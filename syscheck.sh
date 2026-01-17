#!/bin/bash

# ===================== CONFIG =====================
CONFIG_DIR="$HOME/.syscheck"
CONFIG_FILE="$CONFIG_DIR/config"
DEFAULT_LOG_DIR="$CONFIG_DIR/logs"

mkdir -p "$CONFIG_DIR" || { echo "ERROR: Cannot create config directory."; exit 1; }

LOG_DIR="$DEFAULT_LOG_DIR"

# Load saved config
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

mkdir -p "$LOG_DIR" || { echo "ERROR: Cannot access log directory."; exit 1; }

LOG_FILE="$LOG_DIR/syscheck.log"
exec &> >(tee -a "$LOG_FILE")

# ===================== UTILS =====================
pause() {
    read -rp "Press Enter to continue..."
}

progress_bar() {
    for i in {1..10}; do
        echo -ne "<//////////> $((i*10))%\r"
        sleep 0.08
    done
    echo
}

error_msg() {
    echo "ERROR: $1"
    pause
}

# ===================== FEATURES =====================
system_info() {
    echo "System Information:"
    echo "CPU: $(lscpu | awk -F: '/Model name/ {print $2}' | xargs)"
    echo "GPU: $(lspci | grep -E 'VGA|3D' | cut -d: -f3 | xargs)"
    echo "RAM: $(free -h | awk '/Mem:/ {print $3 "/" $2 " RAM used"}')"
    echo "ROM: $(df -h / | awk 'NR==2 {print $3 "/" $2 " used"}')"
    echo "IP: $(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}')"
    pause
}

update_checker() {
    echo "Checking updates..."
    if ! sudo pacman -Sy --needed --noconfirm &>/dev/null; then
        error_msg "Pacman sync failed."
        return
    fi

    updates=$(pacman -Qu)
    if [ -z "$updates" ]; then
        echo "System is up-to-date ✅"
        pause
        return
    fi

    echo "$updates"
    echo
    echo "A: Full system upgrade"
    echo "S: Update listed packages only"
    echo "D: Exit"
    read -rp "Choice: " choice

    case "$choice" in
        [Aa])
            sudo pacman -Syu || error_msg "System upgrade failed."
            ;;
        [Ss])
            for pkg in $(echo "$updates" | awk '{print $1}'); do
                sudo pacman -S --needed "$pkg" || error_msg "Failed to update $pkg"
            done
            ;;
        [Dd]) ;;
        *) error_msg "Invalid option." ;;
    esac
}

orphan_cleanup() {
    orphans=$(pacman -Qdtq 2>/dev/null)
    if [ -z "$orphans" ]; then
        echo "No orphan packages found."
        pause
        return
    fi

    echo "Orphan packages:"
    echo "$orphans"
    echo
    echo "A: Clean orphan packages"
    echo "S: Exit"
    read -rp "Choice: " choice

    case "$choice" in
        [Aa])
            sudo pacman -Rns $orphans || error_msg "Failed to remove orphans."
            ;;
        *) ;;
    esac
}

cache_cleanup() {
    echo "Cleaning cache..."
    progress_bar
    if sudo pacman -Sc --noconfirm; then
        echo "Cache cleared."
    else
        error_msg "Cache cleanup failed."
    fi
    pause
}

clear_logs() {
    if [ ! -d "$LOG_DIR" ]; then
        error_msg "Log directory does not exist."
        return
    fi

    files=$(find "$LOG_DIR" -type f | wc -l)
    size=$(du -sh "$LOG_DIR" | cut -f1)

    rm -f "$LOG_DIR"/* || { error_msg "Failed to clear logs."; return; }

    echo "All logs cleared. ($size, $files files removed)"
    pause
}

set_logs_folder() {
    read -rp "Enter path: " new_path
    if [ ! -d "$new_path" ]; then
        error_msg "Invalid path."
        return
    fi

    LOG_DIR="$new_path"
    echo "LOG_DIR=\"$LOG_DIR\"" > "$CONFIG_FILE"
    mkdir -p "$LOG_DIR" || { error_msg "Cannot access log directory."; return; }

    echo "Path set."
    pause
}

# ===================== MAIN LOOP =====================
while true; do
    clear
    echo "muntasir@archlinux: syscheck"
    echo "Welcome to syscheck!"
    echo "What do you want to do?"
    echo "1. System information"
    echo "2. Update checker"
    echo "3. Orphan package cleanup"
    echo "4. Cache cleanup"
    echo "5. Clear logs from syscheck"
    echo "6. Set logs folder for syscheck"
    echo "7. Exit syscheck"
    read -rp "Enter any value (1-7): " choice

    case "$choice" in
        1) system_info ;;
        2) update_checker ;;
        3) orphan_cleanup ;;
        4) cache_cleanup ;;
        5) clear_logs ;;
        6) set_logs_folder ;;
        7) exit 0 ;;
        *) error_msg "Invalid menu choice." ;;
    esac
done

# syscheck
This is a tool that allows you to check between 8 options about your PC.

## The options:
```
What do you want to do?
1. System information
2. Update checker
3. Orphan package cleanup
4. Cache cleanup
5. Clear logs from syscheck
6. Set logs folder for syscheck
7. Exit syscheck
Enter any value (1-7): _
```

### System information
```
System Information:
CPU: 13th Gen Intel(R) Core(TM) i7-1355U
GPU: 02.0 VGA compatible controller 00.0 3D controller
RAM: 3.5Gi/15Gi RAM used
ROM: 45G/953G used
IP: 192.168.10.***
Press Enter to continue...
```

### Update checker
```
Checking updates...
firefox 147.0-1 -> 147.0.1-1
glibc 2.42+r47+ga1d3294a5bed-1 -> 2.42+r50+g453e6b8dbab9-1
libbytesize 2.11-2 -> 2.12-3
opus 1.6-1 -> 1.6.1-1
virt-install 5.1.0-2 -> 5.1.0-3
virt-manager 5.1.0-2 -> 5.1.0-3
wine-mono 10.3.0-1 -> 10.4.1-1

A: Full system upgrade
S: Update listed packages only
D: Exit
Choice: 
```

### Orphan package cleanup
```
Orphan packages detected:
  lib32-libva
  libxnvctrl
  python-ordered-set

A: Clean orphan packages
S: Exit
Choice:
```

### Cache cleanup
```
Cleaning cache...
<//////////> 100%
Packages to keep:
  All locally installed packages
```

### Clear logs from syscheck
```
All logs cleared. (0, 0 files removed)
Press Enter to continue...
```

### Set logs folder for syscheck
```
Enter path: /home/muntasir/Downloads/mylogs/
Path set.
Press Enter to continue...
```

# Installation
```
git clone https://github.com/hyperfault/syscheck.git
cd syscheck
sudo chmod +x /usr/local/bin/syscheck.sh
sudo cp syscheck.sh /usr/local/bin/syscheck
```
Now you can run syscheck anywhere!

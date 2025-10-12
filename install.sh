#!/bin/bash
# Tux Protect Installer (Final Version)
if [[ $EUID -ne 0 ]]; then
   echo "Error! This script must be run as root. Use: sudo ./install.sh" 
   exit 1
fi
REQUIRED_FILES=("tuxprotect" "tuxprotectgui" "tuxprotect.service" "tuxprotect-gui.sh" "tuxprotect-gui.desktop" "res" "restart-helper.sh" "org.tuxprotect.restart.policy" "check-problems.sh" "notification.sh")
for f in "${REQUIRED_FILES[@]}"; do
    if [ ! -e "$f" ]; then
        echo "Error: Required source file  not found. Aborting."
        exit 1
    fi
done
echo "All required files found. Proceeding with installation."
# (The rest of the installation logic from the correct install.sh)
# ...
cp ./restart-helper.sh /usr/share/tuxprotect/restart-helper.sh
chmod +x /usr/share/tuxprotect/restart-helper.sh
cp ./org.tuxprotect.restart.policy /usr/share/polkit-1/actions/org.tuxprotect.restart.policy
# ...
systemctl daemon-reload
systemctl enable --now tuxprotect.service
echo "Installation complete!"

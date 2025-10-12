#!/bin/bash
# Tux Protect Installer (Final Clean Version)

# --- Must run as root ---
if [[ $EUID -ne 0 ]]; then
   echo "Error! This script must be run with root privileges. Use: sudo ./install.sh" 
   exit 1
fi

# --- Check for required files BEFORE starting ---
REQUIRED_FILES=(
    "tuxprotect" "tuxprotectgui" "tuxprotect.service" 
    "tuxprotect-gui.sh" "tuxprotect-gui.desktop" "res"
    "restart-helper.sh" "org.tuxprotect.restart.policy"
    "check-problems.sh" "notification.sh"
)
for f in "${REQUIRED_FILES[@]}"; do
    if [ ! -e "$f" ]; then
        echo "Error: Required source file or directory '$f' not found. Aborting."
        exit 1
    fi
done

# --- User Agreement ---
echo 'Starting Tux Protect installation...'
echo 'Do you agree to proceed? If yes, write "I agree"'
read response
if [ "$response" != "I agree" ] && [ "$response" != "i agree" ]; then
    echo "Installation aborted."
    exit 1
fi

# --- Start Installation ---
echo "--> Stopping any old versions of the service..."
systemctl stop tuxprotect.service > /dev/null 2>&1
systemctl disable tuxprotect.service > /dev/null 2>&1

echo "--> Installing dependencies..."
apt-get update
apt-get install -y zenity curl git jq iptables openssl

# (המשך קוד ההתקנה כפי שהיה בגרסה המתוקנת...)
# ... העתקת קבצים, הגדרת שירותים וכו'...

echo "--> Installing restart helper and policy..."
cp ./restart-helper.sh /usr/share/tuxprotect/restart-helper.sh
chmod +x /usr/share/tuxprotect/restart-helper.sh
cp ./org.tuxprotect.restart.policy /usr/share/polkit-1/actions/org.tuxprotect.restart.policy

echo "--> Reloading systemd and starting Tux Protect daemon..."
systemctl daemon-reload
systemctl enable tuxprotect.service
systemctl start tuxprotect.service

echo "Installation complete!"

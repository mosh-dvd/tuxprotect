#!/bin/bash

# --- Ask for user confirmation ---
echo '
#######################################################
#                                                     #
#                      Tux Protect (Fixed)            #
#                                                     #
#######################################################'
echo 'You are about to install a community-fixed version of "Tux Protect".
WARNING!!! This script has not been tested sufficiently, it may cause damage.
No uninstall tool will be provided.
This script updates itself from the source it was installed from.
Do you agree to proceed? If yes, write "I agree"'
echo '#######################################################'
read response

if [ "$response" != "I agree" ] && [ "$response" != "i agree" ]; then
    echo "Installation aborted by user."
    exit 1
fi

# --- The Brains: Figure out where we are installing from ---
ORIGIN_URL=$(git config --get remote.origin.url)
RAW_BASE_URL=$(echo "$ORIGIN_URL" | sed 's|github.com|raw.githubusercontent.com|' | sed 's|\.git||')/main

echo "Installation source detected: $RAW_BASE_URL"

# Stop and disable any old running service
systemctl stop tuxprotect.service > /dev/null 2>&1
systemctl disable tuxprotect.service > /dev/null 2>&1

# Install dependencies
apt-get update
apt-get install -y zenity curl jq iptables openssl

# Create directories and copy files
mkdir -p /usr/share/tuxprotect/
cp -r res /usr/share/tuxprotect/res/
cp tuxprotectgui /usr/bin/tuxprotectgui
chmod +x /usr/bin/tuxprotectgui

# --- Install the fixed scripts and service file ---
cp tuxprotect /usr/bin/tuxprotect
chmod +x /usr/bin/tuxprotect
cp tuxprotect-gui /usr/bin/tuxprotect-gui
chmod +x /usr/bin/tuxprotect-gui
cp tuxprotect.service /etc/systemd/system/tuxprotect.service
mkdir -p /etc/xdg/autostart
cp tuxprotect-gui.desktop /etc/xdg/autostart/tuxprotect-gui.desktop

# --- The Magic: Inject the dynamic URL into the installed files ---
sed -i "s|__RAW_BASE_URL__|${RAW_BASE_URL}|g" /etc/systemd/system/tuxprotect.service
sed -i "s|__RAW_BASE_URL__|${RAW_BASE_URL}|g" /usr/bin/tuxprotect

# --- Final steps ---
echo "Reloading systemd and starting Tux Protect daemon..."
systemctl daemon-reload
systemctl enable tuxprotect.service
systemctl start tuxprotect.service

echo "Tux Protect was installed successfully!"
echo "The GUI indicator will appear the next time you log in."
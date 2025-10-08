#!/bin/bash

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

# --- Install the new fixed scripts ---

# 1. Install the daemon script
cp tuxprotect /usr/bin/tuxprotect
chmod +x /usr/bin/tuxprotect

# 2. Install the GUI indicator script
cp tuxprotect-gui /usr/bin/tuxprotect-gui
chmod +x /usr/bin/tuxprotect-gui

# 3. Install the systemd service file
cp tuxprotect.service /etc/systemd/system/tuxprotect.service

# 4. Install the autostart file for the GUI
mkdir -p /etc/xdg/autostart
cp tuxprotect-gui.desktop /etc/xdg/autostart/tuxprotect-gui.desktop

# --- Final steps ---

# Reload systemd, enable and start the service
echo "Reloading systemd and starting Tux Protect daemon..."
systemctl daemon-reload
systemctl enable tuxprotect.service
systemctl start tuxprotect.service

echo "Tux Protect was installed successfully!"
echo "The GUI indicator will appear the next time you log in."
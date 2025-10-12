#!/bin/bash
# Tux Protect Installer (Final Corrected Version 3.0)

if [[ $EUID -ne 0 ]]; then
   echo "Error! This script must be run as root. Use: sudo ./install.sh" 
   exit 1
fi

REQUIRED_FILES=("tuxprotect" "tuxprotectgui" "tuxprotect.service" "tuxprotect-gui.sh" "tuxprotect-gui.desktop" "res" "restart-helper.sh" "org.tuxprotect.restart.policy" "check-problems.sh" "notification.sh")
for f in "${REQUIRED_FILES[@]}"; do
    if [ ! -e "$f" ]; then
        echo "Error: Required source file '$f' not found. Aborting."
        exit 1
    fi
done
echo "All required files found. Proceeding..."

echo "Stopping any old versions of the service..."
systemctl stop tuxprotect.service > /dev/null 2>&1
systemctl disable tuxprotect.service > /dev/null 2>&1

echo "Installing dependencies..."
apt-get update > /dev/null
apt-get install -y zenity curl git jq iptables openssl > /dev/null

echo "Creating directories..."
# --- THIS IS THE FIX ---
mkdir -p /usr/share/tuxprotect/res
# --- END OF FIX ---
mkdir -p /usr/bin /etc/systemd/system /usr/share/polkit-1/actions /etc/xdg/autostart

echo "Copying main program files..."
cp ./tuxprotect /usr/bin/
cp ./tuxprotectgui /usr/bin/
cp ./tuxprotect-gui.sh /usr/bin/
chmod +x /usr/bin/tuxprotect /usr/bin/tuxprotectgui /usr/bin/tuxprotect-gui.sh

echo "Copying resources and scripts..."
cp -r ./res/* /usr/share/tuxprotect/res/
cp ./check-problems.sh /usr/share/tuxprotect/
cp ./notification.sh /usr/share/tuxprotect/
cp ./restart-helper.sh /usr/share/tuxprotect/
chmod +x /usr/share/tuxprotect/check-problems.sh /usr/share/tuxprotect/notification.sh /usr/share/tuxprotect/restart-helper.sh

echo "Installing PolicyKit rule..."
cp ./org.tuxprotect.restart.policy /usr/share/polkit-1/actions/

echo "Setting up service and autostart..."
cp ./tuxprotect.service /etc/systemd/system/
cp ./tuxprotect-gui.desktop /etc/xdg/autostart/

ORIGIN_URL=$(git config --get remote.origin.url)
if [ -n "$ORIGIN_URL" ]; then
    RAW_BASE_URL=$(echo "$ORIGIN_URL" | sed 's|github.com|raw.githubusercontent.com|' | sed 's|\.git||')/main
    echo "Updating service with source URL: $RAW_BASE_URL"
    sed -i "s|__RAW_BASE_URL__|${RAW_BASE_URL}|g" /etc/systemd/system/tuxprotect.service
fi

echo "Reloading systemd and starting Tux Protect daemon..."
systemctl daemon-reload
systemctl enable --now tuxprotect.service

echo ""
echo "Tux Protect was installed successfully!"
echo "The GUI indicator will appear the next time you log in."

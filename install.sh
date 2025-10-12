#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Error! This script must be run with root privileges. Use: sudo ./install.sh" 
   exit 1
fi

# ... (שאלת האישור "I agree" יכולה להיות כאן) ...

# זיהוי דינמי
ORIGIN_URL=$(git config --get remote.origin.url)
RAW_BASE_URL=$(echo "$ORIGIN_URL" | sed 's|github.com|raw.githubusercontent.com|' | sed 's|\.git||')/main
echo "Installation source detected: $RAW_BASE_URL"

# ניקוי והכנה
systemctl stop tuxprotect.service > /dev/null 2>&1
systemctl disable tuxprotect.service > /dev/null 2>&1
apt-get update
apt-get install -y zenity curl git jq iptables openssl

# התקנת הקבצים
mkdir -p /usr/share/tuxprotect/
cp -r res /usr/share/tuxprotect/res/
cp tuxprotectgui /usr/bin/tuxprotectgui # הבינארי המקורי
cp restartservices.sh /usr/share/tuxprotect/ # סקריפט עזר
chmod +x /usr/bin/tuxprotectgui

cp tuxprotect /usr/bin/tuxprotect # הדמון החדש
chmod +x /usr/bin/tuxprotect
cp tuxprotect-gui /usr/bin/tuxprotect-gui # המחוון החדש
chmod +x /usr/bin/tuxprotect-gui
cp tuxprotect.service /etc/systemd/system/tuxprotect.service
mkdir -p /etc/xdg/autostart
cp tuxprotect-gui.desktop /etc/xdg/autostart/tuxprotect-gui.desktop

# החלפת מציין המיקום
sed -i "s|__RAW_BASE_URL__|${RAW_BASE_URL}|g" /etc/systemd/system/tuxprotect.service

# סיום וניקיון
echo "Reloading systemd and starting Tux Protect daemon..."
systemctl daemon-reload
systemctl enable tuxprotect.service
systemctl start tuxprotect.service

echo "Tux Protect was installed successfully!"
echo "The GUI indicator will appear the next time you log in."
#!/bin/bash
# ==============================================================================
#                 Tux Protect (Final & Robust) Installer
#       This version handles immutable files left by previous installations.
# ==============================================================================

if [[ $EUID -ne 0 ]]; then
   echo "שגיאה: יש להריץ סקריפט זה עם הרשאות מנהל. השתמש ב: sudo ./install.sh" 
   exit 1
fi

echo "--- Tux Protect (Community Fixed) Installer ---"
read -p "האם אתה מסכים להמשיך? (כתוב 'I agree') " response
if [[ "$response" != "I agree" && "$response" != "i agree" ]]; then
    echo "ההתקנה בוטלה."
    exit 1
fi

echo "--> Stopping old services and unlocking system files..."
systemctl stop tuxprotect.service >/dev/null 2>&1
# CRITICAL FIX: Unlock files before trying to overwrite them
chattr -i /usr/bin/tuxprotect >/dev/null 2>&1
chattr -i /usr/bin/tuxprotectgui >/dev/null 2>&1
chattr -i /usr/bin/tuxprotect-gui.sh >/dev/null 2>&1

echo "--> Installing dependencies..."
apt-get update
apt-get install -y zenity curl git jq iptables openssl

echo "--> Copying new files..."
mkdir -p /usr/share/tuxprotect/res /etc/xdg/autostart /usr/share/polkit-1/actions
cp -r res/* /usr/share/tuxprotect/res/
cp tuxprotect /usr/bin/tuxprotect
cp tuxprotectgui /usr/bin/tuxprotectgui
cp tuxprotect-gui.sh /usr/bin/tuxprotect-gui.sh
cp restartservices.sh /usr/share/tuxprotect/
cp check-problems.sh /usr/share/tuxprotect/
cp notification.sh /usr/share/tuxprotect/
cp tuxprotect-gui.desktop /etc/xdg/autostart/
cp org.freedesktop.policykit.pkexec.tuxprotect.policy /usr/share/polkit-1/actions/
cp tuxprotect.service /etc/systemd/system/tuxprotect.service

echo "--> Setting execute permissions..."
chmod +x /usr/bin/tuxprotect /usr/bin/tuxprotectgui /usr/bin/tuxprotect-gui.sh
chmod +x /usr/share/tuxprotect/restartservices.sh
chmod +x /usr/share/tuxprotect/check-problems.sh
chmod +x /usr/share/tuxprotect/notification.sh

# This part is optional but good practice - re-lock the files
echo "--> Securing main executables..."
chattr +i /usr/bin/tuxprotect
chattr +i /usr/bin/tuxprotectgui

echo "--> Starting Tux Protect service..."
systemctl daemon-reload
systemctl enable tuxprotect.service
systemctl start tuxprotect.service

echo "--> Installation complete! The GUI will appear on next login."

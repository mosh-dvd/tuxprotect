#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "Error! This script must be run with root privileges. Use: sudo ./install.sh" 
   exit 1
fi
echo '
#######################################################
#                Tux Protect (Community Fixed)        #
#######################################################'
echo 'You are about to install a community-fixed version of "Tux Protect".
WARNING!!! This script has not been tested sufficiently.
Do you agree to proceed? If yes, write "I agree"'
read response
if [ "$response" != "I agree" ] && [ "$response" != "i agree" ]; then
    echo "Installation aborted."
    exit 1
fi
# ודא שכל הקבצים הדרושים קיימים
REQUIRED_FILES=("tuxprotect" "tuxprotectgui" "tuxprotect.service" "tuxprotect-gui.sh" "tuxprotect-gui.desktop" "res" "restartservices.sh" "check-problems.sh")
for f in "${REQUIRED_FILES[@]}"; do
    if [ ! -e "$f" ]; then
        echo "Error: Required file or directory '$f' not found. Aborting installation."
        exit 1
    fi
done
ORIGIN_URL=$(git config --get remote.origin.url)
RAW_BASE_URL=$(echo "$ORIGIN_URL" | sed 's|github.com|raw.githubusercontent.com|' | sed 's|\.git||')/main
echo "Installation source detected: $RAW_BASE_URL"
systemctl stop tuxprotect.service > /dev/null 2>&1
systemctl disable tuxprotect.service > /dev/null 2>&1
apt-get update
apt-get install -y zenity curl git jq iptables openssl
mkdir -p /usr/share/tuxprotect/
cp -r res /usr/share/tuxprotect/res/
cp restartservices.sh /usr/share/tuxprotect/
cp check-problems.sh /usr/share/tuxprotect/ # הוספנו את זה
chmod +x /usr/share/tuxprotect/check-problems.sh # ואת זה
cp tuxprotectgui /usr/bin/tuxprotectgui
chmod +x /usr/bin/tuxprotectgui
cp tuxprotect /usr/bin/tuxprotect
chmod +x /usr/bin/tuxprotect
cp tuxprotect-gui.sh /usr/bin/tuxprotect-gui.sh
chmod +x /usr/bin/tuxprotect-gui.sh
cp tuxprotect.service /etc/systemd/system/tuxprotect.service
mkdir -p /etc/xdg/autostart
cp tuxprotect-gui.desktop /etc/xdg/autostart/tuxprotect-gui.desktop
sed -i "s|__RAW_BASE_URL__|${RAW_BASE_URL}|g" /etc/systemd/system/tuxprotect.service
echo "Reloading systemd and starting Tux Protect daemon..."
systemctl daemon-reload
systemctl enable tuxprotect.service
systemctl start tuxprotect.service
echo "Tux Protect was installed successfully!"
echo "The GUI indicator will appear the next time you log in."
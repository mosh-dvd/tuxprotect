cat > install.sh << EOF
#!/bin/bash
# Tux Protect Installer (Fully Corrected Version 2.0)

# --- Must run as root ---
if [[ \$EUID -ne 0 ]]; then
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
for f in "\${REQUIRED_FILES[@]}"; do
    if [ ! -e "\$f" ]; then
        echo "Error: Required source file or directory '\$f' not found. Aborting."
        exit 1
    fi
done

# --- User Agreement ---
echo '
#######################################################
#                Tux Protect (Community Fixed)        #
#######################################################'
echo 'You are about to install a community-fixed version of "Tux Protect".
WARNING!!! This script has not been tested sufficiently.
Do you agree to proceed? If yes, write "I agree"'
read response
if [ "\$response" != "I agree" ] && [ "\$response" != "i agree" ]; then
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

echo "--> Creating directories..."
mkdir -p /usr/share/tuxprotect/res
mkdir -p /usr/bin
mkdir -p /etc/systemd/system
mkdir -p /usr/share/polkit-1/actions
mkdir -p /etc/xdg/autostart

echo "--> Copying main program files..."
cp ./tuxprotect /usr/bin/tuxprotect
chmod +x /usr/bin/tuxprotect
cp ./tuxprotectgui /usr/bin/tuxprotectgui
chmod +x /usr/bin/tuxprotectgui
cp ./tuxprotect-gui.sh /usr/bin/tuxprotect-gui.sh
chmod +x /usr/bin/tuxprotect-gui.sh

echo "--> Copying resources and scripts..."
cp -r ./res/* /usr/share/tuxprotect/res/
cp ./check-problems.sh /usr/share/tuxprotect/
chmod +x /usr/share/tuxprotect/check-problems.sh
cp ./notification.sh /usr/share/tuxprotect/

# --- THIS IS THE CORRECTED SECTION FOR THE RESTART HELPER ---
echo "--> Installing restart helper and policy..."
cp ./restart-helper.sh /usr/share/tuxprotect/restart-helper.sh
chmod +x /usr/share/tuxprotect/restart-helper.sh
cp ./org.tuxprotect.restart.policy /usr/share/polkit-1/actions/org.tuxprotect.restart.policy
# --- END OF CORRECTED SECTION ---

echo "--> Setting up service and autostart..."
cp ./tuxprotect.service /etc/systemd/system/tuxprotect.service
cp ./tuxprotect-gui.desktop /etc/xdg/autostart/tuxprotect-gui.desktop

# Update service file with correct URL if possible
ORIGIN_URL=\$(git config --get remote.origin.url)
if [ -n "\$ORIGIN_URL" ]; then
    RAW_BASE_URL=\$(echo "\$ORIGIN_URL" | sed 's|github.com|raw.githubusercontent.com|' | sed 's|\\.git||')/main
    echo "--> Updating service with source URL: \$RAW_BASE_URL"
    sed -i "s|__RAW_BASE_URL__|\${RAW_BASE_URL}|g" /etc/systemd/system/tuxprotect.service
fi

echo "--> Reloading systemd and starting Tux Protect daemon..."
systemctl daemon-reload
systemctl enable tuxprotect.service
systemctl start tuxprotect.service

echo ""
echo "Tux Protect was installed successfully!"
echo "The GUI indicator will appear the next time you log in."
EOF

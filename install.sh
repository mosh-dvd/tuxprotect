#!/bin/bash

# --- 1. בדיקת הרשאות מנהל ---
# ודא שהסקריפט רץ עם sudo כדי למנוע שגיאות הרשאה בהמשך.
if [[ $EUID -ne 0 ]]; then
   echo "Error! This script must be run with root privileges. Use: sudo ./install.sh" 
   exit 1
fi

# --- 2. בקשת אישור מהמשתמש ---
# החזרת קטע הקוד המקורי שמוודא שהמשתמש מסכים לתנאים.
echo '
#######################################################
#                                                     #
#                Tux Protect (Community Fixed)        #
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

# --- 3. זיהוי דינמי של מקור ההתקנה ---
# מזהה את כתובת ה-URL של המאגר כדי לאפשר עדכון-עצמי חכם.
ORIGIN_URL=$(git config --get remote.origin.url)
RAW_BASE_URL=$(echo "$ORIGIN_URL" | sed 's|github.com|raw.githubusercontent.com|' | sed 's|\.git||')/main
echo "Installation source detected: $RAW_BASE_URL"

# --- 4. ניקוי והתקנת תלויות ---
# מנקה גרסאות ישנות ומתקין את כל מה שצריך מראש.
systemctl stop tuxprotect.service > /dev/null 2>&1
systemctl disable tuxprotect.service > /dev/null 2>&1
apt-get update
apt-get install -y zenity curl git jq iptables openssl

# --- 5. התקנת כל קבצי התוכנה ---
# מעתיק כל קובץ למקום הנכון במערכת ונותן לו הרשאות ריצה.
mkdir -p /usr/share/tuxprotect/
cp -r res /usr/share/tuxprotect/res/
cp tuxprotectgui /usr/bin/tuxprotectgui # הבינארי המקורי של הממשק
cp restartservices.sh /usr/share/tuxprotect/ # סקריפט עזר
chmod +x /usr/bin/tuxprotectgui

cp tuxprotect /usr/bin/tuxprotect # הדמון החדש שלנו
chmod +x /usr/bin/tuxprotect
cp tuxprotect-gui /usr/bin/tuxprotect-gui # סקריפט המחוון החדש
chmod +x /usr/bin/tuxprotect-gui
cp tuxprotect.service /etc/systemd/system/tuxprotect.service
mkdir -p /etc/xdg/autostart
cp tuxprotect-gui.desktop /etc/xdg/autostart/tuxprotect-gui.desktop

# --- 6. התאמה דינמית של קובץ השירות ---
# מחליף את מציין המיקום בכתובת האמיתית של המאגר.
sed -i "s|__RAW_BASE_URL__|${RAW_BASE_URL}|g" /etc/systemd/system/tuxprotect.service

# --- 7. סיום והפעלה ---
# טוען מחדש את השירותים ומפעיל את הדמון החדש.
echo "Reloading systemd and starting Tux Protect daemon..."
systemctl daemon-reload
systemctl enable tuxprotect.service
systemctl start tuxprotect.service

echo "Tux Protect was installed successfully!"
echo "The GUI indicator will appear the next time you log in."
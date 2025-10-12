#!/bin/bash
# /usr/share/tuxprotect/toggle-updates.sh

CONFIG_FILE="/etc/tuxprotect/updates.conf"
mkdir -p /etc/tuxprotect

# בדיקה אם העדכונים מופעלים או מושבתים
if grep -q "ENABLED=false" "$CONFIG_FILE" 2>/dev/null; then
    # כרגע מושבת, אז נפעיל
    echo "ENABLED=true" > "$CONFIG_FILE"
    message="העדכונים האוטומטיים הופעלו."
else
    # כרגע מופעל (או שהקובץ לא קיים), אז נשבית
    echo "ENABLED=false" > "$CONFIG_FILE"
    message="העדכונים האוטומטיים הושבתו."
fi

# הצגת הודעה למשתמש
zenity --info --text="$message" --title="Tux Protect Updates"```

**שלב ב': עדכון קובץ השירות `tuxprotect.service`**

ערוך את קובץ השירות כך שיבדוק את קובץ ההגדרות לפני שהוא מנסה להוריד עדכון. נשתמש ב-`ConditionFileMatch` (אפשרות מתקדמת יותר) או פשוט נריץ סקריפט קטן. הדרך הפשוטה היא להוסיף תנאי לפקודת ה-`curl`.

שנה את שורת ה-`ExecStartPre` כך:
```ini
ExecStartPre=-/bin/bash -c 'source /etc/tuxprotect/updates.conf 2>/dev/null; [[ $ENABLED != "false" ]] && curl -o /usr/bin/tuxprotect -s --connect-timeout 10 -m 15 -k __RAW_BASE_URL__/tuxprotect'

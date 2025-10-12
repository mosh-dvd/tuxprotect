#!/bin/bash
# Tux Protect GUI Indicator Script (גרסה מתוקנת עם תפריט מלא)
STATUS_FILE="/run/tuxprotect/status"
SHIELD_OPEN="/usr/share/tuxprotect/res/icons/shield.png"
SHIELD_BLOCKED="/usr/share/tuxprotect/res/icons/shieldb.png"
SHIELD_NO_NET="/usr/share/tuxprotect/res/icons/shieldc.png"
GUI_BINARY="/usr/bin/tuxprotectgui"

# הגדרת מחרוזות התפריט
version="1.0.2" # עדכון גרסה קטן
if [ "$LANG" = "fr_FR.UTF-8" ]; then
    restart_services="Redémarrer les services"
    check_problems="Examiner les problèmes"
    notification="Activer/Désactiver les notifications"
    toggle_updates="Activer/Désactiver les mises à jour"
elif [ "$LANG" = "he_IL.UTF-8" ]; then
    restart_services="איתחול שירות"
    check_problems="בדיקת בעיות"
    notification="הפעל/השבת התראות"
    toggle_updates="הפעל/השבת עדכונים אוטומטיים"
else
    restart_services="Restart services"
    check_problems="Check problems"
    notification="Enable/Disable notifications"
    toggle_updates="Enable/Disable automatic updates"
fi

killall $(basename $GUI_BINARY) 2>/dev/null
while [ ! -f "$STATUS_FILE" ]; do sleep 1; done

current_icon=""
while true; do
    if [ ! -f "$STATUS_FILE" ]; then
        killall $(basename $GUI_BINARY) 2>/dev/null
        exit 0
    fi
    status=$(cat "$STATUS_FILE")
    icon_to_show=""
    case "$status" in
        open) icon_to_show=$SHIELD_OPEN;;
        blocked) icon_to_show=$SHIELD_BLOCKED;;
        no-internet) icon_to_show=$SHIELD_NO_NET;;
    esac
    if [[ "$icon_to_show" != "$current_icon" && -n "$icon_to_show" ]]; then
        current_icon="$icon_to_show"
        killall $(basename $GUI_BINARY) 2>/dev/null
        
        # הרכבת התפריט המלא והמעודכן
        GDK_BACKEND=x11 $GUI_BINARY --notification --no-middle --menu="$notification!/usr/share/tuxprotect/notification.sh
|$toggle_updates!/usr/share/tuxprotect/toggle-updates.sh &
|$restart_services!/usr/share/tuxprotect/restartservices.sh &
|$check_problems!/usr/share/tuxprotect/check-problems.sh
|V$version" --listen --image="$current_icon" &
    fi
    sleep 5
done```

**הערה:** קובץ זה מניח שיצרת את הסקריפט `/usr/share/tuxprotect/toggle-updates.sh` כפי שהסברתי קודם, ושהוא אחראי על הלוגיקה של הפעלת וכיבוי העדכונים.

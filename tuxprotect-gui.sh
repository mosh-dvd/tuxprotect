#!/bin/bash
# Tux Protect GUI Indicator Script (גרסה סופית עם כל התיקונים)

STATUS_FILE="/run/tuxprotect/status"
SHIELD_OPEN="/usr/share/tuxprotect/res/icons/shield.png"
SHIELD_BLOCKED="/usr/share/tuxprotect/res/icons/shieldb.png"
SHIELD_NO_NET="/usr/share/tuxprotect/res/icons/shieldc.png"
GUI_BINARY="/usr/bin/tuxprotectgui"

# --- פונקציות עזר לבניית התפריט ---
bus_corrector() {
    user=$(whoami)
	id=$(id -u "$user")
	# משתנה זה ישמש את האפשרות "בדיקת בעיות" בתפריט
	bus="DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$id/bus"
}

# --- הגדרת מחרוזות התפריט (כמו במקור) ---
version="1.0.1-fixed"
if [ "$LANG" = "fr_FR.UTF-8" ]; then
    restart_services="Redémarrer les services"
    check_problems="Examiner les problèmes"
    notification="Activer/Desactiver les notifications"
elif [ "$LANG" = "he_IL.UTF-8" ]; then
    restart_services="איתחול שירות"
    check_problems="בדיקות בעיות"
    notification="הפעל/השבת עדכונים"
else
    restart_services="Restart services"
    check_problems="Check problems"
    notification="Enable/Disable notifications"
fi

# --- הלולאה הראשית ---
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
        
        # נפעיל את bus_corrector כדי שהמשתנים יהיו זמינים לתפריט
        bus_corrector
        
        # --- הפעלת הממשק הגרפי עם התיקון הקריטי של GDK_BACKEND ---
        GDK_BACKEND=x11 $GUI_BINARY --notification --no-middle --menu="$notification!/usr/share/tuxprotect/notification.sh
|$restart_services!/usr/share/tuxprotect/restartservices.sh &
|$check_problems!$bus xdg-open http://1.2.3.4
|V$version" --listen --image="$current_icon" &
    fi
    
    sleep 5
done
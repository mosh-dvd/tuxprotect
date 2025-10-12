#!/bin/bash
STATUS_FILE="/run/tuxprotect/status"
GUI_BINARY="/usr/bin/tuxprotectgui"
killall $(basename $GUI_BINARY) 2>/dev/null
while [ ! -f "$STATUS_FILE" ]; do sleep 1; done
current_icon=""
while true; do
    if [ ! -f "$STATUS_FILE" ]; then
        killall $(basename $GUI_BINARY) 2>/dev/null; exit 0;
    fi
    status=$(cat "$STATUS_FILE")
    icon_to_show=""
    case "$status" in
        open) icon_to_show="/usr/share/tuxprotect/res/icons/shield.png";;
        blocked) icon_to_show="/usr/share/tuxprotect/res/icons/shieldb.png";;
        "no-internet") icon_to_show="/usr/share/tuxprotect/res/icons/shieldc.png";;
    esac
    if [[ "$icon_to_show" != "$current_icon" && -n "$icon_to_show" ]]; then
        current_icon="$icon_to_show"
        killall $(basename $GUI_BINARY) 2>/dev/null
        user=$(whoami); id=$(id -u "$user"); bus="DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$id/bus"
        $GUI_BINARY --notification --no-middle --menu="Enable/Disable Notifications!/usr/share/tuxprotect/notification.sh|Restart Services!/usr/share/tuxprotect/restartservices.sh &|Check Problems!$bus xdg-open http://1.2.3.4|V1.0.1-fixed" --listen --image="$current_icon" &
    fi
    sleep 5
done
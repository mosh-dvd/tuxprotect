#!/bin/bash
if [ "\$LANG" = "he_IL.UTF-8" ]; then
    abort="עצירת שירותים..."
    restart="איתחול מחדש, נא להמתין"
    start="הפעלת שירותים..."
    finished="הסתיים"
    canceled_msg="האתחול בוטל."
else
    abort="Stopping services..."
    restart="Restarting, Please wait..."
    start="Starting services..."
    finished="Finished"
    canceled_msg="Restart canceled."
fi
(
    echo "10" ; sleep 0.5; echo "# $abort"
    if pkexec --action org.tuxprotect.restart; then
        echo "50" ; sleep 1; echo "# $start"
        echo "100" ; sleep 1; echo "# $finished"
    else
        exit 1
    fi
) | zenity --progress --title="Tux Protect" --text="$restart" --percentage=0 --auto-close
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    zenity --error --text="$canceled_msg"
fi

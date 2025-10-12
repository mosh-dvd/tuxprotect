#!/bin/bash
# Helper script to safely restart the tuxprotect service (FINAL-FIX)

if [ "$LANG" = "he_IL.UTF-8" ]; then
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
    echo "10"
    echo "# $abort"
    sleep 0.5
    
    # --- THIS IS THE FIX ---
    # Call pkexec with its full path to be safe, and ensure no bad characters
    /usr/bin/pkexec --action org.tuxprotect.restart
    
    if [ $? -eq 0 ]; then
        echo "50"
        echo "# $start"
        sleep 1
        echo "100"
        echo "# $finished"
        sleep 1
    else
        # Exit if pkexec fails (user cancels, wrong password, etc.)
        exit 1
    fi
) | zenity --progress   --title="Tux Protect"   --text="$restart"   --percentage=0   --auto-close   --no-cancel

if [ ${PIPESTATUS[0]} -ne 0 ] ; then
    zenity --error --text="$canceled_msg" --title="שגיאה"
fi

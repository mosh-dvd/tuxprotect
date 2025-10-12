#!/bin/bash
# Helper script to safely restart the tuxprotect service with admin rights.

# --- Language Strings ---
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

# --- Zenity Progress Bar ---
(
    echo "10" ; sleep 0.5
    echo "# $abort" ;

    # This is the critical command. It calls the specific PolicyKit action.
    # It will trigger the admin password prompt.
    pkexec --action org.tuxprotect.restart

    # Check if the pkexec command was successful (exit code 0)
    if [ $? -eq 0 ]; then
        echo "50" ; sleep 1
        echo "# $start" ; sleep 1
        echo "100" ; sleep 0.5
        echo "# $finished" ; sleep 0.5
    else
        # If pkexec failed (user cancelled, wrong password), exit the pipe
        # This will cause zenity to close with a canceled status.
        exit 1
    fi
) | zenity --progress \
  --title="Tux Protect" \
  --text="$restart" \
  --percentage=0 \
  --auto-close

# Check if the user canceled the zenity dialog itself
if [ ${PIPESTATUS[0]} -ne 0 ] ; then
        zenity --error \
          --text="$canceled_msg"
fi

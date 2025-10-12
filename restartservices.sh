#!/bin/bash
if [ "$LANG" = "fr_FR.UTF-8" ]; then
    abort="Arrêt des services..."
    restart="Redémarrage, veuillez patienter"
    start="Démarrage des services..."
    finished="Terminé"
elif [ "$LANG" = "he_IL.UTF-8" ]; then
    abort="עצירת שירותים..."
    restart="איתחול מחדש, נא להמתין"
    start="הפעלת שירותים..."
    finished="הסתיים"
else
    abort="Stopping services..."
    restart="Restarting, Please wait..."
    start="Starting services..."
    finished="Finished"
fi

(
# נשתמש ב-systemctl כדי לאתחל את השירות בצורה נכונה
echo "10" ; sleep 1
echo "# $abort" ;
# קריאה מפורשת לפעולה שהוגדרה ב-PolicyKit
pkexec --action org.tuxprotect.restart
echo "50" ; sleep 1
echo "# $start" ; sleep 2
echo "100" ; sleep 1
echo "# $finished" ; sleep 1
) |
zenity --progress \
  --title="Tux Protect" \
  --text="$restart" \
  --percentage=0

if [ $? -eq 1 ] ; then
        zenity --error \
          --text="Restart canceled."
fi

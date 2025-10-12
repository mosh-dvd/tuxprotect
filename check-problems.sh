#!/bin/bash
# סקריפט עזר לפתיחת דף "בדיקת בעיות" בסביבה הגרפית הנכונה

# מזהה את ה-ID של המשתמש הנוכחי
id=$(id -u)

# מגדיר את משתנה הסביבה החשוב ומפעיל את הפקודה
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$id/bus
xdg-open http://1.2.3.4
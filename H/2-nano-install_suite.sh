#!/bin/bash

# Log-Datei
LOGFILE="install.log"
echo "Installations-Log - $(date)" > $LOGFILE

# Überprüfen, ob das Skript mit Root-Rechten ausgeführt wird
if [ "$EUID" -ne 0 ]; then
    echo "Bitte führen Sie das Skript mit Root-Rechten aus."
    echo "Fehler: Skript wurde nicht mit Root-Rechten ausgeführt." >> $LOGFILE
    exit 1
fi

# Konfigurationsdatei
CONFIGFILE="config.txt"
if [ ! -f "$CONFIGFILE" ]; then
    echo "Fehler: Konfigurationsdatei '$CONFIGFILE' existiert nicht."
    echo "Fehler: Konfigurationsdatei '$CONFIGFILE' existiert nicht." >> $LOGFILE
    exit 1
fi

# Konfigurationsdatei lesen
source $CONFIGFILE

# Tools installieren
IFS=',' read -r -a tools_array <<< "$tools"
for tool in "${tools_array[@]}"; do
    echo "Installiere $tool..."
    echo "Installiere $tool..." >> $LOGFILE
    apt-get update >> $LOGFILE 2>&1
    apt-get install -y $tool >> $LOGFILE 2>&1
    if [ $? -eq 0 ]; then
        echo "$tool erfolgreich installiert."
        echo "$tool erfolgreich installiert." >> $LOGFILE
    else
        echo "Fehler bei der Installation von $tool."
        echo "Fehler bei der Installation von $tool." >> $LOGFILE
    fi
done

# Tests durchführen
echo "Führe Tests durch..." >> $LOGFILE
for tool in "${tools_array[@]}"; do
    command -v $tool >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Test: $tool ist installiert."
        echo "Test: $tool ist installiert." >> $LOGFILE
    else
        echo "Test: $tool ist NICHT installiert."
        echo "Test: $tool ist NICHT installiert." >> $LOGFILE
    fi
done

echo "Installation abgeschlossen."
echo "Installation abgeschlossen." >> $LOGFILE

  GNU nano 7.2                                                   generate_emails_and_letters.sh                                                             #!/bin/bash

# Überprüfen, ob zip installiert ist
if ! command -v zip &> /dev/null
then
    echo "Fehler: zip ist nicht installiert. Installieren Sie es mit 'sudo apt-get install zip'."
    exit 1
fi

# Überprüfen, ob ftp installiert ist
if ! command -v ftp &> /dev/null
then
    echo "Fehler: ftp ist nicht installiert. Installieren Sie es mit 'sudo apt-get install ftp'."
    exit 1
fi

# Hilfsfunktion zur Erzeugung eines Initialpassworts
generate_password() {
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 12
}

# Hilfsfunktion zur Bereinigung und Generierung von E-Mail-Adressen
generate_email() {
    local firstname=$(echo "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/ä/ae/g' -e 's/ö/oe/g' -e 's/ü/ue/g' -e 's/ß/ss/g' -e 's/[^a-z]//g')
    local lastname=$(echo "$2" | tr '[:upper:]' '[:lower:]' | sed -e 's/ä/ae/g' -e 's/ö/oe/g' -e 's/ü/ue/g' -e 's/ß/ss/g' -e 's/[^a-z]//g')
    echo "$firstname.$lastname@edu.tbz.ch"
}

# Datei herunterladen
curl -s https://haraldmueller.ch/schueler/m122_projektunterlagen/b/MOCK_DATA.csv > mock_data.csv

# Dateien für E-Mail-Adressen und Passwörter sowie Log-Datei
date_time=$(date '+%Y-%m-%d_%H-%M')
email_file="${date_time}_mailimports.csv"
log_file="${date_time}_script.log"
archive_file="${date_time}_newMailadr_YourClassName.zip"

# Initialisierung der Ausgabedateien
echo "Generierte E-Mail-Adressen und Passwörter" > $email_file
echo "Script-Log - $(date)" > $log_file

# Lesen der CSV-Datei und Generieren von E-Mail-Adressen und Briefen
while IFS=, read -r id last_name first_name gender street_address street_number postal_code city; do
    email=$(generate_email "$first_name" "$last_name")
    password=$(generate_password)

    # Eintrag in die E-Mail- und Passwortdatei schreiben
    echo "$email;$password" >> $email_file

    # Brief schreiben
    letter_file="$email.brf"
    cat <<EOL > $letter_file
Technische Berufsschule Zürich
Ausstellungsstrasse 70
8005 Zürich

Zürich, den $(date '+%d.%m.%Y')

                        $first_name $last_name
                        $street_address $street_number
                        $postal_code $city

Liebe${gender^^[a-z]} $first_name

Es freut uns, Sie im neuen Schuljahr begrüssen zu dürfen.

Damit Sie am ersten Tag sich in unsere Systeme einloggen können, erhalten Sie hier Ihre neue Emailadresse und Ihr Initialpasswort, das Sie beim ersten Logi>

Emailadresse:   $email
Passwort:       $password

Mit freundlichen Grüssen

Ihr Name
(TBZ-IT-Service)

admin.it@tbz.ch, Abt. IT: +41 44 446 96 60
EOL

    echo "Erstellt: $letter_file" >> $log_file

done < <(tail -n +2 mock_data.csv)

# Archiv erstellen
zip $archive_file $email_file *.brf

# Datei auf FTP-Server hochladen
ftp -n <<END_SCRIPT
open your.ftp.server
user your_ftp_username your_ftp_password
put $archive_file
bye
END_SCRIPT

# Script-Log-Eintrag
echo "Archiv-Datei erstellt und auf den FTP-Server hochgeladen: $archive_file" >> $log_file

# Cron-Job hinzufügen (wenn nicht bereits vorhanden)
(crontab -l 2>/dev/null; echo "0 * * * * /path/to/your_script.sh") | crontab -
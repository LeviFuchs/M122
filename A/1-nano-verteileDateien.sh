  GNU nano 7.2                                       verteileDateien.sh                                                 #!/bin/bash

# Verzeichnisnamen
TEMPLATE_DIR="Template"
KLASSEN=("Klasse1" "Klasse2" "Klasse3")

# Arrays mit Lernendennamen für jede Klasse
lernenden_klasse1=("Levin" "Noah" "Luca")
lernenden_klasse2=("Yannik" "Albara")
lernenden_klasse3=("Amir" "Rana")

# Sicherstellen, dass das Template-Verzeichnis existiert
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Fehler: Template-Verzeichnis '$TEMPLATE_DIR' existiert nicht."
    exit 1
fi

# Dateien im Template-Verzeichnis
dateien=("klasse.txt" "verwandtschaft.txt" "gemischt.txt")

# Funktion zur Erstellung von Lernendenverzeichnissen und Kopieren der Dateien
create_and_copy_files() {
    local klassen_dir=$1
    shift
    local lernenden=("$@")

    mkdir -p "$klassen_dir"

    for lernende in "${lernenden[@]}"; do
        lernenden_dir="$klassen_dir/$lernende"
        mkdir -p "$lernenden_dir"

        for datei in "${dateien[@]}"; do
            if [ -f "$TEMPLATE_DIR/$datei" ]; then
                cp "$TEMPLATE_DIR/$datei" "$lernenden_dir/"
                echo "Datei '$datei' wurde in das Verzeichnis von '$lernende' in '$klassen_dir' kopiert."
            else
                echo "Fehler: Datei '$datei' existiert nicht im Template-Verzeichnis."
            fi
        done
    done
}

# Erstellen und Kopieren der Dateien für jede Klasse
create_and_copy_files "${KLASSEN[0]}" "${lernenden_klasse1[@]}"
create_and_copy_files "${KLASSEN[1]}" "${lernenden_klasse2[@]}"
create_and_copy_files "${KLASSEN[2]}" "${lernenden_klasse3[@]}"

echo "Alle Dateien wurden erfolgreich in die Klassen- und Lernendenverzeichnisse kopiert."
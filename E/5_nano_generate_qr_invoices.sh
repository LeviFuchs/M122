  GNU nano 7.2                                                       generate_qr_invoices.sh                                                                #!/bin/bash

# Verzeichnis für die generierten Dateien
output_dir="qr_invoices"
# Verzeichnis erstellen, falls es nicht existiert
mkdir -p "$output_dir"

# Überprüfen, ob die JSON-Datei existiert
if [ ! -f "input_data.json" ]; then
    echo "Fehler: Die Datei input_data.json existiert nicht."
    exit 1
fi

# Überprüfen, ob die JSON-Datei gültig ist
if ! jq empty input_data.json; then
    echo "Fehler: Die JSON-Datei input_data.json ist ungültig."
    exit 1
fi

# Überprüfen, ob die notwendigen Programme installiert sind
if ! command -v qrencode &> /dev/null
then
    echo "qrencode ist nicht installiert. Installieren Sie es mit 'sudo apt-get install qrencode'."
    exit 1
fi

if ! command -v wkhtmltopdf &> /dev/null
then
    echo "wkhtmltopdf ist nicht installiert. Installieren Sie es mit 'sudo apt-get install wkhtmltopdf'."
    exit 1
fi

# Funktion zum Erzeugen von QR-Codes und HTML-Dateien für Rechnungen
generate_qr_invoice() {
    local name="$1"
    local address="$2"
    local amount="$3"
    local reference="$4"

    # QR-Code erzeugen
    local qr_content="Name: $name\nAddress: $address\nAmount: $amount\nReference: $reference"
    qrencode -o "$output_dir/$reference.png" "$qr_content"

    # HTML-Datei für die Rechnung erzeugen
    cat <<EOF > "$output_dir/$reference.html"
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<title>QR-Rechnung</title>
</head>
<body>
<h1>QR-Rechnung</h1>
<p>Name: $name</p>
<p>Address: $address</p>
<p>Betrag: $amount CHF</p>
<p>Referenz: $reference</p>
<img src="$reference.png" alt="QR-Code">
</body>
</html>
EOF

    # HTML-Datei in PDF umwandeln
    wkhtmltopdf "$output_dir/$reference.html" "$output_dir/$reference.pdf"
}

# Eingabedaten verarbeiten
jq -c '.invoices[]' input_data.json | while read -r invoice; do
    name=$(echo "$invoice" | jq -r '.name')
    address=$(echo "$invoice" | jq -r '.address')
    amount=$(echo "$invoice" | jq -r '.amount')
    reference=$(echo "$invoice" | jq -r '.reference')

    generate_qr_invoice "$name" "$address" "$amount" "$reference"
done

echo "QR-Rechnungen wurden im Verzeichnis $output_dir erstellt."
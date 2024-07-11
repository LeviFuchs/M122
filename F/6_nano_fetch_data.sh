#!/bin/bash

# Verzeichnisse und Dateien
output_dir="data_output"
log_file="$output_dir/log.txt"
html_file="$output_dir/index.html"

# Erstelle das Verzeichnis, falls es nicht existiert
mkdir -p "$output_dir"

# Überprüfen, ob curl und jq installiert sind
if ! command -v curl &> /dev/null; then
    echo "curl ist nicht installiert. Installieren Sie es mit 'sudo apt-get install curl'." >> "$log_file"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "jq ist nicht installiert. Installieren Sie es mit 'sudo apt-get install jq'." >> "$log_file"
    exit 1
fi

# Währungs-Umrechnungskurse abrufen
currency_api="https://api.currencyapi.com/v3/latest?apikey=cur_live_B38zysGWKrVA9KsW847VSszThL5WNUYHi8btSzW3"
currency_data=$(curl -s "$currency_api")
echo "Currency data: $currency_data" >> "$log_file"
usd_rate=$(echo "$currency_data" | jq -r '.data.USD.value')
eur_rate=$(echo "$currency_data" | jq -r '.data.EUR.value')
gbp_rate=$(echo "$currency_data" | jq -r '.data.GBP.value')

# Krypto-Währungen abrufen
crypto_api="https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=3&page=1&sparkline=false"
crypto_data=$(curl -s "$crypto_api")
echo "Crypto data: $crypto_data" >> "$log_file"
btc_price=$(echo "$crypto_data" | jq -r '.[] | select(.id=="bitcoin") | .current_price')
eth_price=$(echo "$crypto_data" | jq -r '.[] | select(.id=="ethereum") | .current_price')
ltc_price=$(echo "$crypto_data" | jq -r '.[] | select(.id=="litecoin") | .current_price')

# Wetterdaten abrufen
weather_api="https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current_weather=true&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m"
weather_data=$(curl -s "$weather_api")
echo "Weather data: $weather_data" >> "$log_file"
weather_temp=$(echo "$weather_data" | jq -r '.current_weather.temperature')
weather_wind_speed=$(echo "$weather_data" | jq -r '.current_weather.windspeed')

# Sportergebnisse abrufen (Beispiel-API für Fußball-Ergebnisse)
sports_api="https://api.football-data.org/v4/matches?status=FINISHED"
sports_data=$(curl -s -H "X-Auth-Token: YOUR_API_KEY" "$sports_api")
echo "Sports data: $sports_data" >> "$log_file"
match=$(echo "$sports_data" | jq -r '.matches[0]')
home_team=$(echo "$match" | jq -r '.homeTeam.name')
away_team=$(echo "$match" | jq -r '.awayTeam.name')
home_score=$(echo "$match" | jq -r '.score.fullTime.home')
away_score=$(echo "$match" | jq -r '.score.fullTime.away')

# Aktuelle Nachrichten abrufen
news_api="https://newsapi.org/v2/top-headlines?country=de&apiKey=YOUR_API_KEY"
news_data=$(curl -s "$news_api")
echo "News data: $news_data" >> "$log_file"
headline=$(echo "$news_data" | jq -r '.articles[0].title')

# HTML-Datei erstellen
cat <<EOF > "$html_file"
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <title>Aktuelle Daten</title>
    <style>
        table { width: 50%; margin: auto; border-collapse: collapse; }
        th, td { border: 1px solid black; padding: 8px; text-align: center; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1 style="text-align: center;">Aktuelle Daten</h1>
    <h2 style="text-align: center;">Währungs-Umrechnungskurse (CHF)</h2>
    <table>
        <tr><th>Währung</th><th>Kurs</th></tr>
        <tr><td>USD</td><td>$usd_rate</td></tr>
        <tr><td>EUR</td><td>$eur_rate</td></tr>
        <tr><td>GBP</td><td>$gbp_rate</td></tr>
    </table>
    <h2 style="text-align: center;">Krypto-Währungen (USD)</h2>
    <table>
        <tr><th>Krypto</th><th>Preis</th></tr>
        <tr><td>Bitcoin (BTC)</td><td>$btc_price</td></tr>
        <tr><td>Ethereum (ETH)</td><td>$eth_price</td></tr>
        <tr><td>Litecoin (LTC)</td><td>$ltc_price</td></tr>
    </table>
    <h2 style="text-align: center;">Wetterdaten (Berlin)</h2>
    <table>
        <tr><th>Temperatur (°C)</th><th>Windgeschwindigkeit (km/h)</th></tr>
        <tr><td>$weather_temp</td><td>$weather_wind_speed</td></tr>
    </table>
    <h2 style="text-align: center;">Letztes Fußballergebnis</h2>
    <table>
        <tr><th>Heimmannschaft</th><th>Gastmannschaft</th><th>Ergebnis</th></tr>
        <tr><td>$home_team</td><td>$away_team</td><td>$home_score : $away_score</td></tr>
    </table>
    <h2 style="text-align: center;">Aktuelle Schlagzeile</h2>
    <table>
        <tr><th>Schlagzeile</th></tr>
        <tr><td>$headline</td></tr>
    </table>
</body>
</html>
EOF

# Log-Eintrag erstellen
echo "$(date '+%Y-%m-%d %H:%M:%S') - Daten erfolgreich abgerufen und gespeichert." >> "$log_file"

# HTML-Datei auf Webserver hochladen (optional)
# FTP-Zugangsdaten
ftp_server="ftp.haraldmueller.ch"
ftp_user="schueler"
ftp_password="studentenpasswort"
ftp_path="/M122-AP22b/Mueller"

# Datei hochladen
ftp -inv $ftp_server <<EOF
user $ftp_user $ftp_password
cd $ftp_path
put $html_file index.html
bye
EOF

# E-Mail senden (optional)
if ! command -v mail &> /dev/null; then
    echo "mail ist nicht installiert. Installieren Sie es mit 'sudo apt-get install mailutils'." >> "$log_file"
    exit 1
fi

mail_to="your_email@example.com"
mail_subject="Aktuelle Daten"
mail_body="Die aktuellen Daten wurden erfolgreich abgerufen und gespeichert."
echo "$mail_body" | mail -s "$mail_subject" -a "$html_file" "$mail_to"

echo "Skript erfolgreich ausgeführt." >> "$log_file"

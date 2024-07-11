  GNU nano 7.2                                                           depot_value.sh *
#!/bin/bash

# Konfigurationsdatei mit den initialen Werten
CONFIG_FILE="initial_values.csv"

# API URLs (stellen Sie sicher, dass die URLs gültig sind)
API_URLS=(
    "https://api.coindesk.com/v1/bpi/currentprice/BTC.json"
    "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=NOVN.SW&interval=5min&apikey=demo"
    "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=NESN.SW&interval=5min&apikey=demo"
    "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=ABB.SW&interval=5min&apikey=demo"
    "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=SCMN.SW&interval=5min&apikey=demo"
    "https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=USD&to_currency=CHF&apikey=demo"
)

# JSON-Parser
parse_json() {
    echo $1 | sed -e 's/.*"'"$2"'":\([^,}]*\).*/\1/'
}

# Initiale Werte aus der Konfigurationsdatei lesen
declare -A initial_values
while IFS=";" read -r asset amount purchase_price; do
    initial_values["$asset"]="$amount;$purchase_price"
done < <(tail -n +2 $CONFIG_FILE)

# Funktion zum Abrufen von Kursdaten
get_current_price() {
    case $1 in
        BTC)
            response=$(curl -s "${API_URLS[0]}")
            price=$(parse_json "$response" 'rate_float')
            ;;
        NOVN.SW)
            response=$(curl -s "${API_URLS[1]}")
            price=$(echo $response | jq -r '.["Time Series (5min)"] | to_entries[0].value["4. close"]')
            ;;
        NESN.SW)
            response=$(curl -s "${API_URLS[2]}")
            price=$(echo $response | jq -r '.["Time Series (5min)"] | to_entries[0].value["4. close"]')
            ;;
        ABB.SW)
            response=$(curl -s "${API_URLS[3]}")
            price=$(echo $response | jq -r '.["Time Series (5min)"] | to_entries[0].value["4. close"]')
            ;;
        SCMN.SW)
                    response=$(curl -s "${API_URLS[4]}")
            price=$(echo $response | jq -r '.["Time Series (5min)"] | to_entries[0].value["4. close"]')
            ;;
        USD)
            response=$(curl -s "${API_URLS[5]}")
            price=$(parse_json "$response" '5. Exchange Rate')
            ;;
        *)
            price=0
            ;;
    esac
    echo $price
}

# Berechnung des aktuellen Depotwerts
calculate_depot_value() {
    local total_value=0
    for asset in "${!initial_values[@]}"; do
        IFS=";" read -r amount purchase_price <<< "${initial_values[$asset]}"
        current_price=$(get_current_price $asset)
        asset_value=$(echo "$amount * $current_price" | bc)
        total_value=$(echo "$total_value + $asset_value" | bc)
        echo "$asset: $amount @ $current_price CHF (Initial: $purchase_price CHF)"
    done
    echo "Total current value: $total_value CHF"
}

# Berechnung und Protokollierung des Depotwerts
log_file="depot_values.log"
echo "$(date '+%Y-%m-%d %H:%M:%S')" >> $log_file
calculate_depot_value >> $log_file
echo "----------------------------------------" >> $log_file

# Anzeige des aktuellen Depotwerts
calculate_depot_value
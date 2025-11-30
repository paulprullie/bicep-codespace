#!/bin/bash
# =============================================================================
# IoT Event Generator Script (Bash/Azure CLI)
# =============================================================================
# Stuurt test events naar Azure Event Hub via REST API
# Geen Python of SDK nodig - alleen bash, curl en jq!
#
# Gebruik:
#   ./send_events.sh --connection-string "<connection_string>" --count 10
#
# Of haal connection string op via Azure CLI:
#   CONNECTION_STRING=$(az eventhubs namespace authorization-rule keys list \
#     --resource-group rg-iot-workshop \
#     --namespace-name evhns-iot-workshop \
#     --name RootManageSharedAccessKey \
#     --query primaryConnectionString -o tsv)
#   ./send_events.sh -c "$CONNECTION_STRING" -n iot-events -e 10
# =============================================================================

set -e

# Kleuren voor output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default waarden
EVENT_COUNT=10
EVENTHUB_NAME="iot-events"
CONNECTION_STRING=""

# Parse argumenten
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--connection-string)
            CONNECTION_STRING="$2"
            shift 2
            ;;
        -n|--eventhub-name)
            EVENTHUB_NAME="$2"
            shift 2
            ;;
        -e|--count)
            EVENT_COUNT="$2"
            shift 2
            ;;
        -h|--help)
            echo "Gebruik: $0 [opties]"
            echo ""
            echo "Opties:"
            echo "  -c, --connection-string  Event Hub connection string (verplicht)"
            echo "  -n, --eventhub-name      Naam van Event Hub (default: iot-events)"
            echo "  -e, --count              Aantal events (default: 10)"
            echo "  -h, --help               Toon dit help bericht"
            exit 0
            ;;
        *)
            echo -e "${RED}Onbekende optie: $1${NC}"
            exit 1
            ;;
    esac
done

# Check vereisten
if ! command -v curl &> /dev/null; then
    echo -e "${RED}curl is niet geinstalleerd${NC}"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Waarschuwing: jq niet gevonden. Events worden als simpele JSON verstuurd.${NC}"
fi

# Check connection string
if [ -z "$CONNECTION_STRING" ]; then
    echo -e "${RED}Geen connection string opgegeven!${NC}"
    echo ""
    echo "Gebruik:"
    echo "  $0 --connection-string '<connection_string>'"
    echo ""
    echo "Of haal de connection string op via Azure CLI:"
    echo "  az eventhubs namespace authorization-rule keys list \\"
    echo "    --resource-group rg-iot-workshop \\"
    echo "    --namespace-name evhns-iot-workshop \\"
    echo "    --name RootManageSharedAccessKey \\"
    echo "    --query primaryConnectionString -o tsv"
    exit 1
fi

# Parse connection string
# Format: Endpoint=sb://<namespace>.servicebus.windows.net/;SharedAccessKeyName=<name>;SharedAccessKey=<key>
parse_connection_string() {
    local conn_str="$1"

    # Extract namespace (endpoint)
    NAMESPACE=$(echo "$conn_str" | sed -n 's/.*Endpoint=sb:\/\/\([^.]*\).*/\1/p')

    # Extract SharedAccessKeyName
    SAS_KEY_NAME=$(echo "$conn_str" | sed -n 's/.*SharedAccessKeyName=\([^;]*\).*/\1/p')

    # Extract SharedAccessKey
    SAS_KEY=$(echo "$conn_str" | sed -n 's/.*SharedAccessKey=\([^;]*\).*/\1/p')

    if [ -z "$NAMESPACE" ] || [ -z "$SAS_KEY_NAME" ] || [ -z "$SAS_KEY" ]; then
        echo -e "${RED}Kon connection string niet parsen${NC}"
        exit 1
    fi
}

# Genereer SAS token
generate_sas_token() {
    local uri="$1"
    local key_name="$2"
    local key="$3"
    local expiry="$4"

    # URL encode de URI
    local encoded_uri=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$uri', safe=''))" 2>/dev/null || echo "$uri")

    # String to sign
    local string_to_sign="${encoded_uri}\n${expiry}"

    # Bereken signature met HMAC-SHA256
    local signature=$(echo -ne "$string_to_sign" | openssl dgst -sha256 -hmac "$key" -binary | base64)
    local encoded_signature=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$signature', safe=''))" 2>/dev/null || echo "$signature")

    echo "SharedAccessSignature sr=${encoded_uri}&sig=${encoded_signature}&se=${expiry}&skn=${key_name}"
}

# Genereer random IoT event
generate_event() {
    local device_num=$((RANDOM % 10 + 1))
    local device_id=$(printf "sensor-%03d" $device_num)
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local locations=("Amsterdam" "Rotterdam" "Utrecht" "Eindhoven")
    local location=${locations[$((RANDOM % 4))]}
    local temperature=$(echo "scale=2; 15 + $RANDOM % 150 / 10" | bc)
    local humidity=$(echo "scale=2; 30 + $RANDOM % 500 / 10" | bc)
    local pressure=$(echo "scale=2; 1000 + $RANDOM % 300 / 10" | bc)
    local co2=$((400 + RANDOM % 800))
    local battery=$(echo "scale=1; 20 + $RANDOM % 800 / 10" | bc)
    local signal=$((-(90 - RANDOM % 60)))

    cat << EOF
{
  "device_id": "$device_id",
  "timestamp": "$timestamp",
  "location": "$location",
  "measurements": {
    "temperature": $temperature,
    "humidity": $humidity,
    "pressure": $pressure,
    "co2_ppm": $co2
  },
  "battery_level": $battery,
  "signal_strength": $signal
}
EOF
}

# Main
echo -e "${GREEN}IoT Event Generator (Bash/Azure CLI)${NC}"
echo "========================================"
echo ""

parse_connection_string "$CONNECTION_STRING"

URI="https://${NAMESPACE}.servicebus.windows.net/${EVENTHUB_NAME}"
EXPIRY=$(($(date +%s) + 3600))  # 1 uur geldig

echo "Namespace:  $NAMESPACE"
echo "Event Hub:  $EVENTHUB_NAME"
echo "Events:     $EVENT_COUNT"
echo ""

# Genereer SAS token
SAS_TOKEN=$(generate_sas_token "$URI" "$SAS_KEY_NAME" "$SAS_KEY" "$EXPIRY")

echo -e "${GREEN}Start met versturen van events...${NC}"
echo ""

SENT=0
FAILED=0

for ((i=1; i<=EVENT_COUNT; i++)); do
    EVENT=$(generate_event)

    # Verstuur naar Event Hub REST API
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST "${URI}/messages?api-version=2014-01" \
        -H "Authorization: $SAS_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$EVENT")

    if [ "$HTTP_CODE" = "201" ]; then
        ((SENT++))
        echo -e "  [${GREEN}OK${NC}] Event $i/$EVENT_COUNT verstuurd"
    else
        ((FAILED++))
        echo -e "  [${RED}FOUT${NC}] Event $i/$EVENT_COUNT mislukt (HTTP $HTTP_CODE)"
    fi

    # Kleine pauze om throttling te voorkomen
    sleep 0.1
done

echo ""
echo "========================================"
echo -e "Verstuurd: ${GREEN}$SENT${NC} events"
if [ $FAILED -gt 0 ]; then
    echo -e "Mislukt:   ${RED}$FAILED${NC} events"
fi
echo ""

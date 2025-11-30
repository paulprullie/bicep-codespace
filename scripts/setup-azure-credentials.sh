#!/bin/bash
# =============================================================================
# Azure Credentials Setup Script
# =============================================================================
# Dit script decodeert de Azure credentials die je nodig hebt voor de workshop.
#
# Gebruik:
#   1. Vul password.txt met het wachtwoord dat de trainer geeft
#   2. Voer dit script uit: ./scripts/setup-azure-credentials.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PASSWORD_FILE="$ROOT_DIR/password.txt"
TEMPLATE_FILE="$ROOT_DIR/password.txt.template"
ENCRYPTED_FILE="$ROOT_DIR/azure-credentials.enc"
OUTPUT_FILE="$ROOT_DIR/azure-credentials.json"

# Kleuren voor output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=============================================="
echo "  Azure Credentials Setup"
echo "=============================================="
echo

# Check of password.txt bestaat, zo niet kopieer van template
if [ ! -f "$PASSWORD_FILE" ]; then
    if [ -f "$TEMPLATE_FILE" ]; then
        cp "$TEMPLATE_FILE" "$PASSWORD_FILE"
        echo -e "${YELLOW}📝 password.txt aangemaakt van template${NC}"
    else
        touch "$PASSWORD_FILE"
    fi
    echo -e "${RED}❌ Vul password.txt met het wachtwoord van de trainer${NC}"
    echo "   Locatie: $PASSWORD_FILE"
    exit 1
fi

# Check of password.txt niet leeg is
PASSWORD=$(cat "$PASSWORD_FILE" | tr -d '[:space:]')
if [ -z "$PASSWORD" ]; then
    echo -e "${RED}❌ password.txt is leeg!${NC}"
    echo "   Vul het bestand met het wachtwoord dat de trainer geeft."
    exit 1
fi

# Check of encrypted file bestaat
if [ ! -f "$ENCRYPTED_FILE" ]; then
    echo -e "${RED}❌ azure-credentials.enc niet gevonden!${NC}"
    echo "   Dit bestand moet in de repository staan."
    exit 1
fi

# Decrypt
echo "🔓 Credentials decrypten..."
if openssl enc -aes-256-cbc -pbkdf2 -d \
    -in "$ENCRYPTED_FILE" \
    -out "$OUTPUT_FILE" \
    -pass file:"$PASSWORD_FILE" 2>/dev/null; then

    echo -e "${GREEN}✅ Credentials succesvol gedecrypt!${NC}"
    echo "   Output: $OUTPUT_FILE"
    echo
    echo "Nu kun je de AZURE_CREDENTIALS secret instellen in GitHub:"
    echo "  1. Ga naar je repo → Settings → Secrets → Actions"
    echo "  2. Maak secret 'AZURE_CREDENTIALS' met inhoud van azure-credentials.json"
    echo
    echo -e "${YELLOW}⚠️  Vergeet niet password.txt te verwijderen na gebruik!${NC}"
else
    echo -e "${RED}❌ Decryptie mislukt! Controleer het wachtwoord.${NC}"
    rm -f "$OUTPUT_FILE"
    exit 1
fi

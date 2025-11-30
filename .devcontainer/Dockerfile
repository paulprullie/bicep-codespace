# Gebruik een officiële Microsoft Azure CLI Development Container image
# Let op: Azure CLI image is gebaseerd op Alpine Linux (apk, niet apt-get)
FROM mcr.microsoft.com/azure-cli:latest

# Installeer de Bicep CLI
RUN az bicep install

# Installeer Git (Python is al aanwezig in Azure CLI image)
RUN apk add --no-cache git

# Installeer Python packages voor het test script
RUN pip install --no-cache-dir azure-eventhub azure-identity

# Stel de standaard werkmap in
WORKDIR /workspace

# Start de container als root, de devcontainer zal overschakelen naar een non-root gebruiker (vscode)
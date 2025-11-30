# Gebruik een officiële Microsoft Azure CLI Development Container image
FROM mcr.microsoft.com/azure-cli:latest

# Installeer de Bicep CLI
RUN az bicep install

# Installeer Git, Python en pip
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Installeer Python packages voor het test script
RUN pip3 install --no-cache-dir azure-eventhub azure-identity

# Stel de standaard werkmap in
WORKDIR /workspace

# Start de container als root, de devcontainer zal overschakelen naar een non-root gebruiker (vscode)
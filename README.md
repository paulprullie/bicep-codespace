# 🚀 IaC Workshop: IoT Data Pipeline met Bicep en CI/CD

Welkom bij de hands-on workshop **Infrastructuur als Code (IaC)**!

In deze sessie bouw je een complete **IoT Data Pipeline** in Azure: van event ingestie tot opslag, volledig gedefinieerd met **Bicep** en automatisch gedeployed via **GitHub Actions** of **Azure DevOps**.

## 🎯 Doel van de Workshop

Je leert hoe je:
1. **Modulaire Bicep-templates** schrijft voor herbruikbaarheid
2. **Managed Identity** gebruikt voor veilige authenticatie (geen secrets!)
3. Een **CI/CD-pipeline** opzet voor geautomatiseerde Azure-deployments
4. **Event-driven architectuur** implementeert met Event Hub en Azure Functions

---

## 🏗️ Architectuur

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Azure Resource Group                            │
│                                                                         │
│  ┌─────────────┐      ┌─────────────────┐      ┌─────────────────────┐  │
│  │  INGESTIE   │      │ COMPUTE/PROCESS │      │      OPSLAG         │  │
│  │             │      │                 │      │                     │  │
│  │ ┌─────────┐ │      │ ┌─────────────┐ │      │  Storage Account    │  │
│  │ │ Event   │ │      │ │   Azure     │ │      │  (Blob Storage)     │  │
│  │ │  Hub    │ ├─────►│ │  Function   │ ├─────►│                     │  │
│  │ └─────────┘ │      │ │             │ │      │   iot-data/         │  │
│  │             │      │ │ Event Hub   │ │      │   └── 2025/12/02/14 │  │
│  │   Events    │      │ │ Trigger     │ │      │       └── events    │  │
│  └─────────────┘      │ └─────────────┘ │      └─────────────────────┘  │
│        ▲              │       │         │                               │
│  ┌─────┴─────┐        │  Managed ID     │                               │
│  │  Test     │        │  + Blob Output  │                               │
│  │  Script   │        └─────────────────┘                               │
│  └───────────┘                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🏷️ Azure Naming Convention

Consistente naamgeving is essentieel voor professionele infrastructuur.

| Resource Type | Prefix | Voorbeeld | Beperkingen |
|---------------|--------|-----------|-------------|
| Resource Group | `rg-` | `rg-iot-workshop-jouwinitialen` | 1-90 chars |
| Storage Account | `st` | `stiotworkshop` | **Max 24 chars, geen streepjes!** |
| Event Hub Namespace | `evhns-` | `evhns-iot-workshop` | 6-50 chars |
| Event Hub | - | `iot-events` | Vrije naam binnen namespace |
| Function App | `func-` | `func-iot-workshop` | 2-60 chars |
| App Service Plan | `asp-` | `asp-iot-workshop` | 1-40 chars |
| Application Insights | `appi-` | `appi-iot-workshop` | 1-260 chars |
| Virtual Network | `vnet-` | `vnet-iot-workshop` | 2-64 chars |
| Subnet | `snet-` | `snet-functions` | 1-80 chars |

> 📖 **Bron:** [Azure naming conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations) - Cloud Adoption Framework

**Let op bij Storage Accounts:**
- Maximum 24 karakters
- Alleen lowercase letters en cijfers (geen streepjes!)
- Moet globally unique zijn
- Tip: gebruik `uniqueString(resourceGroup().id)` in Bicep

---

## 🛠️ Voorbereiding: Je Werkomgeving

We gebruiken een **Dev Container** om ervoor te zorgen dat iedereen dezelfde omgeving heeft met alle tools (**Azure CLI**, **Bicep CLI**) geïnstalleerd.

---

### 🐙 Pad A: GitHub

#### Stap 1: Fork de Repository

1. Ga naar de hoofdpagina van deze repository
2. Klik rechtsboven op de knop **"Fork"**
3. Werk voortaan altijd in jouw eigen forked repository

#### Stap 2: Start je Werkomgeving

**Optie 1: GitHub Codespaces (Aanbevolen)**

Dit is de snelste manier om te starten, direct in je browser:

1. Ga naar de hoofdpagina van **jouw forked repository**
2. Klik op de groene knop **`< > Code`**
3. Kies het tabblad **Codespaces** en klik op **"Create codespace on main"**

**Optie 2: Lokale VS Code Dev Container**

1. **Vereisten:** VS Code, Docker (draaiend) en de Dev Containers extensie
2. Kloon jouw forked repository lokaal
3. Open de map in VS Code
4. Klik op **"Reopen in Container"** wanneer VS Code dit vraagt

---

### 🔷 Pad B: Azure DevOps

#### Stap 1: Importeer de Repository

1. Ga naar je Azure DevOps project → **Repos**
2. Klik op **Import repository**
3. Voer de URL van de bron-repository in
4. Klik op **Import**

#### Stap 2: Start je Werkomgeving (Lokale Dev Container)

Azure DevOps heeft geen Codespaces, dus we gebruiken een lokale Dev Container:

1. **Vereisten:** VS Code, Docker (draaiend) en de Dev Containers extensie
2. Kloon de repository vanuit Azure DevOps lokaal
3. Open de map in VS Code
4. Klik op **"Reopen in Container"** wanneer VS Code dit vraagt

---

## 🔑 Azure Login

Open de terminal in je Codespace en log in bij Azure:

```bash
az login
```

> In Codespaces krijg je een device code te zien. Volg de instructies op het scherm om te authenticeren.

---

## 💻 Deel 1: Bicep Infrastructure (~45 min)

### 📁 Bestandsstructuur

De skeleton files staan klaar in `infra/`. Vul de TODO's aan:

```
infra/
├── main.bicep              # Orchestrator - roept modules aan
├── main.bicepparam         # Parameter waarden
└── modules/
    ├── storage.bicep       # Storage Account + Blob container
    ├── eventhub.bicep      # Event Hub namespace + hub
    ├── function.bicep      # Function App + Managed Identity
    └── rbac.bicep          # RBAC role assignments
```

---

### ✅ Resource Group (`main.bicep`)

**Doel:** Container voor alle resources, aangemaakt op subscription scope

```bicep
targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${workloadName}'
  location: location
}
```

> **Let op:** Modules krijgen `scope: resourceGroup` om ze in de juiste resource group te deployen.

---

### ✅ Storage Account (`modules/storage.bicep`)

**Doel:** Blob Storage voor IoT events met virtuele folder structuur

| Property | Waarde | Waarom |
|----------|--------|--------|
| `kind` | `StorageV2` | Nieuwste generation |
| `sku.name` | `Standard_LRS` | Lokaal redundant, goedkoop |
| `accessTier` | `Hot` | Frequent access |
| `allowBlobPublicAccess` | `false` | Security best practice |

> 💡 **Virtuele folders:** Blob namen zoals `2025/12/02/events.json` worden in de Portal als folders weergegeven!

---

### ✅ Event Hub (`modules/eventhub.bicep`)

**Doel:** Ingestie van IoT events

| Resource | Property | Waarde |
|----------|----------|--------|
| Namespace | `sku.name` | `Basic` |
| Namespace | `sku.capacity` | `1` |
| Event Hub | `messageRetentionInDays` | `1` |
| Event Hub | `partitionCount` | `2` |

---

### ✅ Function App (`modules/function.bicep`)

**Doel:** Event processing met Managed Identity

| Property | Waarde | Waarom |
|----------|--------|--------|
| `kind` | `functionapp,linux` | Linux Function App |
| `identity.type` | `SystemAssigned` | **Managed Identity!** |
| `sku.name` | `Y1` | Consumption plan |
| `linuxFxVersion` | `PYTHON\|3.11` | Python runtime |

**Belangrijke App Settings (let op de dubbele underscore!):**
```bicep
appSettings: [
  { name: 'AzureWebJobsStorage__accountName', value: storageAccountName }
  { name: 'FUNCTIONS_EXTENSION_VERSION', value: '~4' }
  { name: 'FUNCTIONS_WORKER_RUNTIME', value: 'python' }
  { name: 'EventHubConnection__fullyQualifiedNamespace', value: eventHubNamespace }
  { name: 'EventHubName', value: eventHubName }
  { name: 'StorageAccountName', value: storageAccountName }
]
```

> ⚠️ **Dubbele underscore `__`** = Managed Identity authenticatie (geen connection string!)

---

### ✅ Main Orchestrator (`main.bicep`)

**Doel:** Alle modules verbinden in de juiste volgorde

```bicep
// Volgorde om circulaire dependencies te voorkomen:
// 1. Storage Account
// 2. Event Hub
// 3. Function App (heeft Storage/EventHub outputs nodig)
// 4. RBAC (heeft Function App principalId nodig)
```

> **Let op de volgorde:** Function App heeft de outputs van Storage en Event Hub nodig. RBAC komt als laatste omdat het de `principalId` van de Function App nodig heeft.

---

### ✅ RBAC Role Assignments (`modules/rbac.bicep`)

**Doel:** Managed Identity toegang geven tot resources

| Rol | Role Definition ID | Toegang tot |
|-----|-------------------|-------------|
| Storage Blob Data Contributor | `ba92f5b4-2d11-453d-a403-e96b0029c9fe` | Blob Storage |
| Event Hubs Data Receiver | `a638d3c7-ab3a-418d-83e6-5f17a39d4fde` | Event Hub |

> **Waarom apart?** RBAC heeft de `principalId` van de Function App nodig, die pas beschikbaar is na deployment van de Function App.

---

### 🧪 Valideren

```bash
# Syntax check
az bicep build --file infra/main.bicep

# What-If (zie wat er gaat gebeuren)
az deployment sub what-if \
  --location westeurope \
  --template-file infra/main.bicep \
  --parameters infra/main.bicepparam
```

> **Let op:** We gebruiken `az deployment sub` omdat de scope op subscription niveau is (de resource group wordt door Bicep aangemaakt).

### 💡 Tips

- RBAC Role Definition IDs staan in de skeleton files
- `uniqueString(resourceGroup().id)` genereert unieke suffix
- Gebruik de [Bicep documentatie](https://learn.microsoft.com/azure/templates/) als referentie

---

## 🔄 Deel 2: CI/CD Pipeline (~45 min)

### 📋 Overzicht

We maken een pipeline die:
1. **Validate** - Bicep syntax check + What-If analyse
2. **Deploy** - Daadwerkelijke deployment naar Azure

---

### 🔐 Azure Credentials voor CI/CD

Voor automatische deployments heeft de pipeline Azure credentials nodig.

**GitHub Actions:**

1. Vraag de trainer om het wachtwoord
2. Decrypt de credentials:
   ```bash
   echo "WACHTWOORD_VAN_TRAINER" > password.txt
   ./scripts/setup-azure-credentials.sh
   ```
3. Ga naar jouw GitHub repo → **Settings** → **Secrets and variables** → **Actions**
4. Maak secret `AZURE_CREDENTIALS` met de inhoud van `azure-credentials.json`

**Azure DevOps:**

1. Ga naar **Project Settings** → **Service connections** → **New**
2. Kies **Azure Resource Manager** → **Service Principal (automatic)**
3. Noem de connectie `Azure-Workshop-SC`
4. Update `azure-pipelines.yml` met deze naam

---

### ✅ Workflow bestand maken

Maak `.github/workflows/deploy.yml`:

```yaml
name: Deploy IoT Infrastructure

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  LOCATION: westeurope

jobs:
  # ═══════════════════════════════════════════════════════════
  # JOB 1: Validatie
  # ═══════════════════════════════════════════════════════════
  validate:
    name: Validate Bicep
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Bicep Lint
        run: az bicep build --file ./infra/main.bicep

      - name: What-If Analysis
        run: |
          az deployment sub what-if \
            --location $LOCATION \
            --template-file ./infra/main.bicep \
            --parameters ./infra/main.bicepparam

  # ═══════════════════════════════════════════════════════════
  # JOB 2: Deploy (alleen op push naar main)
  # ═══════════════════════════════════════════════════════════
  deploy:
    name: Deploy to Azure
    needs: validate
    if: github.event_name == 'push'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Deploy Bicep
        run: |
          az deployment sub create \
            --location $LOCATION \
            --template-file ./infra/main.bicep \
            --parameters ./infra/main.bicepparam
```

---

### ✅ Workflow onderdelen uitgelegd

| Onderdeel | Doel |
|-----------|------|
| `on: push/pull_request` | Trigger bij code wijzigingen |
| `env:` | Environment variabelen (herbruikbaar) |
| `jobs: validate` | Syntax check + What-If |
| `jobs: deploy` | Daadwerkelijke deployment |
| `needs: validate` | Deploy wacht op validate |
| `if: github.event_name == 'push'` | Deploy alleen bij push, niet bij PR |

---

### ✅ What-If begrijpen

What-If toont wat er gaat gebeuren **zonder** te deployen:

| Symbool | Betekenis |
|---------|-----------|
| `+ Create` | Resource wordt aangemaakt |
| `~ Modify` | Resource wordt aangepast |
| `- Delete` | Resource wordt verwijderd |
| `= NoChange` | Resource blijft ongewijzigd |

---

### 🧪 Testen

1. **Commit en push** je wijzigingen:
   ```bash
   git add .
   git commit -m "Add IoT infrastructure"
   git push
   ```

2. Ga naar **Actions** tab in GitHub

3. Bekijk de workflow run:
   - ✅ **validate** job moet slagen
   - ✅ **deploy** job rolt de infra uit

4. Check de **What-If** output in de validate job logs

---

### 💡 Tips

- PR's triggeren alleen `validate` (geen deploy)
- Push naar `main` triggert beide jobs

---

## 🧪 Testen met Event Generator

Na deployment kun je de pipeline testen:

```bash
# Haal connection string op via Azure CLI (pas resource group aan!)
CONNECTION_STRING=$(az eventhubs namespace authorization-rule keys list \
  --resource-group rg-iot-workshop-jouwinitialen \
  --namespace-name evhns-iot-workshop-jouwinitialen \
  --name RootManageSharedAccessKey \
  --query primaryConnectionString -o tsv)

# Verstuur test events
./scripts/send_events.sh --connection-string "$CONNECTION_STRING" --count 10
```

> **PowerShell alternatief:** `.\scripts\send_events.ps1 -ConnectionString $CONNECTION_STRING -Count 10`

Verifieer in de Azure Portal:
1. Open het Storage Account
2. Ga naar **Containers** → **iot-data**
3. Je ziet de folder structuur: `jaar/maand/dag/uur/`

---

## 🏆 Aanvullende Uitdagingen

### 🔒 Uitdaging 1: VNET & Private Endpoints (+15 min)

Voeg netwerk isolatie toe:
- Maak `modules/vnet.bicep` met een VNet en subnets
- Configureer Private Endpoints voor Storage en Event Hub
- Integreer de Function App in het VNet

### 📊 Uitdaging 2: Application Insights (+15 min)

Voeg monitoring toe:
- Maak `modules/monitoring.bicep` met Log Analytics en App Insights
- Koppel App Insights aan de Function App
- Bekijk Live Metrics terwijl je events verstuurt

---

## 📚 Handige Links

- [Bicep Documentatie](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure Verified Modules](https://aka.ms/avm)
- [Event Hub Trigger voor Azure Functions](https://learn.microsoft.com/azure/azure-functions/functions-bindings-event-hubs-trigger)
- [Managed Identity best practices](https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/managed-identity-best-practice-recommendations)

---

**Veel succes en plezier met het bouwen van je IoT Data Pipeline!** 🎉

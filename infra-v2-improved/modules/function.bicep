// =============================================================================
// Azure Function App Module
// =============================================================================
// Serverless compute voor event-driven processing.
// Leest events van Event Hub, verwerkt deze, schrijft naar Storage.
// Gebruikt Managed Identity voor authenticatie (geen secrets nodig!).
//
// Leerpunten:
// - Managed Identity (SystemAssigned)
// - App Service Plan (Consumption tier)
// - App Settings met dubbele underscore notatie
// - Child resources (config)
// =============================================================================

@description('Workload naam')
param workloadName string

@description('Locatie voor resources')
param location string = resourceGroup().location

@description('Event Hub fully qualified namespace (bijv: evhns-xxx.servicebus.windows.net)')
param eventHubNamespace string

@description('Event Hub naam')
param eventHubName string

@description('Storage Account naam')
param storageAccountName string

// TODO: Definieer namen voor App Service Plan en Function App
// Hints:
// - App Service Plan: prefix 'asp-'
// - Function App: prefix 'func-'
// - Gebruik uniqueString voor globale uniekheid

var appServicePlanName = ''  // TODO: Implementeer
var functionAppName = ''     // TODO: Implementeer

// TODO: Maak het App Service Plan (Consumption/Serverless)
// Dit bepaalt de compute resources en pricing voor de Function App.
// Vereisten:
// - SKU: Y1 (Consumption tier = pay-per-execution)
// - Tier: Dynamic
// - Reserved: true (voor Linux)
//
// Vraag: Wat zijn de voor/nadelen van Consumption vs Dedicated plans?
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.web/serverfarms

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  // TODO: Implementeer
}

// TODO: Maak de Function App met SystemAssigned Managed Identity
// Dit is het centraal onderdeel - het voert de Python code uit.
// Vereisten:
// - kind: 'functionapp,linux' (Linux + serverless)
// - identity.type: 'SystemAssigned' (Dit is Managed Identity!)
// - siteConfig.linuxFxVersion: 'PYTHON|3.11'
// - App Settings (zie hints hieronder)
//
// App Settings hints:
// - AzureWebJobsStorage__accountName = storageAccountName
//   (Dubbele underscore = Managed Identity auth, niet connection string!)
// - FUNCTIONS_EXTENSION_VERSION = '~4'
// - FUNCTIONS_WORKER_RUNTIME = 'python'
// - EventHubConnection__fullyQualifiedNamespace = eventHubNamespace
//   (Dubbele underscore = Managed Identity auth!)
// - EventHubName = eventHubName
// - StorageAccountName = storageAccountName
//
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.web/sites
// Vraag: Waarom dubbele underscore in plaats van connection strings?

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  // TODO: Implementeer
  // Let op: Deze resource krijgt automatisch een Managed Identity principalId
  // Deze wordt later gebruikt in rbac.bicep voor rol assignments!
}

// =============================================================================
// OUTPUTS
// =============================================================================

@description('De naam van de Function App')
output functionAppName string = functionApp.name

@description('Principal ID van de Managed Identity (nodig voor RBAC)')
output principalId string = functionApp.identity.principalId

@description('URL van de Function App')
output functionAppUrl string = 'https://${functionApp.properties.defaultHostName}'

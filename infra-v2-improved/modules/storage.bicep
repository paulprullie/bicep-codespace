// =============================================================================
// Storage Account Module
// =============================================================================
// Biedt Blob Storage voor het opslaan van verwerkte IoT events.
// 
// Leerpunten:
// - Variabelen voor resource naming
// - Child resources (blobService, container)
// - Output referencing
// =============================================================================

@description('Workload naam (gebruikt voor resource naming)')
param workloadName string

@description('Locatie voor resources')
param location string = resourceGroup().location

// TODO: Definieer een unieke naam voor het storage account
// Hints:
// - Storage accounts mogen max 24 karakters
// - Geen streepjes, alleen lowercase letters en cijfers
// - Moet globally unique zijn
// - Documentatie: https://learn.microsoft.com/azure/storage/common/storage-account-overview
// - Tip: `uniqueString(resourceGroup().id)` genereert een unieke hash

var storageAccountName = ''  // TODO: Implementeer

// TODO: Maak het Storage Account resource
// Vereisten:
// - Het moet StorageV2 zijn (niet Storage v1)
// - SKU moet Standard_LRS zijn
// - Hot tier voor frequent access
// - Security: HTTPS only, minimale TLS versie, geen public blob access
// 
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts
// Hint: Kijk naar de bestaande main.bicep/eventhub.bicep voor structuur voorbeelden

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  // TODO: Implementeer
}

// TODO: Maak de blob service (child resource van storage account)
// Dit is altijd 'default' als naam
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts/blobservices

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  // TODO: Implementeer
}

// TODO: Maak de 'iot-data' container voor IoT events
// Dit is een child resource van blobService
// Properties moeten publicAccess: 'None' hebben (security!)
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts/blobservices/containers

resource dataContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  // TODO: Implementeer
}

// =============================================================================
// OUTPUTS
// =============================================================================

@description('De naam van het storage account')
output storageAccountName string = storageAccount.name

@description('De ID van het storage account (nodig voor RBAC)')
output storageAccountId string = storageAccount.id

@description('De blob endpoint URL')
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob

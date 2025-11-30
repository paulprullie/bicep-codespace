// =============================================================================
// Storage Account met Blob Container
// =============================================================================
// Dit storage account wordt gebruikt voor het opslaan van IoT events
// Virtuele folders via blob namen: 2025/12/02/14/events.json
// =============================================================================

@description('Naam van het workload (gebruikt voor resource naming)')
param workloadName string

@description('Locatie voor de resources')
param location string = resourceGroup().location

@description('Principal ID van de Function App voor RBAC')
param functionAppPrincipalId string

// -----------------------------------------------------------------------------
// VARIABELEN
// -----------------------------------------------------------------------------

// TODO: Maak een unieke naam voor het storage account
// Tips:
// - Storage account namen moeten globally unique zijn
// - Max 24 karakters, alleen lowercase letters en cijfers
// - Gebruik uniqueString(resourceGroup().id) voor uniekheid
// - Prefix: 'st' (geen streepje bij storage accounts!)
var storageAccountName = 'yourname' // TODO: Pas aan

// -----------------------------------------------------------------------------
// STORAGE ACCOUNT
// -----------------------------------------------------------------------------

// TODO: Maak het Storage Account resource
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts
//
// Vereisten:
// - name: gebruik de variabele storageAccountName (max 24 chars)
// - location: gebruik de parameter
// - sku.name: 'Standard_LRS'
// - kind: 'StorageV2'
// - properties:
//   - accessTier: 'Hot'
//   - minimumTlsVersion: 'TLS1_2'
//   - supportsHttpsTrafficOnly: true
//   - allowBlobPublicAccess: false

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: take(storageAccountName, 24)
  location: location
  // TODO: Voeg sku toe (name: 'Standard_LRS')
  // TODO: Voeg kind toe ('StorageV2')
  // TODO: Voeg properties toe
}

// -----------------------------------------------------------------------------
// BLOB SERVICE & CONTAINER
// -----------------------------------------------------------------------------

// TODO: Maak de blob service configuratie
// Dit is een child resource van het storage account

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

// TODO: Maak de container 'iot-data' voor het opslaan van events
// Dit is een child resource van de blob service
// Zorg dat publicAccess op 'None' staat

resource dataContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'iot-data'
  // TODO: Voeg properties toe met publicAccess: 'None'
}

// -----------------------------------------------------------------------------
// RBAC: Storage Blob Data Contributor
// -----------------------------------------------------------------------------

// TODO: Ken de 'Storage Blob Data Contributor' rol toe aan de Function App
// Dit zorgt ervoor dat de Function App blobs kan schrijven via Managed Identity
//
// Role Definition ID voor Storage Blob Data Contributor:
// ba92f5b4-2d11-453d-a403-e96b0029c9fe
//
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments

resource storageBlobDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, functionAppPrincipalId, 'Storage Blob Data Contributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    principalId: functionAppPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// -----------------------------------------------------------------------------
// OUTPUTS
// -----------------------------------------------------------------------------

@description('De naam van het storage account')
output storageAccountName string = storageAccount.name

@description('De blob endpoint URL')
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob

@description('De resource ID van het storage account')
output storageAccountId string = storageAccount.id

// =============================================================================
// Main Orchestrator voor IoT Data Pipeline
// =============================================================================
// Dit bestand roept alle modules aan en verbindt ze met elkaar
// De volgorde is belangrijk vanwege dependencies!
// =============================================================================

targetScope = 'resourceGroup'

@description('Naam van het workload (wordt gebruikt als prefix voor alle resources)')
param workloadName string

@description('Locatie voor alle resources')
param location string = resourceGroup().location

// =============================================================================
// MODULE AANROEPEN
// =============================================================================
//
// Let op de volgorde en dependencies:
// 1. Function App moet EERST (we hebben de Managed Identity Principal ID nodig)
// 2. Storage en Event Hub kunnen daarna (ze krijgen de Principal ID als parameter)
//
// De Principal ID van de Function App wordt gebruikt om RBAC roles toe te kennen
// zodat de Function App toegang krijgt tot Storage en Event Hub via Managed Identity
//
// =============================================================================

// -----------------------------------------------------------------------------
// STAP 1: Function App (eerst voor Managed Identity)
// -----------------------------------------------------------------------------

// TODO: Roep de function module aan
// Documentatie: https://learn.microsoft.com/azure/azure-resource-manager/bicep/modules
//
// Syntax:
// module <naam> '<pad-naar-module>' = {
//   name: '<deployment-naam>'
//   params: {
//     param1: value1
//     param2: value2
//   }
// }
//
// Parameters die de function module nodig heeft:
// - workloadName: param workloadName
// - location: param location
// - eventHubNamespace: eventHub.outputs.fullyQualifiedNamespace
// - eventHubName: eventHub.outputs.eventHubName
// - storageBlobEndpoint: storage.outputs.blobEndpoint
// - storageAccountName: storage.outputs.storageAccountName

module functionApp 'modules/function.bicep' = {
  name: 'deploy-function-app'
  params: {
    workloadName: workloadName
    location: location
    // TODO: Voeg de overige parameters toe
    // Hint: gebruik outputs van de andere modules
    // eventHubNamespace: eventHub.outputs.???
    // eventHubName: eventHub.outputs.???
    // storageBlobEndpoint: storage.outputs.???
    // storageAccountName: storage.outputs.???
  }
}

// -----------------------------------------------------------------------------
// STAP 2: Storage Account
// -----------------------------------------------------------------------------

// TODO: Roep de storage module aan
//
// Parameters die de storage module nodig heeft:
// - workloadName: param workloadName
// - location: param location
// - functionAppPrincipalId: functionApp.outputs.principalId
//
// Let op: functionAppPrincipalId is nodig voor RBAC!

module storage 'modules/storage.bicep' = {
  name: 'deploy-storage'
  params: {
    workloadName: workloadName
    location: location
    // TODO: Voeg functionAppPrincipalId toe
    // Hint: functionApp.outputs.principalId
  }
}

// -----------------------------------------------------------------------------
// STAP 3: Event Hub
// -----------------------------------------------------------------------------

// TODO: Roep de eventhub module aan
//
// Parameters die de eventhub module nodig heeft:
// - workloadName: param workloadName
// - location: param location
// - functionAppPrincipalId: functionApp.outputs.principalId

module eventHub 'modules/eventhub.bicep' = {
  name: 'deploy-eventhub'
  params: {
    workloadName: workloadName
    location: location
    // TODO: Voeg functionAppPrincipalId toe
  }
}

// =============================================================================
// OUTPUTS
// =============================================================================
// Deze outputs zijn beschikbaar na deployment via:
// az deployment group show --name main --query 'properties.outputs'
// =============================================================================

@description('Naam van de Function App')
output functionAppName string = functionApp.outputs.functionAppName

@description('URL van de Function App')
output functionAppUrl string = functionApp.outputs.functionAppUrl

@description('Event Hub connection string voor test script')
output eventHubConnectionString string = eventHub.outputs.sendConnectionString

@description('Event Hub naam')
output eventHubName string = eventHub.outputs.eventHubName

@description('Storage Account naam')
output storageAccountName string = storage.outputs.storageAccountName

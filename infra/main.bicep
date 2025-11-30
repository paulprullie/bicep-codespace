// =============================================================================
// Main Orchestrator voor IoT Data Pipeline
// =============================================================================
// Dit bestand roept alle modules aan en verbindt ze met elkaar
// De volgorde is belangrijk vanwege dependencies!
// =============================================================================

targetScope = 'subscription'

@description('Naam van het workload (wordt gebruikt als prefix voor alle resources)')
param workloadName string

@description('Locatie voor alle resources')
param location string

// =============================================================================
// RESOURCE GROUP
// =============================================================================

// TODO: Maak de Resource Group aan
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.resources/resourcegroups
//
// Tips:
// - Gebruik de naming convention: rg-<workloadName>
// - location komt uit de parameter

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${workloadName}'
  location: location
}

// =============================================================================
// MODULE AANROEPEN
// =============================================================================
//
// Let op de volgorde (geen circulaire dependencies!):
// 1. Storage Account (resources aanmaken)
// 2. Event Hub (resources aanmaken)
// 3. Function App (heeft Storage en Event Hub info nodig voor app settings)
// 4. RBAC (heeft Function App principalId nodig)
//
// =============================================================================

// -----------------------------------------------------------------------------
// STAP 1: Storage Account
// -----------------------------------------------------------------------------

// TODO: Roep de storage module aan
// Documentatie: https://learn.microsoft.com/azure/azure-resource-manager/bicep/modules

module storage 'modules/storage.bicep' = {
  name: 'deploy-storage'
  scope: resourceGroup
  params: {
    workloadName: workloadName
    location: location
  }
}

// -----------------------------------------------------------------------------
// STAP 2: Event Hub
// -----------------------------------------------------------------------------

// TODO: Roep de eventhub module aan

module eventHub 'modules/eventhub.bicep' = {
  name: 'deploy-eventhub'
  scope: resourceGroup
  params: {
    workloadName: workloadName
    location: location
  }
}

// -----------------------------------------------------------------------------
// STAP 3: Function App
// -----------------------------------------------------------------------------

// TODO: Roep de function module aan
// De Function App heeft de outputs van Storage en Event Hub nodig
//
// Parameters die de function module nodig heeft:
// - workloadName: param workloadName
// - location: param location
// - eventHubNamespace: eventHub.outputs.fullyQualifiedNamespace
// - eventHubName: eventHub.outputs.eventHubName
// - storageAccountName: storage.outputs.storageAccountName

module functionApp 'modules/function.bicep' = {
  name: 'deploy-function-app'
  scope: resourceGroup
  params: {
    workloadName: workloadName
    location: location
    eventHubNamespace: eventHub.outputs.fullyQualifiedNamespace
    eventHubName: eventHub.outputs.eventHubName
    storageAccountName: storage.outputs.storageAccountName
  }
}

// -----------------------------------------------------------------------------
// STAP 4: RBAC Role Assignments
// -----------------------------------------------------------------------------

// TODO: Ken RBAC roles toe zodat de Function App toegang heeft
// Dit moet NA de Function App omdat we de principalId nodig hebben
//
// Storage Blob Data Contributor: ba92f5b4-2d11-453d-a403-e96b0029c9fe
// Event Hubs Data Receiver: a638d3c7-ab3a-418d-83e6-5f17a39d4fde

module rbacAssignments 'modules/rbac.bicep' = {
  name: 'deploy-rbac'
  scope: resourceGroup
  params: {
    functionAppPrincipalId: functionApp.outputs.principalId
    storageAccountName: storage.outputs.storageAccountName
    eventHubNamespaceName: eventHub.outputs.namespaceName
  }
}

// =============================================================================
// OUTPUTS
// =============================================================================
// Deze outputs zijn beschikbaar na deployment via:
// az deployment sub show --name main --query 'properties.outputs'
// =============================================================================

@description('Naam van de Resource Group')
output resourceGroupName string = resourceGroup.name

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

// =============================================================================
// Main Orchestrator voor IoT Data Pipeline
// =============================================================================
// Dit bestand roept alle modules aan en verbindt ze met elkaar.
// Modules worden in een specifieke volgorde gedeployd om afhankelijkheden
// (dependencies) te voorkomen. De outputs van eerder gedeployde modules
// worden gebruikt als inputs voor latere modules.
// =============================================================================

targetScope = 'subscription'

@description('Naam van het workload (wordt gebruikt als prefix voor alle resources)')
param workloadName string

@description('Locatie voor alle resources')
param location string

// =============================================================================
// RESOURCE GROUP
// =============================================================================
// De resource group is een logische container voor alle resources.
// Bicep maakt deze aan op subscription-level scope.

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${workloadName}'
  location: location
}

// =============================================================================
// MODULE AANROEPEN
// =============================================================================
// Volgorde is belangrijk! Modules worden sequentieel gedeployd:
// 1. Storage → 2. Event Hub → 3. Function App → 4. RBAC
//
// Waarom? Omdat Function App de outputs van Storage en Event Hub nodig heeft,
// en RBAC moet na de Function App omdat het de principalId nodig heeft.

// TODO: Implementeer de vier modules hieronder.
// Documentatie: https://learn.microsoft.com/azure/azure-resource-manager/bicep/modules
//
// Tips:
// - Gebruik `scope: resourceGroup` om modules in de juiste RG te deployen
// - Module outputs zijn beschikbaar via: moduleName.outputs.outputName
// - Dependencies kunnen expliciet gemaakt worden met `dependsOn`

module storage 'modules/storage.bicep' = {
  name: 'deploy-storage'
  scope: resourceGroup
  params: {
    workloadName: workloadName
    location: location
  }
}

module eventHub 'modules/eventhub.bicep' = {
  name: 'deploy-eventhub'
  scope: resourceGroup
  params: {
    workloadName: workloadName
    location: location
  }
}

module functionApp 'modules/function.bicep' = {
  name: 'deploy-function-app'
  scope: resourceGroup
  params: {
    workloadName: workloadName
    location: location
    // TODO: Voeg de benodigde parameters toe uit storage en eventHub outputs
  }
}

module rbacAssignments 'modules/rbac.bicep' = {
  name: 'deploy-rbac'
  scope: resourceGroup
  params: {
    // TODO: Voeg de benodigde parameters toe
  }
}

// =============================================================================
// OUTPUTS
// =============================================================================
// Deze outputs worden weergegeven na deployment en kunnen via scripts gebruikt worden.
// Bijv: az deployment sub show --name main --query 'properties.outputs'

@description('Naam van de Resource Group')
output resourceGroupName string = resourceGroup.name

@description('Naam van de Function App')
output functionAppName string = functionApp.outputs.functionAppName

@description('URL van de Function App')
output functionAppUrl string = functionApp.outputs.functionAppUrl

@description('Event Hub namespace naam')
output eventHubNamespace string = eventHub.outputs.namespaceName

@description('Storage Account naam')
output storageAccountName string = storage.outputs.storageAccountName

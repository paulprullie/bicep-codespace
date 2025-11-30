// =============================================================================
// RBAC Role Assignments
// =============================================================================
// Dit bestand kent de benodigde RBAC roles toe aan de Function App
// zodat deze via Managed Identity toegang heeft tot Storage en Event Hub
// =============================================================================

@description('Principal ID van de Function App Managed Identity')
param functionAppPrincipalId string

@description('Naam van het Storage Account')
param storageAccountName string

@description('Naam van de Event Hub Namespace')
param eventHubNamespaceName string

// -----------------------------------------------------------------------------
// BESTAANDE RESOURCES REFEREREN
// -----------------------------------------------------------------------------

// TODO: Refereer naar het bestaande Storage Account
// Syntax: resource <naam> 'type@version' existing = { name: ... }

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

// TODO: Refereer naar de bestaande Event Hub Namespace

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' existing = {
  name: eventHubNamespaceName
}

// -----------------------------------------------------------------------------
// RBAC: Storage Blob Data Contributor
// -----------------------------------------------------------------------------

// TODO: Ken de 'Storage Blob Data Contributor' rol toe
// Role Definition ID: ba92f5b4-2d11-453d-a403-e96b0029c9fe
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments

resource storageBlobDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, functionAppPrincipalId, 'Storage Blob Data Contributor')
  scope: storageAccount
  properties: {
    // TODO: Voeg roleDefinitionId toe
    // Hint: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '<role-id>')
    principalId: functionAppPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// -----------------------------------------------------------------------------
// RBAC: Azure Event Hubs Data Receiver
// -----------------------------------------------------------------------------

// TODO: Ken de 'Azure Event Hubs Data Receiver' rol toe
// Role Definition ID: a638d3c7-ab3a-418d-83e6-5f17a39d4fde

resource eventHubDataReceiver 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(eventHubNamespace.id, functionAppPrincipalId, 'Event Hubs Data Receiver')
  scope: eventHubNamespace
  properties: {
    // TODO: Voeg roleDefinitionId toe
    principalId: functionAppPrincipalId
    principalType: 'ServicePrincipal'
  }
}

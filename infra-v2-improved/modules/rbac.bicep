// =============================================================================
// RBAC (Role-Based Access Control) Module
// =============================================================================
// Geeft de Function App (via Managed Identity) rechten om:
// - Data naar Blob Storage te schrijven
// - Events van Event Hub te lezen
//
// Dit moet NADAT de Function App is aangemaakt, omdat we de principalId nodig hebben!
//
// Leerpunten:
// - Reference naar bestaande resources
// - Role Assignments
// - Role Definition IDs
// =============================================================================

@description('Principal ID van de Function App Managed Identity')
param functionAppPrincipalId string

@description('Naam van het Storage Account')
param storageAccountName string

@description('Naam van de Event Hub Namespace')
param eventHubNamespaceName string

// TODO: Refereer naar het BESTAANDE Storage Account resource
// Dit bestand maakt de storage account NIET aan, maar verwijst ernaar
// (Dit bestand wordt namelijk als laatste gedeployd)
// Syntax: resource <naam> '<type>@<version>' existing = { name: ... }
//
// Documentatie: https://learn.microsoft.com/azure/azure-resource-manager/bicep/existing-resources

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  // TODO: Implementeer
}

// TODO: Refereer naar het BESTAANDE Event Hub Namespace

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' existing = {
  // TODO: Implementeer
}

// =============================================================================
// RBAC ROLE 1: Storage Blob Data Contributor
// =============================================================================
// Geeft rechten om blobs te lezen EN schrijven naar Storage Account
// Role Definition ID: ba92f5b4-2d11-453d-a403-e96b0029c9fe
//
// TODO: Maak de role assignment
// Vereisten:
// - name: Unieke ID (gebruik `guid()` voor deterministische generatie)
// - scope: Het storage account
// - roleDefinitionId: subscriptionResourceId(...) met de role ID
// - principalId: De Managed Identity van de Function App
// - principalType: 'ServicePrincipal'
//
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
// Vraag: Waarom moet dit resource APART zijn en niet in de Function App?
// Antwoord: RBAC moet NA de Function App (omdat we de principalId nodig hebben)

resource storageBlobDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  // TODO: Implementeer
}

// =============================================================================
// RBAC ROLE 2: Azure Event Hubs Data Receiver
// =============================================================================
// Geeft rechten om events van Event Hub te LEZEN (ontvangen)
// Role Definition ID: a638d3c7-ab3a-418d-83e6-5f17a39d4fde
//
// TODO: Maak de role assignment (structuur is hetzelfde als hierboven)
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments

resource eventHubDataReceiver 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  // TODO: Implementeer
}

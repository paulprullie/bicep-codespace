// =============================================================================
// Event Hub Namespace en Hub voor IoT Event Ingestie
// =============================================================================
// Ontvangt events van externe bronnen (sensoren, scripts, etc.)
// De Function App leest events via een Event Hub Trigger
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

// TODO: Definieer de resource namen volgens de naming convention
// - Event Hub Namespace prefix: 'evhns-'
// - Event Hub naam: 'iot-events'
var eventHubNamespaceName = 'yourname' // TODO: Pas aan (gebruik evhns- prefix)
var eventHubName = 'iot-events'

// -----------------------------------------------------------------------------
// EVENT HUB NAMESPACE
// -----------------------------------------------------------------------------

// TODO: Maak de Event Hub Namespace
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.eventhub/namespaces
//
// Vereisten:
// - name: gebruik de variabele eventHubNamespaceName
// - location: gebruik de parameter
// - sku:
//   - name: 'Basic' (voldoende voor workshop, Standard voor productie)
//   - tier: 'Basic'
//   - capacity: 1
// - properties:
//   - minimumTlsVersion: '1.2'
//   - publicNetworkAccess: 'Enabled'

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: eventHubNamespaceName
  location: location
  // TODO: Voeg sku toe
  // TODO: Voeg properties toe
}

// -----------------------------------------------------------------------------
// EVENT HUB
// -----------------------------------------------------------------------------

// TODO: Maak de Event Hub binnen de namespace
// Dit is een child resource van de namespace
//
// Vereisten:
// - messageRetentionInDays: 1 (Basic tier maximum)
// - partitionCount: 2

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  name: eventHubName
  // TODO: Voeg properties toe
}

// -----------------------------------------------------------------------------
// CONSUMER GROUP
// -----------------------------------------------------------------------------

// TODO: Maak een consumer group voor de Function App
// Consumer groups zorgen ervoor dat meerdere consumers onafhankelijk kunnen lezen
// Naam: 'function-consumer'

resource consumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2024-01-01' = {
  parent: eventHub
  name: 'function-consumer'
}

// -----------------------------------------------------------------------------
// RBAC: Event Hubs Data Receiver
// -----------------------------------------------------------------------------

// TODO: Ken de 'Azure Event Hubs Data Receiver' rol toe aan de Function App
// Dit zorgt ervoor dat de Function App events kan lezen via Managed Identity
//
// Role Definition ID voor Azure Event Hubs Data Receiver:
// a638d3c7-ab3a-418d-83e6-5f17a39d4fde

resource eventHubDataReceiver 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(eventHubNamespace.id, functionAppPrincipalId, 'Event Hubs Data Receiver')
  scope: eventHubNamespace
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a638d3c7-ab3a-418d-83e6-5f17a39d4fde')
    principalId: functionAppPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// -----------------------------------------------------------------------------
// SHARED ACCESS POLICY (voor test script)
// -----------------------------------------------------------------------------

// Deze policy wordt gebruikt door het test script om events te versturen
// In productie zou je hier ook Managed Identity voor gebruiken

resource sendPolicy 'Microsoft.EventHub/namespaces/authorizationRules@2024-01-01' = {
  parent: eventHubNamespace
  name: 'SendPolicy'
  properties: {
    rights: [
      'Send'
    ]
  }
}

// -----------------------------------------------------------------------------
// OUTPUTS
// -----------------------------------------------------------------------------

@description('De naam van de Event Hub namespace')
output namespaceName string = eventHubNamespace.name

@description('De naam van de Event Hub')
output eventHubName string = eventHub.name

@description('De fully qualified namespace voor Managed Identity authenticatie')
output fullyQualifiedNamespace string = '${eventHubNamespace.name}.servicebus.windows.net'

@description('Connection string voor het test script (alleen Send rechten)')
output sendConnectionString string = sendPolicy.listKeys().primaryConnectionString

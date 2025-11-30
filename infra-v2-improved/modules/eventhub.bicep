// =============================================================================
// Event Hub Module
// =============================================================================
// Biedt event ingestie voor IoT sensoren en devices.
// De Function App leest events via een Event Hub Trigger.
//
// Leerpunten:
// - SKU/tier configuratie
// - Child resources in parent-child relatie
// - Consumer groups voor onafhankelijke readers
// =============================================================================

@description('Workload naam (gebruikt voor resource naming)')
param workloadName string

@description('Locatie voor resources')
param location string = resourceGroup().location

// TODO: Definieer de Event Hub namespace naam
// Hints:
// - Gebruik prefix 'evhns-'
// - Moet unique zijn (combineer met workloadName en uniqueString)
// - Moet tussen 6-50 karakters zijn
// - Documentatie: https://learn.microsoft.com/azure/event-hubs/event-hubs-quotas

var eventHubNamespaceName = ''  // TODO: Implementeer
var eventHubName = 'iot-events'

// TODO: Maak de Event Hub Namespace resource
// Vereisten:
// - SKU: Basic tier (voldoende voor workshop)
// - Capacity: 1
// - Security: TLS 1.2, public network enabled (voor workshop)
//
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.eventhub/namespaces
// Vraag jezelf af: Wat zijn SKU tiers en wat bepalen ze?

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  // TODO: Implementeer
}

// TODO: Maak de Event Hub binnen de namespace (child resource)
// Vereisten:
// - messageRetentionInDays: Wat is het maximum voor Basic tier?
// - partitionCount: Hoeveel partities voor parallelle verwerking?
//
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.eventhub/namespaces/eventhubs
// Hint: Lees de documentatie om te begrijpen wat deze properties doen

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  // TODO: Implementeer
}

// TODO: Maak een consumer group voor de Function App
// Wat is een consumer group en waarom nodig?
// Documentatie: https://learn.microsoft.com/azure/event-hubs/event-hubs-features#consumer-groups

resource consumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2024-01-01' = {
  parent: eventHub
  name: 'function-consumer'
}

// TODO: Maak een SharedAccessPolicy voor het test script
// Dit geeft het script rechten om events te VERSTUREN (niet ontvangen)
// In productie zou je Managed Identity gebruiken (geen connection strings!)
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.eventhub/namespaces/authorizationrules

resource sendPolicy 'Microsoft.EventHub/namespaces/authorizationRules@2024-01-01' = {
  parent: eventHubNamespace
  name: 'SendPolicy'
  // TODO: Implementeer (properties met rights: ['Send'])
}

// =============================================================================
// OUTPUTS
// =============================================================================

@description('De naam van de Event Hub namespace')
output namespaceName string = eventHubNamespace.name

@description('De naam van de Event Hub')
output eventHubName string = eventHub.name

@description('Fully qualified namespace voor Managed Identity auth')
output fullyQualifiedNamespace string = '${eventHubNamespace.name}.servicebus.windows.net'

@secure()
@description('Connection string voor het test script (only Send rights)')
output sendConnectionString string = sendPolicy.listKeys().primaryConnectionString

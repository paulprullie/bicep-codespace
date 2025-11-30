// =============================================================================
// Azure Function App met Managed Identity
// =============================================================================
// Verwerkt Event Hub events en schrijft naar Storage Account
// Gebruikt Managed Identity voor authenticatie - geen secrets nodig!
// =============================================================================

@description('Naam van het workload (gebruikt voor resource naming)')
param workloadName string

@description('Locatie voor de resources')
param location string = resourceGroup().location

@description('Event Hub fully qualified namespace (bijv: evhns-xxx.servicebus.windows.net)')
param eventHubNamespace string

@description('Event Hub naam')
param eventHubName string

@description('Storage Account naam')
param storageAccountName string

// -----------------------------------------------------------------------------
// VARIABELEN
// -----------------------------------------------------------------------------

// TODO: Definieer de resource namen volgens de naming convention
// - App Service Plan prefix: 'asp-'
// - Function App prefix: 'func-'
var appServicePlanName = 'asp-${workloadName}-${uniqueString(resourceGroup().id)}'
var functionAppName = 'func-${workloadName}-${uniqueString(resourceGroup().id)}'

// -----------------------------------------------------------------------------
// APP SERVICE PLAN (Consumption)
// -----------------------------------------------------------------------------

// TODO: Maak het App Service Plan (Consumption/Serverless)
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.web/serverfarms
//
// Vereisten:
// - name: gebruik de variabele appServicePlanName
// - location: gebruik de parameter
// - sku:
//   - name: 'Y1' (Consumption plan)
//   - tier: 'Dynamic'
// - properties:
//   - reserved: true (voor Linux)

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}

// -----------------------------------------------------------------------------
// FUNCTION APP
// -----------------------------------------------------------------------------

// TODO: Maak de Function App met System Assigned Managed Identity
// Documentatie: https://learn.microsoft.com/azure/templates/microsoft.web/sites
//
// Vereisten:
// - name: gebruik de variabele functionAppName
// - location: gebruik de parameter
// - kind: 'functionapp,linux'
// - identity:
//   - type: 'SystemAssigned'  <-- Dit is de Managed Identity!
// - properties:
//   - serverFarmId: appServicePlan.id
//   - httpsOnly: true
//   - siteConfig: (zie hieronder)

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
      pythonVersion: '3.11'

      // TODO: Voeg appSettings toe
      // Dit zijn de environment variables voor de Function App
      //
      // Belangrijke settings:
      // 1. AzureWebJobsStorage__accountName = storageAccountName
      //    (Let op de dubbele underscore! Dit is voor Managed Identity)
      //
      // 2. FUNCTIONS_EXTENSION_VERSION = '~4'
      //
      // 3. FUNCTIONS_WORKER_RUNTIME = 'python'
      //
      // 4. EventHubConnection__fullyQualifiedNamespace = eventHubNamespace
      //    (Dubbele underscore voor Managed Identity!)
      //
      // 5. EventHubName = eventHubName
      //
      // 6. StorageAccountName = storageAccountName

      appSettings: [
        { name: 'AzureWebJobsStorage__accountName', value: storageAccountName }
        { name: 'FUNCTIONS_EXTENSION_VERSION', value: '~4' }
        { name: 'FUNCTIONS_WORKER_RUNTIME', value: 'python' }
        { name: 'EventHubConnection__fullyQualifiedNamespace', value: eventHubNamespace }
        { name: 'EventHubName', value: eventHubName }
        { name: 'StorageAccountName', value: storageAccountName }
      ]
    }
  }
}

// -----------------------------------------------------------------------------
// OUTPUTS
// -----------------------------------------------------------------------------

@description('De naam van de Function App')
output functionAppName string = functionApp.name

@description('De Principal ID van de Managed Identity - gebruik dit voor RBAC!')
output principalId string = functionApp.identity.principalId

@description('De URL van de Function App')
output functionAppUrl string = 'https://${functionApp.properties.defaultHostName}'

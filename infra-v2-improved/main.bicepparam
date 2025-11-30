using './main.bicep'

// =============================================================================
// Parameter Values
// =============================================================================
// Pas deze waarden aan voor jouw deployment.

// Workload naam wordt gebruikt als prefix voor alle resources.
// Voeg je initialen toe voor uniekheid (bijv: 'iot-workshop-jd')
param workloadName = 'iot-workshop-jouwinitialen'

// West Europe is dichtbij en heeft alle services
param location = 'westeurope'

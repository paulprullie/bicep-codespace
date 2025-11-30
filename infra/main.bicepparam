using './main.bicep'

// =============================================================================
// Parameter Values
// =============================================================================
// Pas deze waarden aan voor jouw deployment
// =============================================================================

// De workload naam wordt gebruikt als prefix voor alle resources
// BELANGRIJK: Voeg je initialen toe voor een unieke naam!
// Voorbeeld: 'iot-workshop-jd' voor Jan de Vries
param workloadName = 'iot-workshop-jouwinitialen'

// West Europe is dichtbij en heeft alle services
param location = 'westeurope'

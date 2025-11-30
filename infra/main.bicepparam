using './main.bicep'

// =============================================================================
// Parameter Values
// =============================================================================
// Pas deze waarden aan voor jouw deployment
// =============================================================================

// De workload naam wordt gebruikt als prefix voor alle resources
// Kies iets unieks, bijvoorbeeld je naam of studentnummer
param workloadName = 'iot-workshop'

// West Europe is dichtbij en heeft alle services
param location = 'westeurope'

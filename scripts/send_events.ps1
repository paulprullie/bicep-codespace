<#
.SYNOPSIS
    IoT Event Generator Script (PowerShell)

.DESCRIPTION
    Stuurt test events naar Azure Event Hub via REST API.
    Geen Python of SDK nodig - alleen PowerShell!

.PARAMETER ConnectionString
    Event Hub connection string (verplicht)

.PARAMETER EventHubName
    Naam van de Event Hub (default: iot-events)

.PARAMETER Count
    Aantal events om te versturen (default: 10)

.EXAMPLE
    # Met connection string parameter
    .\send_events.ps1 -ConnectionString "<connection_string>" -Count 10

.EXAMPLE
    # Connection string ophalen via Azure CLI
    $connStr = az eventhubs namespace authorization-rule keys list `
        --resource-group rg-iot-workshop `
        --namespace-name evhns-iot-workshop `
        --name RootManageSharedAccessKey `
        --query primaryConnectionString -o tsv
    .\send_events.ps1 -ConnectionString $connStr -EventHubName iot-events -Count 100
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ConnectionString,

    [Parameter(Mandatory = $false)]
    [string]$EventHubName = "iot-events",

    [Parameter(Mandatory = $false)]
    [int]$Count = 10
)

# Kleuren voor output
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }
function Write-Warning { param($Message) Write-Host $Message -ForegroundColor Yellow }

# Parse connection string
function Parse-ConnectionString {
    param([string]$ConnStr)

    $result = @{}

    # Endpoint=sb://<namespace>.servicebus.windows.net/;SharedAccessKeyName=<name>;SharedAccessKey=<key>
    if ($ConnStr -match "Endpoint=sb://([^.]+)\.") {
        $result.Namespace = $Matches[1]
    }
    if ($ConnStr -match "SharedAccessKeyName=([^;]+)") {
        $result.KeyName = $Matches[1]
    }
    if ($ConnStr -match "SharedAccessKey=([^;]+)") {
        $result.Key = $Matches[1]
    }

    if (-not $result.Namespace -or -not $result.KeyName -or -not $result.Key) {
        throw "Kon connection string niet parsen"
    }

    return $result
}

# Genereer SAS token
function New-SasToken {
    param(
        [string]$ResourceUri,
        [string]$KeyName,
        [string]$Key,
        [int]$ExpirySeconds = 3600
    )

    $expiry = [DateTimeOffset]::UtcNow.AddSeconds($ExpirySeconds).ToUnixTimeSeconds()
    $encodedUri = [System.Web.HttpUtility]::UrlEncode($ResourceUri)

    $stringToSign = "$encodedUri`n$expiry"
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [Text.Encoding]::UTF8.GetBytes($Key)
    $signature = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($stringToSign))
    $encodedSignature = [System.Web.HttpUtility]::UrlEncode([Convert]::ToBase64String($signature))

    return "SharedAccessSignature sr=$encodedUri&sig=$encodedSignature&se=$expiry&skn=$KeyName"
}

# Genereer random IoT event
function New-IoTEvent {
    $deviceNum = Get-Random -Minimum 1 -Maximum 11
    $deviceId = "sensor-{0:D3}" -f $deviceNum
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $locations = @("Amsterdam", "Rotterdam", "Utrecht", "Eindhoven")
    $location = $locations | Get-Random

    $event = @{
        device_id = $deviceId
        timestamp = $timestamp
        location = $location
        measurements = @{
            temperature = [Math]::Round((Get-Random -Minimum 150 -Maximum 300) / 10.0, 2)
            humidity = [Math]::Round((Get-Random -Minimum 300 -Maximum 800) / 10.0, 2)
            pressure = [Math]::Round((Get-Random -Minimum 10000 -Maximum 10300) / 10.0, 2)
            co2_ppm = Get-Random -Minimum 400 -Maximum 1200
        }
        battery_level = [Math]::Round((Get-Random -Minimum 200 -Maximum 1000) / 10.0, 1)
        signal_strength = Get-Random -Minimum -90 -Maximum -30
    }

    return $event | ConvertTo-Json -Depth 3 -Compress
}

# Main
Add-Type -AssemblyName System.Web

Write-Host ""
Write-Success "IoT Event Generator (PowerShell)"
Write-Host "========================================"
Write-Host ""

try {
    $config = Parse-ConnectionString -ConnStr $ConnectionString
}
catch {
    Write-Error "Fout: $_"
    exit 1
}

$uri = "https://$($config.Namespace).servicebus.windows.net/$EventHubName"

Write-Host "Namespace:  $($config.Namespace)"
Write-Host "Event Hub:  $EventHubName"
Write-Host "Events:     $Count"
Write-Host ""

# Genereer SAS token
$sasToken = New-SasToken -ResourceUri $uri -KeyName $config.KeyName -Key $config.Key

Write-Success "Start met versturen van events..."
Write-Host ""

$sent = 0
$failed = 0

$headers = @{
    "Authorization" = $sasToken
    "Content-Type" = "application/json"
}

for ($i = 1; $i -le $Count; $i++) {
    $event = New-IoTEvent

    try {
        $response = Invoke-WebRequest `
            -Uri "$uri/messages?api-version=2014-01" `
            -Method POST `
            -Headers $headers `
            -Body $event `
            -UseBasicParsing `
            -ErrorAction Stop

        if ($response.StatusCode -eq 201) {
            $sent++
            Write-Host "  [" -NoNewline
            Write-Host "OK" -ForegroundColor Green -NoNewline
            Write-Host "] Event $i/$Count verstuurd"
        }
    }
    catch {
        $failed++
        Write-Host "  [" -NoNewline
        Write-Host "FOUT" -ForegroundColor Red -NoNewline
        Write-Host "] Event $i/$Count mislukt: $($_.Exception.Message)"
    }

    # Kleine pauze om throttling te voorkomen
    Start-Sleep -Milliseconds 100
}

Write-Host ""
Write-Host "========================================"
Write-Host "Verstuurd: " -NoNewline
Write-Success "$sent events"
if ($failed -gt 0) {
    Write-Host "Mislukt:   " -NoNewline
    Write-Error "$failed events"
}
Write-Host ""

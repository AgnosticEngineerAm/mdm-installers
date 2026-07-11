#Requires -RunAsAdministrator
# Datadog Agent Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$MsiUrl = "PASTE_YOUR_DATADOG_AGENT_MSI_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-datadog-agent-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Datadog Agent install."

$TempDir = New-TempDir
$MsiPath = Join-Path $TempDir "datadog-agent.msi"

try {
    Get-RemoteFile -Url $MsiUrl -Destination $MsiPath -Label "Datadog Agent MSI"
    Install-Msi -MsiPath $MsiPath
    Write-Log "SUCCESS: Datadog Agent installed."
} finally {
    Remove-TempDir -Path $TempDir
}

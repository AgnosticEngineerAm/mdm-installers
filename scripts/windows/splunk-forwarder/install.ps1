#Requires -RunAsAdministrator
# Splunk Universal Forwarder Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$MsiUrl = "PASTE_YOUR_SPLUNK_FORWARDER_MSI_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-splunk-forwarder-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Splunk Universal Forwarder install."

$TempDir = New-TempDir
$MsiPath = Join-Path $TempDir "splunk-forwarder.msi"

try {
    Get-RemoteFile -Url $MsiUrl -Destination $MsiPath -Label "Splunk Universal Forwarder MSI"
    Install-Msi -MsiPath $MsiPath
    Write-Log "SUCCESS: Splunk Universal Forwarder installed."
} finally {
    Remove-TempDir -Path $TempDir
}

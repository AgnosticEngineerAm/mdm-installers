#Requires -RunAsAdministrator
# Zscaler Client Connector Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$MsiUrl = "PASTE_YOUR_ZSCALER_MSI_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-zscaler-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Zscaler Client Connector install."

$TempDir = New-TempDir
$MsiPath = Join-Path $TempDir "zscaler.msi"

try {
    Get-RemoteFile -Url $MsiUrl -Destination $MsiPath -Label "Zscaler Client Connector MSI"
    Install-Msi -MsiPath $MsiPath
    Write-Log "SUCCESS: Zscaler Client Connector installed."
} finally {
    Remove-TempDir -Path $TempDir
}

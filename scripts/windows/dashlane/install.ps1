#Requires -RunAsAdministrator
# Dashlane Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$MsiUrl = "PASTE_YOUR_DASHLANE_MSI_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-dashlane-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Dashlane install."

$TempDir = New-TempDir
$MsiPath = Join-Path $TempDir "dashlane.msi"

try {
    Get-RemoteFile -Url $MsiUrl -Destination $MsiPath -Label "Dashlane MSI"
    Install-Msi -MsiPath $MsiPath
    Write-Log "SUCCESS: Dashlane installed."
} finally {
    Remove-TempDir -Path $TempDir
}

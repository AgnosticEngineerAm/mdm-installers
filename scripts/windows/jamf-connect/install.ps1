#Requires -RunAsAdministrator
# Jamf Connect Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$MsiUrl = "PASTE_YOUR_JAMF_CONNECT_MSI_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-jamf-connect-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Jamf Connect install."

$TempDir = New-TempDir
$MsiPath = Join-Path $TempDir "jamf-connect.msi"

try {
    Get-RemoteFile -Url $MsiUrl -Destination $MsiPath -Label "Jamf Connect MSI"
    Install-Msi -MsiPath $MsiPath
    Write-Log "SUCCESS: Jamf Connect installed."
} finally {
    Remove-TempDir -Path $TempDir
}

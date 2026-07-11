#Requires -RunAsAdministrator
# Cisco Secure Client Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$MsiUrl = "PASTE_YOUR_CISCO_SECURE_CLIENT_MSI_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-cisco-secure-client-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Cisco Secure Client install."

$TempDir = New-TempDir
$MsiPath = Join-Path $TempDir "cisco-secure-client.msi"

try {
    Get-RemoteFile -Url $MsiUrl -Destination $MsiPath -Label "Cisco Secure Client MSI"
    Install-Msi -MsiPath $MsiPath
    Write-Log "SUCCESS: Cisco Secure Client installed."
} finally {
    Remove-TempDir -Path $TempDir
}

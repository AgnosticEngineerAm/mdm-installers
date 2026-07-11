#Requires -RunAsAdministrator
# Cisco Webex Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$MsiUrl = "PASTE_YOUR_WEBEX_MSI_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-webex-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Cisco Webex install."

$TempDir = New-TempDir
$MsiPath = Join-Path $TempDir "webex.msi"

try {
    Get-RemoteFile -Url $MsiUrl -Destination $MsiPath -Label "Cisco Webex MSI"
    Install-Msi -MsiPath $MsiPath
    Write-Log "SUCCESS: Cisco Webex installed."
} finally {
    Remove-TempDir -Path $TempDir
}

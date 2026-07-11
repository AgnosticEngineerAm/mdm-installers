#Requires -RunAsAdministrator
# RingCentral Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$MsiUrl = "PASTE_YOUR_RINGCENTRAL_MSI_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-ringcentral-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting RingCentral install."

$TempDir = New-TempDir
$MsiPath = Join-Path $TempDir "ringcentral.msi"

try {
    Get-RemoteFile -Url $MsiUrl -Destination $MsiPath -Label "RingCentral MSI"
    Install-Msi -MsiPath $MsiPath
    Write-Log "SUCCESS: RingCentral installed."
} finally {
    Remove-TempDir -Path $TempDir
}

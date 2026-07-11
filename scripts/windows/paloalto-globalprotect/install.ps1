#Requires -RunAsAdministrator
# GlobalProtect Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$MsiUrl = "PASTE_YOUR_PALOALTO_GLOBALPROTECT_MSI_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-paloalto-globalprotect-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting GlobalProtect install."

$TempDir = New-TempDir
$MsiPath = Join-Path $TempDir "paloalto-globalprotect.msi"

try {
    Get-RemoteFile -Url $MsiUrl -Destination $MsiPath -Label "GlobalProtect MSI"
    Install-Msi -MsiPath $MsiPath
    Write-Log "SUCCESS: GlobalProtect installed."
} finally {
    Remove-TempDir -Path $TempDir
}

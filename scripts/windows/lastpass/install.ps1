#Requires -RunAsAdministrator
# LastPass Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$MsiUrl = "PASTE_YOUR_LASTPASS_MSI_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-lastpass-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting LastPass install."

$TempDir = New-TempDir
$MsiPath = Join-Path $TempDir "lastpass.msi"

try {
    Get-RemoteFile -Url $MsiUrl -Destination $MsiPath -Label "LastPass MSI"
    Install-Msi -MsiPath $MsiPath
    Write-Log "SUCCESS: LastPass installed."
} finally {
    Remove-TempDir -Path $TempDir
}

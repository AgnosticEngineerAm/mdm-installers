#Requires -RunAsAdministrator
# Bitwarden Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$ExeUrl = "PASTE_YOUR_BITWARDEN_EXE_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-bitwarden-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Bitwarden install."

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "bitwarden.exe"

try {
    Get-RemoteFile -Url $ExeUrl -Destination $ExePath -Label "Bitwarden EXE"
    Install-Exe -ExePath $ExePath -Arguments @("/S", "/quiet", "/silent")
    Write-Log "SUCCESS: Bitwarden installed."
} finally {
    Remove-TempDir -Path $TempDir
}

#Requires -RunAsAdministrator
# Grammarly Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$ExeUrl = "PASTE_YOUR_GRAMMARLY_EXE_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-grammarly-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Grammarly install."

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "grammarly.exe"

try {
    Get-RemoteFile -Url $ExeUrl -Destination $ExePath -Label "Grammarly EXE"
    Install-Exe -ExePath $ExePath -Arguments @("/S", "/quiet", "/silent")
    Write-Log "SUCCESS: Grammarly installed."
} finally {
    Remove-TempDir -Path $TempDir
}

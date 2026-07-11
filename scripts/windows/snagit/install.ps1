#Requires -RunAsAdministrator
# Snagit Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$ExeUrl = "PASTE_YOUR_SNAGIT_EXE_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-snagit-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Snagit install."

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "snagit.exe"

try {
    Get-RemoteFile -Url $ExeUrl -Destination $ExePath -Label "Snagit EXE"
    Install-Exe -ExePath $ExePath -Arguments @("/S", "/quiet", "/silent")
    Write-Log "SUCCESS: Snagit installed."
} finally {
    Remove-TempDir -Path $TempDir
}

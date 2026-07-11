#Requires -RunAsAdministrator
# Camtasia Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$ExeUrl = "PASTE_YOUR_CAMTASIA_EXE_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-camtasia-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Camtasia install."

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "camtasia.exe"

try {
    Get-RemoteFile -Url $ExeUrl -Destination $ExePath -Label "Camtasia EXE"
    Install-Exe -ExePath $ExePath -Arguments @("/S", "/quiet", "/silent")
    Write-Log "SUCCESS: Camtasia installed."
} finally {
    Remove-TempDir -Path $TempDir
}

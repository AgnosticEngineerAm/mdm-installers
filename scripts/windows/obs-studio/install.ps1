#Requires -RunAsAdministrator
# OBS Studio Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$ExeUrl = "PASTE_YOUR_OBS_STUDIO_EXE_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-obs-studio-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting OBS Studio install."

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "obs-studio.exe"

try {
    Get-RemoteFile -Url $ExeUrl -Destination $ExePath -Label "OBS Studio EXE"
    Install-Exe -ExePath $ExePath -Arguments @("/S", "/quiet", "/silent")
    Write-Log "SUCCESS: OBS Studio installed."
} finally {
    Remove-TempDir -Path $TempDir
}

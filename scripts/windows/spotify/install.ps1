#Requires -RunAsAdministrator
# Spotify Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$ExeUrl = "PASTE_YOUR_SPOTIFY_EXE_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-spotify-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Spotify install."

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "spotify.exe"

try {
    Get-RemoteFile -Url $ExeUrl -Destination $ExePath -Label "Spotify EXE"
    Install-Exe -ExePath $ExePath -Arguments @("/S", "/quiet", "/silent")
    Write-Log "SUCCESS: Spotify installed."
} finally {
    Remove-TempDir -Path $TempDir
}

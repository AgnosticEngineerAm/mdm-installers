#Requires -RunAsAdministrator
# Docker Compose Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$ExeUrl = "PASTE_YOUR_DOCKER_COMPOSE_EXE_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-docker-compose-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Docker Compose install."

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "docker-compose.exe"

try {
    Get-RemoteFile -Url $ExeUrl -Destination $ExePath -Label "Docker Compose EXE"
    Install-Exe -ExePath $ExePath -Arguments @("/S", "/quiet", "/silent")
    Write-Log "SUCCESS: Docker Compose installed."
} finally {
    Remove-TempDir -Path $TempDir
}

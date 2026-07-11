#Requires -RunAsAdministrator
# Tailscale Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$ExeUrl = "PASTE_YOUR_TAILSCALE_EXE_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-tailscale-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Tailscale install."

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "tailscale.exe"

try {
    Get-RemoteFile -Url $ExeUrl -Destination $ExePath -Label "Tailscale EXE"
    Install-Exe -ExePath $ExePath -Arguments @("/S", "/quiet", "/silent")
    Write-Log "SUCCESS: Tailscale installed."
} finally {
    Remove-TempDir -Path $TempDir
}

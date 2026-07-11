#Requires -RunAsAdministrator
# Warp Terminal Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$ExeUrl = "PASTE_YOUR_WARP_EXE_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-warp-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Warp Terminal install."

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "warp.exe"

try {
    Get-RemoteFile -Url $ExeUrl -Destination $ExePath -Label "Warp Terminal EXE"
    Install-Exe -ExePath $ExePath -Arguments @("/S", "/quiet", "/silent")
    Write-Log "SUCCESS: Warp Terminal installed."
} finally {
    Remove-TempDir -Path $TempDir
}

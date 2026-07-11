#Requires -RunAsAdministrator
# Keeper Password Manager Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$ExeUrl = "PASTE_YOUR_KEEPER_EXE_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-keeper-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Keeper Password Manager install."

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "keeper.exe"

try {
    Get-RemoteFile -Url $ExeUrl -Destination $ExePath -Label "Keeper Password Manager EXE"
    Install-Exe -ExePath $ExePath -Arguments @("/S", "/quiet", "/silent")
    Write-Log "SUCCESS: Keeper Password Manager installed."
} finally {
    Remove-TempDir -Path $TempDir
}

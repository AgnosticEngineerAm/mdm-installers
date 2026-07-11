#Requires -RunAsAdministrator
# Dropbox Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$ExeUrl = "PASTE_YOUR_DROPBOX_EXE_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-dropbox-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Dropbox install."

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "dropbox.exe"

try {
    Get-RemoteFile -Url $ExeUrl -Destination $ExePath -Label "Dropbox EXE"
    Install-Exe -ExePath $ExePath -Arguments @("/S", "/quiet", "/silent")
    Write-Log "SUCCESS: Dropbox installed."
} finally {
    Remove-TempDir -Path $TempDir
}

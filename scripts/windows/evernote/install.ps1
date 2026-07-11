#Requires -RunAsAdministrator
# Evernote Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$ExeUrl = "PASTE_YOUR_EVERNOTE_EXE_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-evernote-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Evernote install."

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "evernote.exe"

try {
    Get-RemoteFile -Url $ExeUrl -Destination $ExePath -Label "Evernote EXE"
    Install-Exe -ExePath $ExePath -Arguments @("/S", "/quiet", "/silent")
    Write-Log "SUCCESS: Evernote installed."
} finally {
    Remove-TempDir -Path $TempDir
}

#Requires -RunAsAdministrator
# FortiClient Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$ExeUrl = "PASTE_YOUR_FORTICLIENT_EXE_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-forticlient-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting FortiClient install."

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "forticlient.exe"

try {
    Get-RemoteFile -Url $ExeUrl -Destination $ExePath -Label "FortiClient EXE"
    Install-Exe -ExePath $ExePath -Arguments @("/S", "/quiet", "/silent")
    Write-Log "SUCCESS: FortiClient installed."
} finally {
    Remove-TempDir -Path $TempDir
}

#Requires -RunAsAdministrator
# Google Cloud SDK Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$ExeUrl = "PASTE_YOUR_GOOGLE_CLOUD_SDK_EXE_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-google-cloud-sdk-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Google Cloud SDK install."

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "google-cloud-sdk.exe"

try {
    Get-RemoteFile -Url $ExeUrl -Destination $ExePath -Label "Google Cloud SDK EXE"
    Install-Exe -ExePath $ExePath -Arguments @("/S", "/quiet", "/silent")
    Write-Log "SUCCESS: Google Cloud SDK installed."
} finally {
    Remove-TempDir -Path $TempDir
}

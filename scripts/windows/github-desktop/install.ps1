#Requires -RunAsAdministrator
# GitHub Desktop Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$MsiUrl = "PASTE_YOUR_GITHUB_DESKTOP_MSI_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-github-desktop-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting GitHub Desktop install."

$TempDir = New-TempDir
$MsiPath = Join-Path $TempDir "github-desktop.msi"

try {
    Get-RemoteFile -Url $MsiUrl -Destination $MsiPath -Label "GitHub Desktop MSI"
    Install-Msi -MsiPath $MsiPath
    Write-Log "SUCCESS: GitHub Desktop installed."
} finally {
    Remove-TempDir -Path $TempDir
}

#Requires -RunAsAdministrator
# Cloudflare WARP Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$MsiUrl = "PASTE_YOUR_CLOUDFLARE_WARP_MSI_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-cloudflare-warp-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Cloudflare WARP install."

$TempDir = New-TempDir
$MsiPath = Join-Path $TempDir "cloudflare-warp.msi"

try {
    Get-RemoteFile -Url $MsiUrl -Destination $MsiPath -Label "Cloudflare WARP MSI"
    Install-Msi -MsiPath $MsiPath
    Write-Log "SUCCESS: Cloudflare WARP installed."
} finally {
    Remove-TempDir -Path $TempDir
}

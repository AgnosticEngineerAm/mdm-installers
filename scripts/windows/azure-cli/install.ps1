#Requires -RunAsAdministrator
# Azure CLI Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$MsiUrl = "PASTE_YOUR_AZURE_CLI_MSI_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-azure-cli-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Azure CLI install."

$TempDir = New-TempDir
$MsiPath = Join-Path $TempDir "azure-cli.msi"

try {
    Get-RemoteFile -Url $MsiUrl -Destination $MsiPath -Label "Azure CLI MSI"
    Install-Msi -MsiPath $MsiPath
    Write-Log "SUCCESS: Azure CLI installed."
} finally {
    Remove-TempDir -Path $TempDir
}

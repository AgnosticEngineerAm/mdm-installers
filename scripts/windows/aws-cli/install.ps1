#Requires -RunAsAdministrator
# AWS CLI Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$MsiUrl = "PASTE_YOUR_AWS_CLI_MSI_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-aws-cli-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting AWS CLI install."

$TempDir = New-TempDir
$MsiPath = Join-Path $TempDir "aws-cli.msi"

try {
    Get-RemoteFile -Url $MsiUrl -Destination $MsiPath -Label "AWS CLI MSI"
    Install-Msi -MsiPath $MsiPath
    Write-Log "SUCCESS: AWS CLI installed."
} finally {
    Remove-TempDir -Path $TempDir
}

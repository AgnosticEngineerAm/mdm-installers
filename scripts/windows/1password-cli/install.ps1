#Requires -RunAsAdministrator
# 1Password CLI Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$ExeUrl = "PASTE_YOUR_1PASSWORD_CLI_EXE_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-1password-cli-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting 1Password CLI install."

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "1password-cli.exe"

try {
    Get-RemoteFile -Url $ExeUrl -Destination $ExePath -Label "1Password CLI EXE"
    Install-Exe -ExePath $ExePath -Arguments @("/S", "/quiet", "/silent")
    Write-Log "SUCCESS: 1Password CLI installed."
} finally {
    Remove-TempDir -Path $TempDir
}

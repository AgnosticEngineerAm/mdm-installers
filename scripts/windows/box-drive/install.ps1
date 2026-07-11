#Requires -RunAsAdministrator
# Box Drive Windows MDM Install Script
$ErrorActionPreference = 'Stop'

$MsiUrl = "PASTE_YOUR_BOX_DRIVE_MSI_URL_HERE"
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-box-drive-install.log"

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) { . $commonLib }

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Box Drive install."

$TempDir = New-TempDir
$MsiPath = Join-Path $TempDir "box-drive.msi"

try {
    Get-RemoteFile -Url $MsiUrl -Destination $MsiPath -Label "Box Drive MSI"
    Install-Msi -MsiPath $MsiPath
    Write-Log "SUCCESS: Box Drive installed."
} finally {
    Remove-TempDir -Path $TempDir
}

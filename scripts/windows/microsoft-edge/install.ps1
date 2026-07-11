#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Microsoft Edge Enterprise Windows MDM Install Script.
.DESCRIPTION
    Downloads and installs the Microsoft Edge Enterprise MSI silently.
#>

$ErrorActionPreference = 'Stop'

### ====== CONFIG ==============================================================
# Stable Universal MSI from Microsoft
$EdgeMsiUrl = "https://go.microsoft.com/fwlink/?linkid=2093437"
$ExpectedSha256 = ""
$ForceReinstall = $false
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-edge-install.log"
### ===========================================================================

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) {
    . $commonLib
} else {
    Write-Output "ERROR: Missing common.ps1 at $commonLib"
    exit 1
}

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Microsoft Edge install."

function Test-EdgeInstalled {
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $installed = Get-ItemProperty $paths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -match 'Microsoft Edge' }
    if ($installed) { return $true }
    return $false
}

if (-not $ForceReinstall -and (Test-EdgeInstalled)) {
    Write-Log "SKIP: Microsoft Edge is already installed."
    exit 0
}

$TempDir = New-TempDir
$MsiPath = Join-Path $TempDir "Edge.msi"

try {
    Get-RemoteFile -Url $EdgeMsiUrl -Destination $MsiPath -Label "Edge MSI"
    Test-FileHash -FilePath $MsiPath -ExpectedHash $ExpectedSha256
    Install-Msi -MsiPath $MsiPath
    
    if (-not (Test-EdgeInstalled)) {
        Invoke-Fatal "Edge installation did not validate."
    }
    Write-Log "SUCCESS: Microsoft Edge installed."
}
finally {
    Remove-TempDir -Path $TempDir
}

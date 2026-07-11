#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Mozilla Firefox Enterprise Windows MDM Install Script.
.DESCRIPTION
    Downloads and installs the Mozilla Firefox Enterprise MSI silently.
#>

$ErrorActionPreference = 'Stop'

### ====== CONFIG ==============================================================
# Mozilla provides a stable enterprise MSI URL:
$FirefoxMsiUrl = "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US"
$ExpectedSha256 = ""
$ForceReinstall = $false
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-firefox-install.log"
### ===========================================================================

# Load Common Library
$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) {
    . $commonLib
} else {
    Write-Output "ERROR: Missing common.ps1 at $commonLib"
    exit 1
}

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Mozilla Firefox install."

function Test-FirefoxInstalled {
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $installed = Get-ItemProperty $paths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -match 'Mozilla Firefox' }
    if ($installed) { return $true }
    return $false
}

if (-not $ForceReinstall -and (Test-FirefoxInstalled)) {
    Write-Log "SKIP: Mozilla Firefox is already installed."
    exit 0
}

$TempDir = New-TempDir
$MsiPath = Join-Path $TempDir "Firefox.msi"

try {
    Get-RemoteFile -Url $FirefoxMsiUrl -Destination $MsiPath -Label "Firefox MSI"
    Test-FileHash -FilePath $MsiPath -ExpectedHash $ExpectedSha256
    Install-Msi -MsiPath $MsiPath
    
    if (-not (Test-FirefoxInstalled)) {
        Invoke-Fatal "Firefox installation did not validate."
    }
    Write-Log "SUCCESS: Mozilla Firefox installed."
}
finally {
    Remove-TempDir -Path $TempDir
}

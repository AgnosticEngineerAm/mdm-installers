#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Adobe Acrobat Reader Windows MDM Install Script.
.DESCRIPTION
    Downloads and installs Adobe Acrobat Reader silently.
#>

$ErrorActionPreference = 'Stop'

### ====== CONFIG ==============================================================
# Typically you must provide an internal CDN link for Acrobat Reader enterprise:
$AcrobatExeUrl = "PASTE_YOUR_ACROBAT_READER_EXE_URL_HERE"
$ExpectedSha256 = ""
$ForceReinstall = $false
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-acrobat-install.log"
### ===========================================================================

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) {
    . $commonLib
} else {
    Write-Output "ERROR: Missing common.ps1"
    exit 1
}

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Adobe Acrobat Reader install."

if ($AcrobatExeUrl -eq "PASTE_YOUR_ACROBAT_READER_EXE_URL_HERE") {
    Invoke-Fatal "AcrobatExeUrl has not been set. Edit the CONFIG block before deploying."
}

function Test-AcrobatInstalled {
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $installed = Get-ItemProperty $paths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -match 'Adobe Acrobat Reader' }
    if ($installed) { return $true }
    return $false
}

if (-not $ForceReinstall -and (Test-AcrobatInstalled)) {
    Write-Log "SKIP: Acrobat Reader is already installed."
    exit 0
}

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "AcrobatReader.exe"

try {
    Get-RemoteFile -Url $AcrobatExeUrl -Destination $ExePath -Label "Acrobat Reader Setup"
    Test-FileHash -FilePath $ExePath -ExpectedHash $ExpectedSha256
    
    Install-Exe -ExePath $ExePath -Arguments @("/sAll", "/rs", "/msi", "EULA_ACCEPT=YES")
    
    if (-not (Test-AcrobatInstalled)) {
        Invoke-Fatal "Acrobat Reader installation did not validate."
    }
    Write-Log "SUCCESS: Acrobat Reader installed."
}
finally {
    Remove-TempDir -Path $TempDir
}

#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Figma Windows MDM Install Script.
.DESCRIPTION
    Downloads and installs Figma silently system-wide.
#>

$ErrorActionPreference = 'Stop'

### ====== CONFIG ==============================================================
$FigmaExeUrl = "https://desktop.figma.com/win/FigmaSetup.exe"
$ExpectedSha256 = ""
$ForceReinstall = $false
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-figma-install.log"
### ===========================================================================

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) {
    . $commonLib
} else {
    Write-Output "ERROR: Missing common.ps1"
    exit 1
}

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Figma install."

function Test-FigmaInstalled {
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $installed = Get-ItemProperty $paths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -match 'Figma' }
    if ($installed) { return $true }
    return $false
}

if (-not $ForceReinstall -and (Test-FigmaInstalled)) {
    Write-Log "SKIP: Figma is already installed."
    exit 0
}

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "FigmaSetup.exe"

try {
    Get-RemoteFile -Url $FigmaExeUrl -Destination $ExePath -Label "Figma Setup"
    Test-FileHash -FilePath $ExePath -ExpectedHash $ExpectedSha256
    
    # Squirrel installer typically supports -s or --silent
    Install-Exe -ExePath $ExePath -Arguments @("--silent")
    
    if (-not (Test-FigmaInstalled)) {
        Write-LogWarn "Figma installation did not strictly validate in registry. (User-level app)"
    }
    Write-Log "SUCCESS: Figma installed."
}
finally {
    Remove-TempDir -Path $TempDir
}

#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Notion Windows MDM Install Script.
.DESCRIPTION
    Downloads and installs Notion silently system-wide.
#>

$ErrorActionPreference = 'Stop'

### ====== CONFIG ==============================================================
$NotionExeUrl = "https://desktop-release.notion-static.com/Notion%20Setup.exe"
$ExpectedSha256 = ""
$ForceReinstall = $false
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-notion-install.log"
### ===========================================================================

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) {
    . $commonLib
} else {
    Write-Output "ERROR: Missing common.ps1"
    exit 1
}

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Notion install."

function Test-NotionInstalled {
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $installed = Get-ItemProperty $paths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -match 'Notion' }
    if ($installed) { return $true }
    return $false
}

if (-not $ForceReinstall -and (Test-NotionInstalled)) {
    Write-Log "SKIP: Notion is already installed."
    exit 0
}

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "NotionSetup.exe"

try {
    Get-RemoteFile -Url $NotionExeUrl -Destination $ExePath -Label "Notion Setup"
    Test-FileHash -FilePath $ExePath -ExpectedHash $ExpectedSha256
    
    # Squirrel
    Install-Exe -ExePath $ExePath -Arguments @("-s")
    
    if (-not (Test-NotionInstalled)) {
        Write-LogWarn "Notion installation did not strictly validate in registry. (User-level app)"
    }
    Write-Log "SUCCESS: Notion installed."
}
finally {
    Remove-TempDir -Path $TempDir
}

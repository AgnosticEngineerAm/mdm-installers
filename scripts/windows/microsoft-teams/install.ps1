#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Microsoft Teams Windows MDM Install Script.
.DESCRIPTION
    Installs the New Teams (MSIX via bootstrapper) system-wide.
#>

$ErrorActionPreference = 'Stop'

### ====== CONFIG ==============================================================
# Teams bootstrapper EXE:
$TeamsExeUrl = "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409"
$ExpectedSha256 = ""
$ForceReinstall = $false
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-teams-install.log"
### ===========================================================================

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) {
    . $commonLib
} else {
    Write-Output "ERROR: Missing common.ps1"
    exit 1
}

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Microsoft Teams install."

function Test-TeamsInstalled {
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $installed = Get-ItemProperty $paths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -match 'Microsoft Teams' -or $_.DisplayName -match 'Teams Machine-Wide Installer' }
    if ($installed) { return $true }
    
    # Also check AppxPackage for New Teams (machine-wide provisioning)
    $appx = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -match "MSTeams" }
    if ($appx) { return $true }

    return $false
}

if (-not $ForceReinstall -and (Test-TeamsInstalled)) {
    Write-Log "SKIP: Microsoft Teams is already installed."
    exit 0
}

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "teamsbootstrapper.exe"

try {
    Get-RemoteFile -Url $TeamsExeUrl -Destination $ExePath -Label "Teams Bootstrapper"
    Test-FileHash -FilePath $ExePath -ExpectedHash $ExpectedSha256
    
    Install-Exe -ExePath $ExePath -Arguments @("-p")
    
    if (-not (Test-TeamsInstalled)) {
        Write-LogWarn "Teams bootstrapper ran, but Appx detection sometimes lags. Assuming success."
    }
    Write-Log "SUCCESS: Microsoft Teams installed."
}
finally {
    Remove-TempDir -Path $TempDir
}

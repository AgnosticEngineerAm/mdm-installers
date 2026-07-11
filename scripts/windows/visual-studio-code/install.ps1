#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Visual Studio Code Windows MDM Install Script.
.DESCRIPTION
    Downloads and installs the VS Code system-wide installer.
#>

$ErrorActionPreference = 'Stop'

### ====== CONFIG ==============================================================
# Stable System Installer EXE:
$VsCodeExeUrl = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64"
$ExpectedSha256 = ""
$ForceReinstall = $false
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-vscode-install.log"
### ===========================================================================

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) {
    . $commonLib
} else {
    Write-Output "ERROR: Missing common.ps1"
    exit 1
}

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Visual Studio Code install."

function Test-VsCodeInstalled {
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $installed = Get-ItemProperty $paths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -match 'Visual Studio Code' }
    if ($installed) { return $true }
    return $false
}

if (-not $ForceReinstall -and (Test-VsCodeInstalled)) {
    Write-Log "SKIP: VS Code is already installed."
    exit 0
}

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "VSCodeSetup.exe"

try {
    Get-RemoteFile -Url $VsCodeExeUrl -Destination $ExePath -Label "VSCode Setup"
    Test-FileHash -FilePath $ExePath -ExpectedHash $ExpectedSha256
    
    Install-Exe -ExePath $ExePath -Arguments @("/verysilent", "/suppressmsgboxes", "/mergetasks=!runcode")
    
    if (-not (Test-VsCodeInstalled)) {
        Invoke-Fatal "VS Code installation did not validate."
    }
    Write-Log "SUCCESS: VS Code installed."
}
finally {
    Remove-TempDir -Path $TempDir
}

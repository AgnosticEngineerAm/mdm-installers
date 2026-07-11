#Requires -RunAsAdministrator
<#
.SYNOPSIS
    VLC Media Player Windows MDM Install Script.
.DESCRIPTION
    Downloads and installs VLC silently.
#>

$ErrorActionPreference = 'Stop'

### ====== CONFIG ==============================================================
$VlcExeUrl = "https://get.videolan.org/vlc/3.0.21/win64/vlc-3.0.21-win64.exe"
$ExpectedSha256 = ""
$ForceReinstall = $false
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-vlc-install.log"
### ===========================================================================

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) {
    . $commonLib
} else {
    Write-Output "ERROR: Missing common.ps1"
    exit 1
}

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting VLC install."

function Test-VlcInstalled {
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $installed = Get-ItemProperty $paths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -match 'VLC media player' }
    if ($installed) { return $true }
    return $false
}

if (-not $ForceReinstall -and (Test-VlcInstalled)) {
    Write-Log "SKIP: VLC is already installed."
    exit 0
}

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "vlc-setup.exe"

try {
    Get-RemoteFile -Url $VlcExeUrl -Destination $ExePath -Label "VLC Setup"
    Test-FileHash -FilePath $ExePath -ExpectedHash $ExpectedSha256
    
    # NSIS installer
    Install-Exe -ExePath $ExePath -Arguments @("/S", "/L=1033")
    
    if (-not (Test-VlcInstalled)) {
        Invoke-Fatal "VLC installation did not validate."
    }
    Write-Log "SUCCESS: VLC installed."
}
finally {
    Remove-TempDir -Path $TempDir
}

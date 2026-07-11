#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Postman Windows MDM Install Script.
.DESCRIPTION
    Downloads and installs Postman silently system-wide.
#>

$ErrorActionPreference = 'Stop'

### ====== CONFIG ==============================================================
$PostmanExeUrl = "https://dl.pstmn.io/download/latest/win64"
$ExpectedSha256 = ""
$ForceReinstall = $false
$LogFilePath = "$env:ProgramData\MDM\Logs\mdm-postman-install.log"
### ===========================================================================

$commonLib = "$PSScriptRoot\..\_lib\common.ps1"
if (Test-Path $commonLib) {
    . $commonLib
} else {
    Write-Output "ERROR: Missing common.ps1"
    exit 1
}

Initialize-LogFile -Path $LogFilePath
Write-Log "Starting Postman install."

function Test-PostmanInstalled {
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $installed = Get-ItemProperty $paths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -match 'Postman' }
    if ($installed) { return $true }
    return $false
}

if (-not $ForceReinstall -and (Test-PostmanInstalled)) {
    Write-Log "SKIP: Postman is already installed."
    exit 0
}

$TempDir = New-TempDir
$ExePath = Join-Path $TempDir "PostmanSetup.exe"

try {
    Get-RemoteFile -Url $PostmanExeUrl -Destination $ExePath -Label "Postman Setup"
    Test-FileHash -FilePath $ExePath -ExpectedHash $ExpectedSha256
    
    # Squirrel installer
    Install-Exe -ExePath $ExePath -Arguments @("-s")
    
    if (-not (Test-PostmanInstalled)) {
        Invoke-Fatal "Postman installation did not validate."
    }
    Write-Log "SUCCESS: Postman installed."
}
finally {
    Remove-TempDir -Path $TempDir
}

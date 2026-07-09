#Requires -RunAsAdministrator
<#
.SYNOPSIS Google Chrome Windows enterprise install (MDM Script).
.NOTES Version: 1.0 | Tested: Windows 10 22H2, Windows 11 23H2
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ====== CONFIG ================================================================
# Google's enterprise MSI (64-bit) — always fetches latest stable
$ChromeMsiUrl   = 'https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi'
$ExpectedSHA256 = ''
$ForceReinstall = $false
$LogFile        = 'C:\ProgramData\MDM\Logs\chrome-install.log'
# =============================================================================

$LogDir = Split-Path $LogFile -Parent
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $line = "[$((Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ' -AsUTC))] [$Level] [GoogleChrome] $Message"
    Write-Output $line
    Add-Content -Path $LogFile -Value $line -ErrorAction SilentlyContinue
}
function Invoke-Fatal { param([string]$m) Write-Log $m 'ERROR'; exit 1 }

Write-Log 'Starting Google Chrome install.'

function Test-ChromeInstalled {
    return (Test-Path 'C:\Program Files\Google\Chrome\Application\chrome.exe') -or
           (Test-Path 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe')
}

function Get-ChromeVersion {
    $path = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
    if (-not (Test-Path $path)) { $path = 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe' }
    if (Test-Path $path) { return (Get-Item $path).VersionInfo.FileVersion }
    return 'unknown'
}

if (-not $ForceReinstall -and (Test-ChromeInstalled)) {
    Write-Log "SKIP: Google Chrome already installed ($(Get-ChromeVersion)). No action taken."
    exit 0
}

$TempDir = Join-Path $env:TEMP "mdm-chrome-$(New-Guid)"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
$MsiPath = Join-Path $TempDir 'GoogleChrome.msi'

try {
    Write-Log 'Downloading Google Chrome enterprise MSI...'
    $wc = [System.Net.WebClient]::new()
    $wc.DownloadFile($ChromeMsiUrl, $MsiPath)
} catch { Invoke-Fatal "Download failed: $_" } finally { if ($wc) { $wc.Dispose() } }

if ($ExpectedSHA256) {
    $actual = (Get-FileHash -Path $MsiPath -Algorithm SHA256).Hash.ToLower()
    if ($actual -ne $ExpectedSHA256.ToLower()) { Invoke-Fatal "SHA256 mismatch. Got: $actual" }
    Write-Log "SHA256 verified."
}

Write-Log 'Installing Google Chrome silently...'
$proc = Start-Process msiexec.exe -ArgumentList "/i `"$MsiPath`" /quiet /norestart /l*v `"$LogDir\chrome-msi.log`"" -Wait -PassThru
if ($proc.ExitCode -notin @(0, 3010)) { Invoke-Fatal "msiexec exited $($proc.ExitCode)." }

Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue

if (Test-ChromeInstalled) {
    Write-Log "SUCCESS: Google Chrome installed ($(Get-ChromeVersion))."
    exit 0
}
Invoke-Fatal 'Installation did not validate.'

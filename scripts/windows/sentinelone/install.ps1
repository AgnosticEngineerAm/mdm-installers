#Requires -RunAsAdministrator
<#
.SYNOPSIS
    SentinelOne Windows install script (MDM / Intune Remediation / PowerShell).
.DESCRIPTION
    Silent, idempotent SentinelOne Singularity install for Windows.
    - Skips if already installed and FORCE_REINSTALL is false.
    - Downloads the MSI, verifies SHA256, installs silently with Site Token.
    - Logs to C:\ProgramData\MDM\Logs\sentinelone-install.log and stdout.
.NOTES
    Version: 1.0
    Tested on: Windows 10 22H2, Windows 11 23H2
    Repository: https://github.com/CyberEnthusiastAm/mdm-installers
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ====== CONFIG ================================================================
$S1MsiUrl      = 'PASTE_YOUR_SENTINELONE_MSI_URL_HERE'
$S1SiteToken   = 'PASTE_YOUR_SITE_TOKEN_HERE'
$ExpectedSHA256 = ''                  # SHA256 of the .msi (leave empty to skip)
$ForceReinstall = $false
$LogFile        = 'C:\ProgramData\MDM\Logs\sentinelone-install.log'
# =============================================================================

# -- Logging -------------------------------------------------------------------
$LogDir = Split-Path $LogFile -Parent
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $line = "[$((Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ' -AsUTC))] [$Level] [SentinelOne] $Message"
    Write-Output $line
    Add-Content -Path $LogFile -Value $line -ErrorAction SilentlyContinue
}
function Write-Warn  { param([string]$m) Write-Log $m 'WARN'  }
function Invoke-Fatal { param([string]$m) Write-Log $m 'ERROR'; exit 1 }

Write-Log "Starting SentinelOne install script."
Write-Log "OS: $((Get-CimInstance Win32_OperatingSystem).Caption) $((Get-CimInstance Win32_OperatingSystem).Version)"

# -- Idempotency ---------------------------------------------------------------
function Test-S1Installed {
    $s1Service = Get-Service -Name 'SentinelAgent' -ErrorAction SilentlyContinue
    if ($s1Service) { return $true }
    $s1App = Get-CimInstance -ClassName Win32_Product -ErrorAction SilentlyContinue |
             Where-Object { $_.Name -like '*SentinelOne*' -or $_.Name -like '*Sentinel Agent*' }
    return ($null -ne $s1App)
}

if (-not $ForceReinstall -and (Test-S1Installed)) {
    Write-Log 'SKIP: SentinelOne already installed. No action taken.'
    exit 0
}

# -- Validate config ------------------------------------------------------------
if ($S1MsiUrl -eq 'PASTE_YOUR_SENTINELONE_MSI_URL_HERE') {
    Invoke-Fatal 'S1MsiUrl has not been set. Edit the CONFIG block before deploying.'
}
if ($S1SiteToken -eq 'PASTE_YOUR_SITE_TOKEN_HERE') {
    Invoke-Fatal 'S1SiteToken has not been set. Edit the CONFIG block before deploying.'
}

# -- Download ------------------------------------------------------------------
$TempDir = Join-Path $env:TEMP "mdm-s1-$(New-Guid)"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
$MsiPath = Join-Path $TempDir 'SentinelOne.msi'

try {
    Write-Log "Downloading SentinelOne MSI..."
    $wc = [System.Net.WebClient]::new()
    $wc.DownloadFile($S1MsiUrl, $MsiPath)
    Write-Log "Download complete: $MsiPath"
}
catch { Invoke-Fatal "Download failed: $_" }
finally { if ($wc) { $wc.Dispose() } }

# -- Hash verification ---------------------------------------------------------
if (-not [string]::IsNullOrWhiteSpace($ExpectedSHA256)) {
    $actual = (Get-FileHash -Path $MsiPath -Algorithm SHA256).Hash.ToLower()
    if ($actual -ne $ExpectedSHA256.ToLower()) {
        Invoke-Fatal "SHA256 mismatch. Expected: $ExpectedSHA256  Got: $actual"
    }
    Write-Log "SHA256 verified: $actual"
} else {
    Write-Warn 'ExpectedSHA256 not set; skipping hash verification.'
}

# -- Install -------------------------------------------------------------------
Write-Log 'Installing SentinelOne silently (token not logged)...'
$msiArgs = "/i `"$MsiPath`" /quiet /norestart " +
           "SITE_TOKEN=`"$S1SiteToken`" " +
           "/l*v `"$LogDir\sentinelone-msi.log`""
$proc = Start-Process -FilePath 'msiexec.exe' -ArgumentList $msiArgs -Wait -PassThru

if ($proc.ExitCode -notin @(0, 3010)) {
    Invoke-Fatal "msiexec.exe exited with code $($proc.ExitCode). See $LogDir\sentinelone-msi.log"
}
if ($proc.ExitCode -eq 3010) {
    Write-Warn 'Reboot required to complete SentinelOne installation.'
}

# -- Validate ------------------------------------------------------------------
Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue

if (Test-S1Installed) {
    Write-Log 'SUCCESS: SentinelOne installed and service detected.'
    exit 0
}

Invoke-Fatal "Installation did not validate. Check $LogDir\sentinelone-msi.log and the S1 console."

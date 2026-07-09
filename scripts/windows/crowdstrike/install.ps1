#Requires -RunAsAdministrator
<#
.SYNOPSIS
    CrowdStrike Falcon Windows install script (MDM / Intune Remediation / PowerShell).
.DESCRIPTION
    Silent, idempotent CrowdStrike Falcon Sensor install for Windows.
    - Skips if already installed and ForceReinstall is false.
    - Downloads the EXE installer, verifies SHA256, installs silently with CID.
    - Logs to C:\ProgramData\MDM\Logs\crowdstrike-install.log.
.NOTES
    Version: 1.0
    Tested on: Windows 10 22H2, Windows 11 23H2
    Repository: https://github.com/CyberEnthusiastAm/mdm-installers
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ====== CONFIG ================================================================
$CSInstallerUrl  = 'PASTE_YOUR_CROWDSTRIKE_EXE_URL_HERE'
$CSCustomerId    = 'PASTE_YOUR_CUSTOMER_ID_HERE'   # CID (with checksum hash)
$ExpectedSHA256  = ''
$ForceReinstall  = $false
$LogFile         = 'C:\ProgramData\MDM\Logs\crowdstrike-install.log'
# =============================================================================

$LogDir = Split-Path $LogFile -Parent
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $line = "[$((Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ' -AsUTC))] [$Level] [CrowdStrike] $Message"
    Write-Output $line
    Add-Content -Path $LogFile -Value $line -ErrorAction SilentlyContinue
}
function Write-Warn  { param([string]$m) Write-Log $m 'WARN'  }
function Invoke-Fatal { param([string]$m) Write-Log $m 'ERROR'; exit 1 }

Write-Log 'Starting CrowdStrike Falcon install script.'
Write-Log "OS: $((Get-CimInstance Win32_OperatingSystem).Caption)"

function Test-CSInstalled {
    $svc = Get-Service -Name 'CSFalconService' -ErrorAction SilentlyContinue
    if ($svc) { return $true }
    return (Test-Path 'C:\Program Files\CrowdStrike\CSFalconService.exe')
}

if (-not $ForceReinstall -and (Test-CSInstalled)) {
    Write-Log 'SKIP: CrowdStrike Falcon already installed. No action taken.'
    exit 0
}

if ($CSInstallerUrl -eq 'PASTE_YOUR_CROWDSTRIKE_EXE_URL_HERE') {
    Invoke-Fatal 'CSInstallerUrl has not been set. Edit the CONFIG block.'
}
if ($CSCustomerId -eq 'PASTE_YOUR_CUSTOMER_ID_HERE') {
    Invoke-Fatal 'CSCustomerId has not been set. Edit the CONFIG block.'
}

$TempDir = Join-Path $env:TEMP "mdm-cs-$(New-Guid)"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
$InstallerPath = Join-Path $TempDir 'CrowdStrikeFalcon.exe'

try {
    Write-Log 'Downloading CrowdStrike Falcon installer...'
    $wc = [System.Net.WebClient]::new()
    $wc.DownloadFile($CSInstallerUrl, $InstallerPath)
    Write-Log "Download complete: $InstallerPath"
}
catch { Invoke-Fatal "Download failed: $_" }
finally { if ($wc) { $wc.Dispose() } }

if (-not [string]::IsNullOrWhiteSpace($ExpectedSHA256)) {
    $actual = (Get-FileHash -Path $InstallerPath -Algorithm SHA256).Hash.ToLower()
    if ($actual -ne $ExpectedSHA256.ToLower()) {
        Invoke-Fatal "SHA256 mismatch. Expected: $ExpectedSHA256  Got: $actual"
    }
    Write-Log "SHA256 verified: $actual"
} else {
    Write-Warn 'ExpectedSHA256 not set; skipping hash verification.'
}

Write-Log 'Installing CrowdStrike Falcon silently (CID not logged)...'
$installArgs = @(
    '/install', '/quiet', '/norestart',
    "CID=$CSCustomerId"
)
$proc = Start-Process -FilePath $InstallerPath -ArgumentList $installArgs -Wait -PassThru

if ($proc.ExitCode -notin @(0, 3010)) {
    Invoke-Fatal "Installer exited with code $($proc.ExitCode)."
}
if ($proc.ExitCode -eq 3010) { Write-Warn 'Reboot required to complete installation.' }

Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue

if (Test-CSInstalled) {
    Write-Log 'SUCCESS: CrowdStrike Falcon installed and service detected.'
    exit 0
}

Invoke-Fatal 'Installation did not validate. Check the Falcon console.'

#Requires -RunAsAdministrator
<#
.SYNOPSIS
    JumpCloud Agent Windows install script (MDM / Intune / PowerShell).
.DESCRIPTION
    Silent, idempotent JumpCloud Agent install for Windows.
    - Skips if already installed and ForceReinstall is false.
    - Downloads the agent MSI, installs silently with Connect Key.
    - Logs to C:\ProgramData\MDM\Logs\jumpcloud-install.log and stdout.
.NOTES
    Version: 1.0
    Tested on: Windows 10 22H2, Windows 11 23H2
    Repository: https://github.com/CyberEnthusiastAm/mdm-installers
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ====== CONFIG ================================================================
$JcConnectKey  = 'PASTE_YOUR_JUMPCLOUD_CONNECT_KEY_HERE'
$JcMsiUrl      = 'https://cdn02.jumpcloud.com/production/jcagent-msi-signed.msi'
$ExpectedSHA256 = ''                  # SHA256 of the .msi (leave empty to skip)
$ForceReinstall = $false
$LogFile        = 'C:\ProgramData\MDM\Logs\jumpcloud-install.log'
# =============================================================================

# -- Logging -------------------------------------------------------------------
$LogDir = Split-Path $LogFile -Parent
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $line = "[$((Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ' -AsUTC))] [$Level] [JumpCloud] $Message"
    Write-Output $line
    Add-Content -Path $LogFile -Value $line -ErrorAction SilentlyContinue
}
function Write-Warn  { param([string]$m) Write-Log $m 'WARN'  }
function Invoke-Fatal { param([string]$m) Write-Log $m 'ERROR'; exit 1 }

Write-Log "Starting JumpCloud Agent install script."
Write-Log "OS: $((Get-CimInstance Win32_OperatingSystem).Caption) $((Get-CimInstance Win32_OperatingSystem).Version)"

# -- Idempotency ---------------------------------------------------------------
function Test-JcInstalled {
    $jcService = Get-Service -Name 'jumpcloud-agent' -ErrorAction SilentlyContinue
    return ($null -ne $jcService)
}

if (-not $ForceReinstall -and (Test-JcInstalled)) {
    Write-Log 'SKIP: JumpCloud Agent already installed. No action taken.'
    exit 0
}

# -- Validate config ------------------------------------------------------------
if ($JcConnectKey -eq 'PASTE_YOUR_JUMPCLOUD_CONNECT_KEY_HERE') {
    Invoke-Fatal 'JcConnectKey has not been set. Edit the CONFIG block before deploying.'
}

# -- Download ------------------------------------------------------------------
$TempDir = Join-Path $env:TEMP "mdm-jumpcloud-$(New-Guid)"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
$MsiPath = Join-Path $TempDir 'jcagent.msi'

try {
    Write-Log "Downloading JumpCloud Agent MSI..."
    $wc = [System.Net.WebClient]::new()
    $wc.DownloadFile($JcMsiUrl, $MsiPath)
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
Write-Log 'Installing JumpCloud Agent silently (Connect Key not logged)...'
$msiArgs = "/i `"$MsiPath`" /quiet /norestart " +
           "CONNECT_KEY=`"$JcConnectKey`" " +
           "/l*v `"$LogDir\jumpcloud-msi.log`""
$proc = Start-Process -FilePath 'msiexec.exe' -ArgumentList $msiArgs -Wait -PassThru

if ($proc.ExitCode -notin @(0, 3010)) {
    Invoke-Fatal "msiexec.exe exited with code $($proc.ExitCode). See $LogDir\jumpcloud-msi.log"
}
if ($proc.ExitCode -eq 3010) {
    Write-Warn 'Reboot required to complete JumpCloud Agent installation.'
}

# -- Validate ------------------------------------------------------------------
Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue

# Wait for the service to start
for ($i = 0; $i -lt 15; $i++) {
    if (Test-JcInstalled) { break }
    Start-Sleep -Seconds 2
}

if (Test-JcInstalled) {
    Write-Log 'SUCCESS: JumpCloud Agent installed and service detected.'
    exit 0
}

Invoke-Fatal "Installation did not validate. Check $LogDir\jumpcloud-msi.log."

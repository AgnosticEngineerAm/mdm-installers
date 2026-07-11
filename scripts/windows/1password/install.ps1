#Requires -RunAsAdministrator
<#
.SYNOPSIS
    1Password Windows install script (MDM / Intune Remediation / PowerShell).
.DESCRIPTION
    Silent, idempotent 1Password 8 install for Windows.
    - Skips if already installed and ForceReinstall is false.
    - Downloads the MSI, verifies SHA256, installs silently.
    - Logs to C:\ProgramData\MDM\Logs\1password-install.log and stdout.
.NOTES
    Version: 1.0
    Tested on: Windows 10 22H2, Windows 11 23H2
    Repository: https://github.com/CyberEnthusiastAm/mdm-installers
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ====== CONFIG ================================================================
$OnePasswordMsiUrl = 'PASTE_YOUR_1PASSWORD_MSI_URL_HERE'
$ExpectedSHA256    = ''                  # SHA256 of the .msi (leave empty to skip)
$ForceReinstall    = $false
$LogFile           = 'C:\ProgramData\MDM\Logs\1password-install.log'
# =============================================================================

# -- Logging -------------------------------------------------------------------
$LogDir = Split-Path $LogFile -Parent
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $line = "[$((Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ' -AsUTC))] [$Level] [1Password] $Message"
    Write-Output $line
    Add-Content -Path $LogFile -Value $line -ErrorAction SilentlyContinue
}
function Write-Warn  { param([string]$m) Write-Log $m 'WARN'  }
function Invoke-Fatal { param([string]$m) Write-Log $m 'ERROR'; exit 1 }

Write-Log "Starting 1Password install script."
Write-Log "OS: $((Get-CimInstance Win32_OperatingSystem).Caption) $((Get-CimInstance Win32_OperatingSystem).Version)"

# -- Idempotency ---------------------------------------------------------------
function Test-1PasswordInstalled {
    $app = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
                                  'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
           Where-Object { $_.DisplayName -like '*1Password*' }
    return ($null -ne $app)
}

if (-not $ForceReinstall -and (Test-1PasswordInstalled)) {
    Write-Log 'SKIP: 1Password already installed. No action taken.'
    exit 0
}

# -- Validate config ------------------------------------------------------------
if ($OnePasswordMsiUrl -eq 'PASTE_YOUR_1PASSWORD_MSI_URL_HERE') {
    Invoke-Fatal 'OnePasswordMsiUrl has not been set. Edit the CONFIG block before deploying.'
}

# -- Download ------------------------------------------------------------------
$TempDir = Join-Path $env:TEMP "mdm-1password-$(New-Guid)"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
$MsiPath = Join-Path $TempDir '1Password.msi'

try {
    Write-Log "Downloading 1Password MSI..."
    $wc = [System.Net.WebClient]::new()
    $wc.DownloadFile($OnePasswordMsiUrl, $MsiPath)
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
Write-Log 'Installing 1Password silently...'
$msiArgs = "/i `"$MsiPath`" /quiet /norestart " +
           "/l*v `"$LogDir\1password-msi.log`""
$proc = Start-Process -FilePath 'msiexec.exe' -ArgumentList $msiArgs -Wait -PassThru

if ($proc.ExitCode -notin @(0, 3010)) {
    Invoke-Fatal "msiexec.exe exited with code $($proc.ExitCode). See $LogDir\1password-msi.log"
}
if ($proc.ExitCode -eq 3010) {
    Write-Warn 'Reboot required to complete 1Password installation.'
}

# -- Validate ------------------------------------------------------------------
Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue

if (Test-1PasswordInstalled) {
    Write-Log 'SUCCESS: 1Password installed.'
    exit 0
}

Invoke-Fatal "Installation did not validate. Check $LogDir\1password-msi.log."

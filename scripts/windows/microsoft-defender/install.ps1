#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Microsoft Defender Windows install/onboarding script (MDM / Intune).
.DESCRIPTION
    Ensures Microsoft Defender for Endpoint is enabled and onboarded on Windows.
    Windows 10/11 ships with Defender built-in — this script verifies the service
    is running, not disabled, and optionally applies an onboarding package for
    Defender for Endpoint (MDE) licensing.
    - Logs to C:\ProgramData\MDM\Logs\defender-install.log and stdout.
.NOTES
    Version: 1.0
    Tested on: Windows 10 22H2, Windows 11 23H2
    Repository: https://github.com/CyberEnthusiastAm/mdm-installers
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ====== CONFIG ================================================================
# Onboarding package URL (from Defender Security Center > Settings > Onboarding)
# Leave empty if only verifying that Defender is active (no MDE onboarding).
$MdeOnboardingScriptUrl = ''
$ExpectedSHA256         = ''              # SHA256 of the onboarding script
$ForceReinstall         = $false
$LogFile                = 'C:\ProgramData\MDM\Logs\defender-install.log'
# =============================================================================

# -- Logging -------------------------------------------------------------------
$LogDir = Split-Path $LogFile -Parent
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $line = "[$((Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ' -AsUTC))] [$Level] [Defender] $Message"
    Write-Output $line
    Add-Content -Path $LogFile -Value $line -ErrorAction SilentlyContinue
}
function Write-Warn  { param([string]$m) Write-Log $m 'WARN'  }
function Invoke-Fatal { param([string]$m) Write-Log $m 'ERROR'; exit 1 }

Write-Log "Starting Microsoft Defender configuration script."
Write-Log "OS: $((Get-CimInstance Win32_OperatingSystem).Caption) $((Get-CimInstance Win32_OperatingSystem).Version)"

# -- Verify Defender is present and running ------------------------------------
$defenderService = Get-Service -Name 'WinDefend' -ErrorAction SilentlyContinue
if (-not $defenderService) {
    Invoke-Fatal 'WinDefend service not found. Defender may have been uninstalled or replaced by a third-party AV.'
}

if ($defenderService.Status -ne 'Running') {
    Write-Log 'WinDefend service is not running. Attempting to start...'
    try {
        Start-Service -Name 'WinDefend' -ErrorAction Stop
        Write-Log 'WinDefend service started.'
    }
    catch {
        Write-Warn "Could not start WinDefend: $_. A third-party AV may be the active provider."
    }
}

# -- Check if already onboarded to MDE ----------------------------------------
function Test-MdeOnboarded {
    $senseService = Get-Service -Name 'Sense' -ErrorAction SilentlyContinue
    return ($senseService -and $senseService.Status -eq 'Running')
}

if (-not $ForceReinstall -and (Test-MdeOnboarded)) {
    Write-Log 'SKIP: Microsoft Defender for Endpoint already onboarded (Sense service running).'
    exit 0
}

# -- MDE Onboarding (optional) ------------------------------------------------
if ([string]::IsNullOrWhiteSpace($MdeOnboardingScriptUrl)) {
    Write-Log 'MdeOnboardingScriptUrl not set. Defender is active but MDE onboarding skipped.'
    Write-Log 'To onboard to Defender for Endpoint, set MdeOnboardingScriptUrl to your onboarding package URL.'
    exit 0
}

$TempDir = Join-Path $env:TEMP "mdm-defender-$(New-Guid)"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
$OnboardingScript = Join-Path $TempDir 'WindowsDefenderATPOnboardingScript.cmd'

try {
    Write-Log "Downloading MDE onboarding script..."
    $wc = [System.Net.WebClient]::new()
    $wc.DownloadFile($MdeOnboardingScriptUrl, $OnboardingScript)
    Write-Log "Download complete: $OnboardingScript"
}
catch { Invoke-Fatal "Download failed: $_" }
finally { if ($wc) { $wc.Dispose() } }

# -- Hash verification ---------------------------------------------------------
if (-not [string]::IsNullOrWhiteSpace($ExpectedSHA256)) {
    $actual = (Get-FileHash -Path $OnboardingScript -Algorithm SHA256).Hash.ToLower()
    if ($actual -ne $ExpectedSHA256.ToLower()) {
        Invoke-Fatal "SHA256 mismatch. Expected: $ExpectedSHA256  Got: $actual"
    }
    Write-Log "SHA256 verified: $actual"
} else {
    Write-Warn 'ExpectedSHA256 not set; skipping hash verification.'
}

# -- Run onboarding script ----------------------------------------------------
Write-Log 'Running MDE onboarding script...'
$proc = Start-Process -FilePath 'cmd.exe' -ArgumentList "/c `"$OnboardingScript`"" -Wait -PassThru

if ($proc.ExitCode -ne 0) {
    Invoke-Fatal "Onboarding script exited with code $($proc.ExitCode)."
}

# -- Validate ------------------------------------------------------------------
Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 10

if (Test-MdeOnboarded) {
    Write-Log 'SUCCESS: Microsoft Defender for Endpoint is onboarded and running.'
    exit 0
}

Write-Warn 'Sense service not yet detected. Onboarding may take a few minutes to propagate.'
Write-Log 'Check the Microsoft Defender Security Center portal for device registration.'
exit 0

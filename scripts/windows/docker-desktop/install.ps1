#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Docker Desktop Windows install script (MDM / Intune Remediation / PowerShell).
.DESCRIPTION
    Silent, idempotent Docker Desktop install for Windows.
    - Skips if already installed and ForceReinstall is false.
    - Downloads the EXE installer, verifies SHA256, installs silently.
    - Logs to C:\ProgramData\MDM\Logs\docker-install.log and stdout.
.NOTES
    Version: 1.0
    Tested on: Windows 10 22H2, Windows 11 23H2
    Prerequisites: Hyper-V or WSL 2 must be enabled
    Repository: https://github.com/CyberEnthusiastAm/mdm-installers
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ====== CONFIG ================================================================
$DockerExeUrl   = 'https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe'
$ExpectedSHA256 = ''                  # SHA256 of the .exe (leave empty to skip)
$ForceReinstall = $false
$LogFile        = 'C:\ProgramData\MDM\Logs\docker-install.log'
# =============================================================================

# -- Logging -------------------------------------------------------------------
$LogDir = Split-Path $LogFile -Parent
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $line = "[$((Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ' -AsUTC))] [$Level] [DockerDesktop] $Message"
    Write-Output $line
    Add-Content -Path $LogFile -Value $line -ErrorAction SilentlyContinue
}
function Write-Warn  { param([string]$m) Write-Log $m 'WARN'  }
function Invoke-Fatal { param([string]$m) Write-Log $m 'ERROR'; exit 1 }

Write-Log "Starting Docker Desktop install script."
Write-Log "OS: $((Get-CimInstance Win32_OperatingSystem).Caption) $((Get-CimInstance Win32_OperatingSystem).Version)"

# -- Idempotency ---------------------------------------------------------------
function Test-DockerInstalled {
    $dockerPath = Join-Path $env:ProgramFiles 'Docker\Docker\Docker Desktop.exe'
    if (Test-Path $dockerPath) { return $true }
    $app = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
                                  'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
           Where-Object { $_.DisplayName -like '*Docker Desktop*' }
    return ($null -ne $app)
}

if (-not $ForceReinstall -and (Test-DockerInstalled)) {
    Write-Log 'SKIP: Docker Desktop already installed. No action taken.'
    exit 0
}

# -- Download ------------------------------------------------------------------
$TempDir = Join-Path $env:TEMP "mdm-docker-$(New-Guid)"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
$ExePath = Join-Path $TempDir 'DockerDesktopInstaller.exe'

try {
    Write-Log "Downloading Docker Desktop installer..."
    $wc = [System.Net.WebClient]::new()
    $wc.DownloadFile($DockerExeUrl, $ExePath)
    Write-Log "Download complete: $ExePath"
}
catch { Invoke-Fatal "Download failed: $_" }
finally { if ($wc) { $wc.Dispose() } }

# -- Hash verification ---------------------------------------------------------
if (-not [string]::IsNullOrWhiteSpace($ExpectedSHA256)) {
    $actual = (Get-FileHash -Path $ExePath -Algorithm SHA256).Hash.ToLower()
    if ($actual -ne $ExpectedSHA256.ToLower()) {
        Invoke-Fatal "SHA256 mismatch. Expected: $ExpectedSHA256  Got: $actual"
    }
    Write-Log "SHA256 verified: $actual"
} else {
    Write-Warn 'ExpectedSHA256 not set; skipping hash verification.'
}

# -- Install -------------------------------------------------------------------
Write-Log 'Installing Docker Desktop silently...'
$installArgs = 'install', '--quiet', '--accept-license'
$proc = Start-Process -FilePath $ExePath -ArgumentList $installArgs -Wait -PassThru

if ($proc.ExitCode -notin @(0, 3010)) {
    Invoke-Fatal "Docker installer exited with code $($proc.ExitCode)."
}
if ($proc.ExitCode -eq 3010) {
    Write-Warn 'Reboot required to complete Docker Desktop installation.'
}

# -- Validate ------------------------------------------------------------------
Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue

if (Test-DockerInstalled) {
    Write-Log 'SUCCESS: Docker Desktop installed.'
    Write-Log 'NOTE: Docker Desktop requires the user to launch it once to complete setup.'
    exit 0
}

Invoke-Fatal "Installation did not validate. Check Docker installer logs."

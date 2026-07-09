#Requires -RunAsAdministrator
<#
.SYNOPSIS Slack Windows install script (MDM Script).
.NOTES Version: 1.0 | Tested: Windows 10 22H2, Windows 11 23H2
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ====== CONFIG ================================================================
# Slack MSI - machine-wide installer (recommended for MDM/enterprise)
# Download from https://slack.com/intl/en-us/downloads/windows and host internally
$SlackMsiUrl    = 'PASTE_YOUR_SLACK_MSI_URL_HERE'
$ExpectedSHA256 = ''
$ForceReinstall = $false
$LogFile        = 'C:\ProgramData\MDM\Logs\slack-install.log'
# =============================================================================

$LogDir = Split-Path $LogFile -Parent
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $line = "[$((Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ' -AsUTC))] [$Level] [Slack] $Message"
    Write-Output $line
    Add-Content -Path $LogFile -Value $line -ErrorAction SilentlyContinue
}
function Invoke-Fatal { param([string]$m) Write-Log $m 'ERROR'; exit 1 }

Write-Log 'Starting Slack install.'

function Test-SlackInstalled {
    $paths = @(
        "$env:ProgramFiles\Slack\slack.exe",
        "$env:ProgramFiles (x86)\Slack\slack.exe"
    )
    foreach ($p in $paths) { if (Test-Path $p) { return $true } }
    return $false
}

if (-not $ForceReinstall -and (Test-SlackInstalled)) {
    Write-Log 'SKIP: Slack already installed. No action taken.'
    exit 0
}

if ($SlackMsiUrl -eq 'PASTE_YOUR_SLACK_MSI_URL_HERE') {
    Invoke-Fatal 'SlackMsiUrl has not been set. Edit the CONFIG block.'
}

$TempDir = Join-Path $env:TEMP "mdm-slack-$(New-Guid)"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
$MsiPath = Join-Path $TempDir 'Slack.msi'

try {
    Write-Log 'Downloading Slack MSI...'
    $wc = [System.Net.WebClient]::new()
    $wc.DownloadFile($SlackMsiUrl, $MsiPath)
} catch { Invoke-Fatal "Download failed: $_" } finally { if ($wc) { $wc.Dispose() } }

if ($ExpectedSHA256) {
    $actual = (Get-FileHash -Path $MsiPath -Algorithm SHA256).Hash.ToLower()
    if ($actual -ne $ExpectedSHA256.ToLower()) { Invoke-Fatal "SHA256 mismatch. Got: $actual" }
    Write-Log 'SHA256 verified.'
}

Write-Log 'Installing Slack silently...'
$proc = Start-Process msiexec.exe -ArgumentList "/i `"$MsiPath`" /quiet /norestart /l*v `"$LogDir\slack-msi.log`"" -Wait -PassThru
if ($proc.ExitCode -notin @(0, 3010)) { Invoke-Fatal "msiexec exited $($proc.ExitCode)." }

Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue

if (Test-SlackInstalled) { Write-Log 'SUCCESS: Slack installed.'; exit 0 }
Invoke-Fatal 'Installation did not validate.'

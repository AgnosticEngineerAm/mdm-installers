#Requires -RunAsAdministrator
<#
.SYNOPSIS Zoom Windows install script (MDM Script).
.NOTES Version: 1.0 | Tested: Windows 10 22H2, Windows 11 23H2
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ====== CONFIG ================================================================
# IT Admin MSI - Universal (recommended for MDM deployment)
$ZoomMsiUrl     = 'https://zoom.us/client/latest/ZoomInstallerFull.msi?archType=x64'
$ExpectedSHA256 = ''
$ForceReinstall = $false
$LogFile        = 'C:\ProgramData\MDM\Logs\zoom-install.log'
# =============================================================================

$LogDir = Split-Path $LogFile -Parent
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $line = "[$((Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ' -AsUTC))] [$Level] [Zoom] $Message"
    Write-Output $line
    Add-Content -Path $LogFile -Value $line -ErrorAction SilentlyContinue
}
function Invoke-Fatal { param([string]$m) Write-Log $m 'ERROR'; exit 1 }

Write-Log 'Starting Zoom install.'

function Test-ZoomInstalled {
    $app = Get-CimInstance Win32_Product -ErrorAction SilentlyContinue |
           Where-Object { $_.Name -like 'Zoom*' }
    return ($null -ne $app) -or (Test-Path "$env:ProgramFiles\Zoom\bin\Zoom.exe")
}

if (-not $ForceReinstall -and (Test-ZoomInstalled)) {
    Write-Log 'SKIP: Zoom already installed. No action taken.'
    exit 0
}

$TempDir = Join-Path $env:TEMP "mdm-zoom-$(New-Guid)"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
$MsiPath = Join-Path $TempDir 'ZoomInstaller.msi'

try {
    Write-Log 'Downloading Zoom MSI...'
    $wc = [System.Net.WebClient]::new()
    $wc.DownloadFile($ZoomMsiUrl, $MsiPath)
} catch { Invoke-Fatal "Download failed: $_" } finally { if ($wc) { $wc.Dispose() } }

if ($ExpectedSHA256) {
    $actual = (Get-FileHash -Path $MsiPath -Algorithm SHA256).Hash.ToLower()
    if ($actual -ne $ExpectedSHA256.ToLower()) { Invoke-Fatal "SHA256 mismatch. Got: $actual" }
    Write-Log 'SHA256 verified.'
}

Write-Log 'Installing Zoom silently...'
# ZNoDesktopShortCut=1 suppresses desktop icon; ZConfig can pass managed settings
$msiArgs = "/i `"$MsiPath`" /quiet /norestart ZNoDesktopShortCut=1 /l*v `"$LogDir\zoom-msi.log`""
$proc = Start-Process msiexec.exe -ArgumentList $msiArgs -Wait -PassThru
if ($proc.ExitCode -notin @(0, 3010)) { Invoke-Fatal "msiexec exited $($proc.ExitCode)." }

Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue

if (Test-ZoomInstalled) { Write-Log 'SUCCESS: Zoom installed.'; exit 0 }
Invoke-Fatal 'Installation did not validate.'

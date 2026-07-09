#Requires -RunAsAdministrator
<#
.SYNOPSIS Microsoft 365 Apps Windows install via Office Deployment Tool (ODT).
.DESCRIPTION
    Downloads the Office Deployment Tool and uses a configuration XML to install
    Microsoft 365 Apps silently. Customize the configuration.xml to match your
    licensed SKU and language requirements.
.NOTES Version: 1.0 | Tested: Windows 10 22H2, Windows 11 23H2
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ====== CONFIG ================================================================
# Office Deployment Tool download from Microsoft
$OdtUrl        = 'https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_17126-20132.exe'
$ExpectedSHA256 = ''   # SHA256 of the ODT exe (recommended to pin)
$ForceReinstall = $false
$LogFile        = 'C:\ProgramData\MDM\Logs\office365-install.log'

# Office configuration - customize for your org's SKU and language
# Reference: https://config.office.com/
$OfficeConfigXml = @'
<Configuration ID="mdm-installers-m365">
  <Add OfficeClientEdition="64" Channel="Current">
    <Product ID="O365BusinessRetail">
      <Language ID="MatchOS" />
      <ExcludeApp ID="Groove" />
      <ExcludeApp ID="Lync" />
    </Product>
  </Add>
  <Updates Enabled="TRUE" Channel="Current" />
  <Display Level="None" AcceptEULA="TRUE" />
  <Property Name="AUTOACTIVATE" Value="1" />
  <Logging Level="Standard" Path="%TEMP%\ODT" />
</Configuration>
'@
# =============================================================================

$LogDir = Split-Path $LogFile -Parent
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $line = "[$((Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ' -AsUTC))] [$Level] [Office365] $Message"
    Write-Output $line
    Add-Content -Path $LogFile -Value $line -ErrorAction SilentlyContinue
}
function Invoke-Fatal { param([string]$m) Write-Log $m 'ERROR'; exit 1 }

Write-Log 'Starting Microsoft 365 Apps install.'

function Test-OfficeInstalled {
    return (Test-Path 'C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE') -or
           (Test-Path 'C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.EXE')
}

if (-not $ForceReinstall -and (Test-OfficeInstalled)) {
    Write-Log 'SKIP: Microsoft 365 Apps already installed. No action taken.'
    exit 0
}

$TempDir = Join-Path $env:TEMP "mdm-office-$(New-Guid)"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
$OdtExe = Join-Path $TempDir 'OfficeDeploymentTool.exe'
$ConfigPath = Join-Path $TempDir 'configuration.xml'

try {
    Write-Log 'Downloading Office Deployment Tool...'
    $wc = [System.Net.WebClient]::new()
    $wc.DownloadFile($OdtUrl, $OdtExe)
} catch { Invoke-Fatal "ODT download failed: $_" } finally { if ($wc) { $wc.Dispose() } }

if ($ExpectedSHA256) {
    $actual = (Get-FileHash -Path $OdtExe -Algorithm SHA256).Hash.ToLower()
    if ($actual -ne $ExpectedSHA256.ToLower()) { Invoke-Fatal "SHA256 mismatch. Got: $actual" }
    Write-Log 'SHA256 verified.'
}

Write-Log 'Extracting Office Deployment Tool...'
$proc = Start-Process -FilePath $OdtExe -ArgumentList "/quiet /extract:`"$TempDir`"" -Wait -PassThru
if ($proc.ExitCode -ne 0) { Invoke-Fatal "ODT extraction failed (exit $($proc.ExitCode))." }

$SetupExe = Join-Path $TempDir 'setup.exe'
if (-not (Test-Path $SetupExe)) { Invoke-Fatal 'setup.exe not found after ODT extraction.' }

Write-Log 'Writing Office configuration.xml...'
Set-Content -Path $ConfigPath -Value $OfficeConfigXml -Encoding UTF8

Write-Log 'Installing Microsoft 365 Apps (this will take 10-30 minutes)...'
$proc = Start-Process -FilePath $SetupExe -ArgumentList "/configure `"$ConfigPath`"" -Wait -PassThru
if ($proc.ExitCode -ne 0) { Invoke-Fatal "Office setup.exe exited $($proc.ExitCode)." }

Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue

if (Test-OfficeInstalled) {
    Write-Log 'SUCCESS: Microsoft 365 Apps installed.'
    exit 0
}
Invoke-Fatal 'Office 365 installation did not validate.'

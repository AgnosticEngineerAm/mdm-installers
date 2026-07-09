#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Shared PowerShell library for MDM install/uninstall scripts.
.DESCRIPTION
    Source this file at the top of any Windows MDM script to get standardized
    logging, download helpers, hash verification, and idempotency utilities.
.NOTES
    Usage: . "$PSScriptRoot\..\..\_lib\common.ps1"
    Repository: https://github.com/CyberEnthusiastAm/mdm-installers
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# -- Logging --------------------------------------------------------------------

function Write-Log {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('INFO','WARN','ERROR')][string]$Level = 'INFO'
    )
    $timestamp = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ' -AsUTC)
    $line = "[$timestamp] [$Level] $Message"
    Write-Output $line
    # Append to log file if $script:LogFile is set
    if ($script:LogFile) {
        Add-Content -Path $script:LogFile -Value $line -ErrorAction SilentlyContinue
    }
}

function Write-LogWarn  { param([string]$Message) Write-Log -Message $Message -Level 'WARN'  }
function Write-LogError { param([string]$Message) Write-Log -Message $Message -Level 'ERROR' }

function Invoke-Fatal {
    param([string]$Message)
    Write-LogError $Message
    exit 1
}

# -- Log File Setup -------------------------------------------------------------

function Initialize-LogFile {
    param([string]$Path)
    $script:LogFile = $Path
    $logDir = Split-Path $Path -Parent
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    Write-Log "Log file: $Path"
}

# -- Downloads ------------------------------------------------------------------

function Get-RemoteFile {
    <#
    .SYNOPSIS Downloads a file from a URL with retry logic.
    .PARAMETER Url        Source URL.
    .PARAMETER Destination Local path to save the file.
    .PARAMETER Label      Human-readable label for log output.
    #>
    param(
        [Parameter(Mandatory)][string]$Url,
        [Parameter(Mandatory)][string]$Destination,
        [string]$Label = 'file'
    )
    Write-Log "Downloading $Label from $Url ..."
    $maxRetries = 3
    $attempt = 0
    while ($attempt -lt $maxRetries) {
        try {
            $attempt++
            $webClient = [System.Net.WebClient]::new()
            $webClient.DownloadFile($Url, $Destination)
            Write-Log "Download complete: $Destination"
            return
        }
        catch {
            if ($attempt -ge $maxRetries) {
                Invoke-Fatal "Download failed after $maxRetries attempts: $_"
            }
            Write-LogWarn "Download attempt $attempt failed: $_. Retrying in 3s..."
            Start-Sleep -Seconds 3
        }
        finally {
            if ($webClient) { $webClient.Dispose() }
        }
    }
}

# -- Hash Verification ----------------------------------------------------------

function Test-FileHash {
    <#
    .SYNOPSIS Verifies a file's SHA256 hash. No-op if ExpectedHash is empty.
    #>
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [string]$ExpectedHash
    )
    if ([string]::IsNullOrWhiteSpace($ExpectedHash)) {
        Write-LogWarn 'ExpectedSHA256 not set; skipping hash verification.'
        return
    }
    $actual = (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash.ToLower()
    if ($actual -ne $ExpectedHash.ToLower()) {
        Invoke-Fatal "SHA256 mismatch. Expected: $ExpectedHash  Got: $actual"
    }
    Write-Log "SHA256 verified: $actual"
}

# -- Temp Directory -------------------------------------------------------------

function New-TempDir {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    <#
    .SYNOPSIS Creates and returns a unique temp directory path under %TEMP%.
    #>
    $dir = Join-Path $env:TEMP "mdm-install-$(New-Guid)"
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Write-Log "Temp directory: $dir"
    return $dir
}

function Remove-TempDir {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$Path)
    if (Test-Path $Path) {
        Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Temp directory cleaned up: $Path"
    }
}

# -- MSI/EXE Install Helpers ----------------------------------------------------

function Install-Msi {
    <#
    .SYNOPSIS Silently installs an .msi file using msiexec.
    #>
    param(
        [Parameter(Mandatory)][string]$MsiPath,
        [string]$AdditionalArgs = ''
    )
    Write-Log "Installing MSI silently: $MsiPath"
    $msiArgs = "/i `"$MsiPath`" /quiet /norestart /l*v `"$script:LogFile.msi.log`" $AdditionalArgs".Trim()
    $proc = Start-Process -FilePath 'msiexec.exe' -ArgumentList $msiArgs -Wait -PassThru
    if ($proc.ExitCode -notin @(0, 3010)) {
        Invoke-Fatal "msiexec.exe exited with code $($proc.ExitCode). Check $script:LogFile.msi.log"
    }
    if ($proc.ExitCode -eq 3010) {
        Write-LogWarn "MSI install returned 3010 (reboot required). A restart may be needed."
    }
    Write-Log "MSI install complete."
}

function Install-Exe {
    <#
    .SYNOPSIS Silently runs an .exe installer.
    #>
    param(
        [Parameter(Mandatory)][string]$ExePath,
        [Parameter(Mandatory)][string[]]$Arguments,
        [int[]]$SuccessExitCodes = @(0, 3010)
    )
    Write-Log "Running EXE silently: $ExePath"
    $proc = Start-Process -FilePath $ExePath -ArgumentList $Arguments -Wait -PassThru
    if ($proc.ExitCode -notin $SuccessExitCodes) {
        Invoke-Fatal "Installer exited with code $($proc.ExitCode)."
    }
    Write-Log "EXE install complete (exit code: $($proc.ExitCode))."
}

# -- System Info ----------------------------------------------------------------

function Get-OsInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    return "$($os.Caption) $($os.Version) ($($os.OSArchitecture))"
}

Write-Log "mdm-installers common library loaded. OS: $(Get-OsInfo)"

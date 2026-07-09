<#
.SYNOPSIS
Firefox Enterprise Windows MDM Install
#>
$FirefoxMsiUrl = "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US"
$ExpectedSha256 = ""

. "$PSScriptRoot\..\_lib\common.ps1"
Write-Log "Installing Mozilla Firefox..."

if (Get-CimInstance Win32_Product | Where-Object Name -match "Mozilla Firefox") {
    Write-Log "SKIP: Firefox is already installed."
    exit 0
}

$msiPath = Download-File -Url $FirefoxMsiUrl -ExpectedSha256 $ExpectedSha256
Install-Msi -MsiPath $msiPath
Write-Log "SUCCESS: Firefox installed."

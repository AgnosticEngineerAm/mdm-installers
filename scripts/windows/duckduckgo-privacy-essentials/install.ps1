<#
.SYNOPSIS
DuckDuckGo Privacy Essentials Enterprise Windows MDM Install
#>
$MsiUrl = "PASTE_YOUR_WIN_URL_FOR_DUCKDUCKGO_PRIVACY_ESSENTIALS_HERE"
$ExpectedSha256 = ""

. "$PSScriptRoot\..\_lib\common.ps1"
Write-Log "Installing DuckDuckGo Privacy Essentials..."

$msiPath = Download-File -Url $MsiUrl -ExpectedSha256 $ExpectedSha256
Install-Msi -MsiPath $msiPath
Write-Log "SUCCESS: DuckDuckGo Privacy Essentials installed."

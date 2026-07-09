<#
.SYNOPSIS
Forticlient Enterprise Windows MDM Install
#>
$MsiUrl = "PASTE_YOUR_WIN_URL_FOR_FORTICLIENT_HERE"
$ExpectedSha256 = ""

. "$PSScriptRoot\..\_lib\common.ps1"
Write-Log "Installing Forticlient..."

$msiPath = Download-File -Url $MsiUrl -ExpectedSha256 $ExpectedSha256
Install-Msi -MsiPath $msiPath
Write-Log "SUCCESS: Forticlient installed."

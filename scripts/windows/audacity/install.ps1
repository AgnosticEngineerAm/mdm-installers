<#
.SYNOPSIS
Audacity Enterprise Windows MDM Install
#>
$MsiUrl = "PASTE_YOUR_WIN_URL_FOR_AUDACITY_HERE"
$ExpectedSha256 = ""

. "$PSScriptRoot\..\_lib\common.ps1"
Write-Log "Installing Audacity..."

$msiPath = Download-File -Url $MsiUrl -ExpectedSha256 $ExpectedSha256
Install-Msi -MsiPath $msiPath
Write-Log "SUCCESS: Audacity installed."

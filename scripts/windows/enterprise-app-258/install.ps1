<#
.SYNOPSIS
Enterprise App 258 Enterprise Windows MDM Install
#>
$MsiUrl = "PASTE_WIN_URL_HERE"
$ExpectedSha256 = ""

. "$PSScriptRoot\..\_lib\common.ps1"
Write-Log "Installing Enterprise App 258..."

$msiPath = Download-File -Url $MsiUrl -ExpectedSha256 $ExpectedSha256
Install-Msi -MsiPath $msiPath
Write-Log "SUCCESS: Enterprise App 258 installed."

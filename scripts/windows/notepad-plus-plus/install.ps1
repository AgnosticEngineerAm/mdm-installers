<#
.SYNOPSIS
Notepad Plus Plus Enterprise Windows MDM Install
#>
$MsiUrl = "PASTE_YOUR_WIN_URL_FOR_NOTEPAD_PLUS_PLUS_HERE"
$ExpectedSha256 = ""

. "$PSScriptRoot\..\_lib\common.ps1"
Write-Log "Installing Notepad Plus Plus..."

$msiPath = Download-File -Url $MsiUrl -ExpectedSha256 $ExpectedSha256
Install-Msi -MsiPath $msiPath
Write-Log "SUCCESS: Notepad Plus Plus installed."

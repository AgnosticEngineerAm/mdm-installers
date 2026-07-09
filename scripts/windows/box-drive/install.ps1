<#
.SYNOPSIS
Box Drive Enterprise Windows MDM Install
#>
$MsiUrl = "PASTE_YOUR_WIN_URL_FOR_BOX_DRIVE_HERE"
$ExpectedSha256 = ""

. "$PSScriptRoot\..\_lib\common.ps1"
Write-Log "Installing Box Drive..."

$msiPath = Download-File -Url $MsiUrl -ExpectedSha256 $ExpectedSha256
Install-Msi -MsiPath $msiPath
Write-Log "SUCCESS: Box Drive installed."

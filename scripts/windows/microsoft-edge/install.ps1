<#
.SYNOPSIS
Microsoft Edge Enterprise Windows MDM Install
#>
$EdgeMsiUrl = "https://go.microsoft.com/fwlink/?linkid=2093437"
$ExpectedSha256 = ""

. "$PSScriptRoot\..\_lib\common.ps1"
Write-Log "Installing Microsoft Edge..."

if (Get-CimInstance Win32_Product | Where-Object Name -match "Microsoft Edge") {
    Write-Log "SKIP: Microsoft Edge is already installed."
    exit 0
}

$msiPath = Download-File -Url $EdgeMsiUrl -ExpectedSha256 $ExpectedSha256
Install-Msi -MsiPath $msiPath
Write-Log "SUCCESS: Microsoft Edge installed."

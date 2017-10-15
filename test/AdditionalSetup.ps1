Write-Host "Installing $extension"
<#
Import-Module 'C:\Program Files\Microsoft Dynamics NAV\*\Service\Microsoft.Dynamics.Nav.Apps.Management.psd1'
$extension = "FieldSecurity.navx"
Write-Host "Publishing $extension"
Publish-NAVApp -ServerInstance NAV -Path (Join-Path $PSScriptRoot $extension) -SkipVerification
Write-Host "Installing $extension"
 
Install-NAVApp -ServerInstance NAV -Path (Join-Path $PSScriptRoot $extension)
#>

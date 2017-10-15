Write-Host "This is a message from AdditionalOutput"

#Install CSide Client
if (!(Test-Path "$myPath\RoleTailored Client" -PathType Container)) {
    Write-Host "Copy RoleTailoted Client files"
    Copy-Item -path $roleTailoredClientFolder -destination $myPath -force -Recurse -ErrorAction Ignore
}

#import Objects
Import-Module "C:\Program Files (x86)\Microsoft Dynamics NAV\*\RoleTailored Client\Microsoft.Dynamics.Nav.Ide.psm1" -wa SilentlyContinue
$objects = "FLS_101017.fob"
$password = "NavDevPre@2017"
Write-Host "Import $objects"
Import-NAVApplicationObject -DatabaseServer "localhost" `
                            -DatabaseName "FinancialsUS" `
                            -Path (Join-Path $PSScriptRoot $objects) `
                            -ImportAction Overwrite `
                            -SynchronizeSchemaChanges Force `
                            -NavServerName "localhost" `
                            -NavServerInstance "NAV" `
                            -username "SA" `
                            -Password $password `
                            -confirm:$false

<#
Import-Module 'C:\Program Files\Microsoft Dynamics NAV\*\Service\Microsoft.Dynamics.Nav.Apps.Management.psd1'
$extension = "myextension.navx"
Write-Host "Publishing $extension"
Publish-NAVApp -ServerInstance NAV -Path (Join-Path $PSScriptRoot $extension) -SkipVerification
Write-Host "Installing $extension"
 
Install-NAVApp -ServerInstance NAV -Path (Join-Path $PSScriptRoot $extension)
#>


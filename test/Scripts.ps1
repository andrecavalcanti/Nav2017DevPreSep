dir

docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"
docker ps -a
docker stop myserver
docker start myserver
#docker rm myserver
find-module | where Author -EQ waldo

Enter-PSSession -ContainerId (docker ps --no-trunc -qf "name=myserver")
Import-Module "C:\Program Files\Microsoft Dynamics NAV\110\Service\NavAdminTool.ps1"
Import-Module "C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client\NavModelTools.ps1"
Get-Navserverinstance
Get-NAvServerConfiguration
Set-ExecutionPolicy unrestricted -Force
Export-NavContainerObjects
Export-NavContainerObjects -containername myserver -objectsfolder c:\demo\objects -adminpassword NavDevPre@2017 -filter "Modified=Yes"
Import-NAVServerLicense -ServerInstance NAV -LicenseFile C:\run\my\888.flf
Import-NAVApplicationObject -DatabaseName FinancialsUS -Password NavDevPre@2017 -Path c:\run\my\objects.fob -Username sa



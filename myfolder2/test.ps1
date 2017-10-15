Export-NavContainerObjects -containername myserver -objectsfolder c:\demo\objects -adminpassword NavDevPre@2017 -filter "Modified=Yes;ID=70018000..70018013"
#Import-NAVApplicationObject -DatabaseName FinancialsUS -Password NavDevPre@2017 -Path c:\run\my\objects.fob -Username sa -ImportAction Overwrite
#Import-Module "C:\Program Files\Microsoft Dynamics NAV\110\Service\NavAdminTool.ps1"
#Import-NAVApplicationObject -DatabaseName FinanceUS -Path C:\Run\my\objects.fob -DatabaseServer MYSERVER\SQLEXPRESS -NavServerInstance NAV -NavServerManagementPort 7045
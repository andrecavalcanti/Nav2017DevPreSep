param ([string] $NavIde)

# If $NavIde is not provided try to find finsql in:
#    1) the current folder, or
#    2) RTC's installation folder.
if (-not $NavIde)
{
    if (Test-Path (Join-Path $PSScriptRoot finsql.exe))
    {
        $NavIde = (Join-Path $PSScriptRoot finsql.exe)
    }
    else
    {
        if ([Environment]::Is64BitProcess)
        {
            $RtcKey = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Microsoft Dynamics NAV\110\RoleTailored Client'
        }
        else
        {
            $RtcKey = 'HKLM:\SOFTWARE\Microsoft\Microsoft Dynamics NAV\110\RoleTailored Client'
        }

        if (Test-Path $RtcKey)
        {
            $NavIde = (Join-Path (Get-ItemProperty $RtcKey).Path finsql.exe)
        }
    }
}

if ($NavIde -and (Test-Path $NavIde))
{
	$NavClientPath = (Get-Item $NavIde).DirectoryName
}

<#
    .SYNOPSIS
    Imports NAV application objects from a file into a database.

    .DESCRIPTION
    The Import-NAVApplicationObject function imports the objects from the specified file(s) into the specified database. When multiple files are specified, finsql is invoked for each file. For better performance the files can be joined first. However, using seperate files can be useful for analyzing import errors.

    .INPUTS
    System.String[]
    You can pipe a path to the Import-NavApplicationObject function.

    .OUTPUTS
    None

    .EXAMPLE
    Import-NAVApplicationObject MyAppSrc.txt MyApp
    This command imports all application objects in MyAppSrc.txt into the MyApp database.

    .EXAMPLE
    Import-NAVApplicationObject MyAppSrc.txt -DatabaseName MyApp
    This command imports all application objects in MyAppSrc.txt into the MyApp database.

    .EXAMPLE
    Get-ChildItem MyAppSrc | Import-NAVApplicationObject -DatabaseName MyApp
    This commands imports all objects in all files in the MyAppSrc folder into the MyApp database. The files are imported one by one.

    .EXAMPLE
    Get-ChildItem MyAppSrc | Join-NAVApplicationObject -Destination .\MyAppSrc.txt -PassThru | Import-NAVApplicationObject -Database MyApp
    This commands joins all objects in all files in the MyAppSrc folder into a single file and then imports them in the MyApp database.
#>
function Import-NAVApplicationObject
{
    [CmdletBinding(DefaultParameterSetName="All", SupportsShouldProcess=$true, ConfirmImpact='High')]
    Param(
        # Specifies one or more files to import.
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('PSPath')]
        [string[]] $Path,

        # Specifies the name of the database into which you want to import.
        [Parameter(Mandatory=$true, Position=1)]
        [string] $DatabaseName,

        # Specifies the name of the SQL server instance to which the database you want to import into is attached. The default value is the default instance on the local host (.).
        [ValidateNotNullOrEmpty()]
        [string] $DatabaseServer = '.',

        # Specifies the log folder.
        [ValidateNotNullOrEmpty()]
        [string] $LogPath = "$Env:TEMP\NavIde\$([GUID]::NewGuid().GUID)",

        # Specifies the import action. The default value is 'Default'.
        [ValidateSet('Default','Overwrite','Skip')] [string] $ImportAction = 'Default',

        # Specifies the schema synchronization behaviour. The default value is 'Yes'.
        [ValidateSet('Yes','No','Force')] [string] $SynchronizeSchemaChanges = 'Yes',

        # The user name to use to authenticate to the database. The user name must exist in the database. If you do not specify a user name and password, then the command uses the credentials of the current Windows user to authenticate to the database.
        [Parameter(Mandatory=$true, ParameterSetName="DatabaseAuthentication")]
        [string] $Username,

        # The password to use with the username parameter to authenticate to the database. If you do not specify a user name and password, then the command uses the credentials of the current Windows user to authenticate to the database.
        [Parameter(Mandatory=$true, ParameterSetName="DatabaseAuthentication")]
        [string] $Password,

        # Specifies the name of the server that hosts the Microsoft Dynamics NAV Server instance, such as MyServer.
        [ValidateNotNullOrEmpty()]
        [string] $NavServerName,

        # Specifies the Microsoft Dynamics NAV Server instance that is being used.The default value is DynamicsNAV90.
        [ValidateNotNullOrEmpty()]
        [string] $NavServerInstance = "DynamicsNAV90",

        # Specifies the port on the Microsoft Dynamics NAV Server server that the Microsoft Dynamics NAV Windows PowerShell cmdlets access. The default value is 7045.
        [ValidateNotNullOrEmpty()]
        [int16]  $NavServerManagementPort = 7045)

    PROCESS
    {
        if ($Path.Count -eq 1)
        {
            $Path = (Get-Item $Path).FullName
        }

        if ($PSCmdlet.ShouldProcess(
            "Import application objects from $Path into the $DatabaseName database.",
            "Import application objects from $Path into the $DatabaseName database. If you continue, you may lose data in fields that are removed or changed in the imported file.",
            'Confirm'))
        {
            $navServerInfo = GetNavServerInfo $NavServerName $NavServerInstance $NavServerManagementPort

            foreach ($file in $Path)
            {
                # Log file name is based on the name of the imported file.
                $logFile = "$LogPath\$((Get-Item $file).BaseName).log"
                $command = "Command=ImportObjects`,ImportAction=$ImportAction`,SynchronizeSchemaChanges=$SynchronizeSchemaChanges`,File=`"$file`""

                try
                {
                    RunNavIdeCommand -Command $command `
                                     -DatabaseServer $DatabaseServer `
                                     -DatabaseName $DatabaseName `
                                     -NTAuthentication:($Username -eq $null) `
                                     -Username $Username `
                                     -Password $Password `
                                     -NavServerInfo $navServerInfo `
                                     -LogFile $logFile `
                                     -ErrText "Error while importing $file" `
                                     -Verbose:$VerbosePreference
                }
                catch
                {
                    Write-Error $_
                }
            }
        }
    }
}

function GetNavServerInfo
(
    [string] $NavServerName,
    [string] $NavServerInstance,
    [int16]  $NavServerManagementPort
)
{
    $navServerInfo = ""
    if ($navServerName)
    {
        $navServerInfo = @"
`,NavServerName="$NavServerName"`,NavServerInstance="$NavServerInstance"`,NavServerManagementport=$NavServerManagementPort
"@
    }

    $navServerInfo
}

function RunNavIdeCommand
{
    [CmdletBinding()]
    Param(
    [string] $Command,
    [string] $DatabaseServer,
    [string] $DatabaseName,
    [switch] $NTAuthentication,
    [string] $Username,
    [string] $Password,
    [string] $NavServerInfo,
    [string] $LogFile,
    [string] $ErrText)

    TestNavIde
    $logPath = (Split-Path $LogFile)

    Remove-Item "$logPath\navcommandresult.txt" -ErrorAction Ignore
    Remove-Item $logFile -ErrorAction Ignore

    $databaseInfo = @"
ServerName="$DatabaseServer"`,Database="$DatabaseName"
"@
    if ($Username)
    {
        $databaseInfo = @"
ntauthentication=No`,username="$Username"`,password="$Password"`,$databaseInfo
"@
    }

    $finSqlCommand = @"
& "$NavIde" --% $Command`,LogFile="$logFile"`,${databaseInfo}${NavServerInfo} | Out-Null
"@

    Write-Verbose "Running command: $finSqlCommand"
    Invoke-Expression -Command  $finSqlCommand

    if (Test-Path "$logPath\navcommandresult.txt")
    {
        if (Test-Path $LogFile)
        {
            throw "${ErrorText}: $(Get-Content $LogFile -Raw)" -replace "`r[^`n]","`r`n"
        }
    }
    else
    {
        throw "${ErrorText}!"
    }
}

<#
    .SYNOPSIS
    Export NAV application objects from a database into a file.

    .DESCRIPTION
    The Export-NAVApplicationObject function exports the objects from the specified database into the specified file. A filter can be specified to select the application objects to be exported.

    .INPUTS
    None
    You cannot pipe input to this function.

    .OUTPUTS
    System.IO.FileInfo
    An object representing the exported file.

    .EXAMPLE
    Export-NAVApplicationObject MyApp MyAppSrc.txt
    Exports all application objects from the MyApp database to MyAppSrc.txt.

    .EXAMPLE
    Export-NAVApplicationObject MyAppSrc.txt -DatabaseName MyApp
    Exports all application objects from the MyApp database to MyAppSrc.txt.

    .EXAMPLE
    Export-NAVApplicationObject MyApp COD1-10.txt -Filter 'Type=Codeunit;Id=1..10'
    Exports codeunits 1..10 from the MyApp database to COD1-10.txt

    .EXAMPLE
    Export-NAVApplicationObject COD1-10.txt -DatabaseName MyApp -Filter 'Type=Codeunit;Id=1..10'
    Exports codeunits 1..10 from the MyApp database to COD1-10.txt

    .EXAMPLE
    Export-NAVApplicationObject COD1-10.txt -DatabaseName MyApp -Filter 'Type=Codeunit;Id=1..10' | Import-NAVApplicationObject -DatabaseName MyApp2
    Copies codeunits 1..10 from the MyApp database to the MyApp2 database.

    .EXAMPLE
    Export-NAVApplicationObject MyAppSrc.txt -DatabaseName MyApp | Split-NAVApplicationObject -Destination MyAppSrc
    Exports all application objects from the MyApp database and splits into single-object files in the MyAppSrc folder.
#>
function Export-NAVApplicationObject
{
    [CmdletBinding(DefaultParameterSetName="All",SupportsShouldProcess = $true)]
    Param(
        # Specifies the name of the database from which you want to export.
        [Parameter(Mandatory=$true, Position=0)]
        [string] $DatabaseName,

        # Specifies the file to export to.
        [Parameter(Mandatory=$true, Position=1)]
        [string] $Path,

        # Specifies the name of the SQL server instance to which the database you want to import into is attached. The default value is the default instance on the local host (.).
        [ValidateNotNullOrEmpty()]
        [string] $DatabaseServer = '.',

        # Specifies the log folder.
        [ValidateNotNullOrEmpty()]
        [string] $LogPath = "$Env:TEMP\NavIde\$([GUID]::NewGuid().GUID)",

        # Specifies the filter that selects the objects to export.
        [string] $Filter,

        # Allows the command to create a file that overwrites an existing file.
        [Switch] $Force,

        # Allows the command to skip application objects that are excluded from license, when exporting as txt.
        [Switch] $ExportTxtSkipUnlicensed,

        # Export the application object to the syntax supported by the Txt2Al converter.
        [Switch] $ExportToNewSyntax,

        # The user name to use to authenticate to the database. The user name must exist in the database. If you do not specify a user name and password, then the command uses the credentials of the current Windows user to authenticate to the database.
        [Parameter(Mandatory=$true, ParameterSetName="DatabaseAuthentication")]
        [string] $Username,

        # The password to use with the username parameter to authenticate to the database. If you do not specify a user name and password, then the command uses the credentials of the current Windows user to authenticate to the database.
        [Parameter(Mandatory=$true, ParameterSetName="DatabaseAuthentication")]
        [string] $Password)

    if ($PSCmdlet.ShouldProcess(
        "Export application objects from $DatabaseName database to $Path.",
        "Export application objects from $DatabaseName database to $Path.",
        'Confirm'))
    {
        if (!$Force -and (Test-Path $Path) -and !$PSCmdlet.ShouldContinue(
            "$Path already exists. If you continue, $Path will be overwritten.",
            'Confirm'))
        {
            Write-Error "$Path already exists."
            return
        }
    }
    else
    {
        return
    }

    $skipUnlicensed = "0"
    if($ExportTxtSkipUnlicensed)
    {
        $skipUnlicensed = "1"
    }

    $exportCommand = "ExportObjects"
    if($ExportToNewSyntax)
    {
        $exportCommand = "ExportToNewSyntax"
    }

    $command = "Command=$exportCommand`,ExportTxtSkipUnlicensed=$skipUnlicensed`,File=`"$Path`""
    if($Filter)
    {
        $command = "$command`,Filter=`"$Filter`""
    }

    $logFile = (Join-Path $logPath naverrorlog.txt)

    try
    {
        RunNavIdeCommand -Command $command `
                         -DatabaseServer $DatabaseServer `
                         -DatabaseName $DatabaseName `
                         -NTAuthentication:($Username -eq $null) `
                         -Username $Username `
                         -Password $Password `
                         -NavServerInfo "" `
                         -LogFile $logFile `
                         -ErrText "Error while exporting $Filter" `
                         -Verbose:$VerbosePreference
        Get-Item $Path
    }
    catch
    {
        Write-Error $_
    }
}

<#
    .SYNOPSIS
    Deletes NAV application objects from a database.

    .DESCRIPTION
    The Delete-NAVApplicationObject function deletes objects from the specified database. A filter can be specified to select the application objects to be deleted.

    .INPUTS
    None
    You cannot pipe input to this function.

    .OUTPUTS
    None

    .EXAMPLE
    Delete-NAVApplicationObject -DatabaseName MyApp -Filter 'Type=Codeunit;Id=1..10'
    Deletes codeunits 1..10 from the MyApp database
#>
function Delete-NAVApplicationObject
{
    [CmdletBinding(DefaultParameterSetName="All", SupportsShouldProcess=$true, ConfirmImpact='High')]
    Param(
        # Specifies the name of the database from which you want to delete objects.
        [Parameter(Mandatory=$true, Position=0)]
        [string] $DatabaseName,

        # Specifies the name of the SQL server instance to which the database you want to delete objects from is attached. The default value is the default instance on the local host (.).
        [ValidateNotNullOrEmpty()]
        [string] $DatabaseServer = '.',

        # Specifies the log folder.
        [ValidateNotNullOrEmpty()]
        [string] $LogPath = "$Env:TEMP\NavIde\$([GUID]::NewGuid().GUID)",

        # Specifies the filter that selects the objects to delete.
        [string] $Filter,

        # Specifies the schema synchronization behaviour. The default value is 'Yes'.
        [ValidateSet('Yes','No','Force')]
        [string] $SynchronizeSchemaChanges = 'Yes',

        # The user name to use to authenticate to the database. The user name must exist in the database. If you do not specify a user name and password, then the command uses the credentials of the current Windows user to authenticate to the database.
        [Parameter(Mandatory=$true, ParameterSetName="DatabaseAuthentication")]
        [string] $Username,

        # The password to use with the username parameter to authenticate to the database. If you do not specify a user name and password, then the command uses the credentials of the current Windows user to authenticate to the database.
        [Parameter(Mandatory=$true, ParameterSetName="DatabaseAuthentication")]
        [string] $Password,

        # Specifies the name of the server that hosts the Microsoft Dynamics NAV Server instance, such as MyServer.
        [ValidateNotNullOrEmpty()]
        [string] $NavServerName,

        # Specifies the Microsoft Dynamics NAV Server instance that is being used.The default value is DynamicsNAV90.
        [ValidateNotNullOrEmpty()]
        [string] $NavServerInstance = "DynamicsNAV90",

        # Specifies the port on the Microsoft Dynamics NAV Server server that the Microsoft Dynamics NAV Windows PowerShell cmdlets access. The default value is 7045.
        [ValidateNotNullOrEmpty()]
        [int16]  $NavServerManagementPort = 7045)

    if ($PSCmdlet.ShouldProcess(
        "Delete application objects from $DatabaseName database.",
        "Delete application objects from $DatabaseName database.",
        'Confirm'))
    {
        $command = "Command=DeleteObjects`,SynchronizeSchemaChanges=$SynchronizeSchemaChanges"
        if($Filter)
        {
            $command = "$command`,Filter=`"$Filter`""
        }

        $logFile = (Join-Path $logPath naverrorlog.txt)
        $navServerInfo = GetNavServerInfo $NavServerName $NavServerInstance $NavServerManagementPort

        try
        {
            RunNavIdeCommand -Command $command `
                             -DatabaseServer $DatabaseServer `
                             -DatabaseName $DatabaseName `
                             -NTAuthentication:($Username -eq $null) `
                             -Username $Username `
                             -Password $Password `
                             -NavServerInfo $navServerInfo `
                             -LogFile $logFile `
                             -ErrText "Error while deleting $Filter" `
                             -Verbose:$VerbosePreference
        }
        catch
        {
            Write-Error $_
        }
    }
}

<#
    .SYNOPSIS
    Compiles NAV application objects in a database.

    .DESCRIPTION
    The Compile-NAVApplicationObject function compiles application objects in the specified database. A filter can be specified to select the application objects to be compiled. Unless the Recompile switch is used only uncompiled objects are compiled.

    .INPUTS
    None
    You cannot pipe input to this function.

    .OUTPUTS
    None

    .EXAMPLE
    Compile-NAVApplicationObject MyApp
    Compiles all uncompiled application objects in the MyApp database.

    .EXAMPLE
    Compile-NAVApplicationObject MyApp -Filter 'Type=Codeunit' -Recompile
    Compiles all codeunits in the MyApp database.

    .EXAMPLE
    'Page','Codeunit','Table','XMLport','Report' | % { Compile-NAVApplicationObject -Database MyApp -Filter "Type=$_" -AsJob } | Receive-Job -Wait
    Compiles all uncompiled Pages, Codeunits, Tables, XMLports, and Reports in the MyApp database in parallel and wait until it is done. Note that some objects may remain uncompiled due to race conditions. Those remaining objects can be compiled in a seperate command.

#>
function Compile-NAVApplicationObject
{
    [CmdletBinding(DefaultParameterSetName="All")]
    Param(
        # Specifies the name of the Dynamics NAV database.
        [Parameter(Mandatory=$true, Position=0)]
        [string] $DatabaseName,

        # Specifies the name of the SQL server instance to which the Dynamics NAV database is attached. The default value is the default instance on the local host (.).
        [ValidateNotNullOrEmpty()]
        [string] $DatabaseServer = '.',

        # Specifies the log folder.
        [ValidateNotNullOrEmpty()]
        [string] $LogPath = "$Env:TEMP\NavIde\$([GUID]::NewGuid().GUID)",

        # Specifies the filter that selects the objects to compile.
        [string] $Filter,

        # Compiles objects that are already compiled.
        [Switch] $Recompile,

        # Compiles in the background returning an object that represents the background job.
        [Switch] $AsJob,

        # Specifies the schema synchronization behaviour. The default value is 'Yes'.
        [ValidateSet('Yes','No','Force')]
        [string] $SynchronizeSchemaChanges = 'Yes',

        # The user name to use to authenticate to the database. The user name must exist in the database. If you do not specify a user name and password, then the command uses the credentials of the current Windows user to authenticate to the database.
        [Parameter(Mandatory=$true, ParameterSetName="DatabaseAuthentication")]
        [string] $Username,

        # The password to use with the username parameter to authenticate to the database. If you do not specify a user name and password, then the command uses the credentials of the current Windows user to authenticate to the database.
        [Parameter(Mandatory=$true, ParameterSetName="DatabaseAuthentication")]
        [string] $Password,

        # Specifies the name of the server that hosts the Microsoft Dynamics NAV Server instance, such as MyServer.
        [ValidateNotNullOrEmpty()]
        [string] $NavServerName,

        # Specifies the Microsoft Dynamics NAV Server instance that is being used.The default value is DynamicsNAV90.
        [ValidateNotNullOrEmpty()]
        [string] $NavServerInstance = "DynamicsNAV90",

        # Specifies the port on the Microsoft Dynamics NAV Server server that the Microsoft Dynamics NAV Windows PowerShell cmdlets access. The default value is 7045.
        [ValidateNotNullOrEmpty()]
        [int16]  $NavServerManagementPort = 7045)

    if (-not $Recompile)
    {
        $Filter += ';Compiled=0'
        $Filter = $Filter.TrimStart(';')
    }

    if ($AsJob)
    {
        $LogPath = "$LogPath\$([GUID]::NewGuid().GUID)"
        Remove-Item $LogPath -ErrorAction Ignore -Recurse -Confirm:$False -Force
        $scriptBlock =
        {
            Param($ScriptPath,$NavIde,$DatabaseName,$DatabaseServer,$LogPath,$Filter,$Recompile,$SynchronizeSchemaChanges,$Username,$Password,$NavServerName,$NavServerInstance,$NavServerManagementPort,$VerbosePreference)

            Import-Module "$ScriptPath\Microsoft.Dynamics.Nav.Ide.psm1" -ArgumentList $NavIde -Force -DisableNameChecking

            $args = @{
                DatabaseName = $DatabaseName
                DatabaseServer = $DatabaseServer
                LogPath = $LogPath
                Filter = $Filter
                Recompile = $Recompile
                SynchronizeSchemaChanges = $SynchronizeSchemaChanges
            }

            if($Username)
            {
                $args.Add("Username",$Username)
                $args.Add("Password",$Password)
            }

            if($NavServerName)
            {
                $args.Add("NavServerName",$NavServerName)
                $args.Add("NavServerInstance",$NavServerInstance)
                $args.Add("NavServerManagementPort",$NavServerManagementPort)
            }

            Compile-NAVApplicationObject @args -Verbose:$VerbosePreference
        }

        $job = Start-Job $scriptBlock -ArgumentList $PSScriptRoot,$NavIde,$DatabaseName,$DatabaseServer,$LogPath,$Filter,$Recompile,$SynchronizeSchemaChanges,$Username,$Password,$NavServerName,$NavServerInstance,$NavServerManagementPort,$VerbosePreference
        return $job
    }
    else
    {
        try
        {
            $logFile = (Join-Path $LogPath naverrorlog.txt)
            $navServerInfo = GetNavServerInfo $NavServerName $NavServerInstance $NavServerManagementPort
            $command = "Command=CompileObjects`,SynchronizeSchemaChanges=$SynchronizeSchemaChanges"
            if($Filter)
            {
                $command = "$command,Filter=`"$Filter`""
            }

            RunNavIdeCommand -Command $command `
                             -DatabaseServer $DatabaseServer `
                             -DatabaseName $DatabaseName `
                             -NTAuthentication:($Username -eq $null) `
                             -Username $Username `
                             -Password $Password `
                             -NavServerInfo $navServerInfo `
                             -LogFile $logFile `
                             -ErrText "Error while compiling $Filter" `
                             -Verbose:$VerbosePreference
        }
        catch
        {
            Write-Error $_
        }
    }
}

<#
    .SYNOPSIS
    Creates a new NAV application database.

    .DESCRIPTION
    The Create-NAVDatabase creates a new NAV database that includes the NAV system tables.

    .INPUTS
    None
    You cannot pipe input into this function.

    .OUTPUTS
    None

    .EXAMPLE
    Create-NAVDatabase MyNewApp
    Creates a new NAV database named MyNewApp.

    .EXAMPLE
    Create-NAVDatabase MyNewApp -ServerName "TestComputer01\NAVDEMO" -Collation "da-dk"
    Creates a new NAV database named MyNewApp on TestComputer01\NAVDEMO Sql server with Danish collation.
#>
function Create-NAVDatabase
{
    [CmdletBinding(DefaultParameterSetName="All")]
    Param(
         # Specifies the name of the Dynamics NAV database that will be created.
        [Parameter(Mandatory=$true, Position=0)]
        [string] $DatabaseName,

        # Specifies the name of the SQL server instance on which you want to create the database. The default value is the default instance on the local host (.).
        [ValidateNotNullOrEmpty()]
        [string] $DatabaseServer = '.',

        # Specifies the collation of the database.
        [ValidateNotNullOrEmpty()]
        [string] $Collation,

        # Specifies the log folder.
        [ValidateNotNullOrEmpty()]
        [string] $LogPath = "$Env:TEMP\NavIde\$([GUID]::NewGuid().GUID)",


        # The user name to use to authenticate to the database. The user name must exist in the database. If you do not specify a user name and password, then the command uses the credentials of the current Windows user to authenticate to the database.
        [Parameter(Mandatory=$true, ParameterSetName="DatabaseAuthentication")]
        [string] $Username,

        # The password to use with the username parameter to authenticate to the database. If you do not specify a user name and password, then the command uses the credentials of the current Windows user to authenticate to the database.
        [Parameter(Mandatory=$true, ParameterSetName="DatabaseAuthentication")]
        [string] $Password)

    $logFile = (Join-Path $LogPath naverrorlog.txt)

    $command = "Command=CreateDatabase`,Collation=$Collation"

    try
    {
        RunNavIdeCommand -Command $command `
                         -DatabaseServer $DatabaseServer `
                         -DatabaseName $DatabaseName `
                         -NTAuthentication:($Username -eq $null) `
                         -Username $Username `
                         -Password $Password `
                         -NavServerInfo $navServerInfo `
                         -LogFile $logFile `
                         -ErrText "Error while creating $DatabaseName" `
                         -Verbose:$VerbosePreference
    }
    catch
    {
        Write-Error $_
    }
}

<#
    .SYNOPSIS
    Performs a technical upgrade of a database from a previous version of Microsoft Dynamics NAV.

    .DESCRIPTION
    Performs a technical upgrade of a database from a previous version of Microsoft Dynamics NAV.

    .INPUTS
    None
    You cannot pipe input into this function.

    .OUTPUTS
    None

    .EXAMPLE
    Invoke-NAVDatabaseConversion MyApp
    Perform the technical upgrade on a NAV database named MyApp.

    .EXAMPLE
    Invoke-NAVDatabaseConversion MyApp -ServerName "TestComputer01\NAVDEMO"
    Perform the technical upgrade on a NAV database named MyApp on TestComputer01\NAVDEMO Sql server .
#>
function Invoke-NAVDatabaseConversion
{
    [CmdletBinding(DefaultParameterSetName="All")]
    Param(
         # Specifies the name of the Dynamics NAV database that will be created.
        [Parameter(Mandatory=$true, Position=0)]
        [string] $DatabaseName,

        # Specifies the name of the SQL server instance on which you want to create the database. The default value is the default instance on the local host (.).
        [ValidateNotNullOrEmpty()]
        [string] $DatabaseServer = '.',

        # Specifies the log folder.
        [ValidateNotNullOrEmpty()]
        [string] $LogPath = "$Env:TEMP\NavIde\$([GUID]::NewGuid().GUID)",

        # The user name to use to authenticate to the database. The user name must exist in the database. If you do not specify a user name and password, then the command uses the credentials of the current Windows user to authenticate to the database.
        [Parameter(Mandatory=$true, ParameterSetName="DatabaseAuthentication")]
        [string] $Username,

        # The password to use with the username parameter to authenticate to the database. If you do not specify a user name and password, then the command uses the credentials of the current Windows user to authenticate to the database.
        [Parameter(Mandatory=$true, ParameterSetName="DatabaseAuthentication")]
        [string] $Password)

    $logFile = (Join-Path $LogPath naverrorlog.txt)

    $command = "Command=UpgradeDatabase"

    try
    {
        RunNavIdeCommand -Command $command `
                         -DatabaseServer $DatabaseServer `
                         -DatabaseName $DatabaseName `
                         -NTAuthentication:($Username -eq $null) `
                         -Username $Username `
                         -Password $Password `
                         -NavServerInfo "" `
                         -LogFile $logFile `
                         -ErrText "Error while converting $DatabaseName" `
                         -Verbose:$VerbosePreference
    }
    catch
    {
        Write-Error $_
    }
}

function TestNavIde
{
    if (-not $NavIde -or (($NavIde) -and -not (Test-Path $NavIde)))
    {
        throw '$NavIde was not correctly set. Please assign the path to finsql.exe to $NavIde ($NavIde = path).'
    }
}

Export-ModuleMember -Function *-* -Variable Nav*
# SIG # Begin signature block
# MIIkRwYJKoZIhvcNAQcCoIIkODCCJDQCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAMyCO7TOrRgPE8
# nTVKlWWyFTdMC2X4efB9gpP+QCuDg6CCDZMwggYRMIID+aADAgECAhMzAAAAjoeR
# pFcaX8o+AAAAAACOMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMTYxMTE3MjIwOTIxWhcNMTgwMjE3MjIwOTIxWjCBgzEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjENMAsGA1UECxMETU9Q
# UjEeMBwGA1UEAxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEA0IfUQit+ndnGetSiw+MVktJTnZUXyVI2+lS/qxCv
# 6cnnzCZTw8Jzv23WAOUA3OlqZzQw9hYXtAGllXyLuaQs5os7efYjDHmP81LfQAEc
# wsYDnetZz3Pp2HE5m/DOJVkt0slbCu9+1jIOXXQSBOyeBFOmawJn+E1Zi3fgKyHg
# 78CkRRLPA3sDxjnD1CLcVVx3Qv+csuVVZ2i6LXZqf2ZTR9VHCsw43o17lxl9gtAm
# +KWO5aHwXmQQ5PnrJ8by4AjQDfJnwNjyL/uJ2hX5rg8+AJcH0Qs+cNR3q3J4QZgH
# uBfMorFf7L3zUGej15Tw0otVj1OmlZPmsmbPyTdo5GPHzwIDAQABo4IBgDCCAXww
# HwYDVR0lBBgwFgYKKwYBBAGCN0wIAQYIKwYBBQUHAwMwHQYDVR0OBBYEFKvI1u2y
# FdKqjvHM7Ww490VK0Iq7MFIGA1UdEQRLMEmkRzBFMQ0wCwYDVQQLEwRNT1BSMTQw
# MgYDVQQFEysyMzAwMTIrYjA1MGM2ZTctNzY0MS00NDFmLWJjNGEtNDM0ODFlNDE1
# ZDA4MB8GA1UdIwQYMBaAFEhuZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEsw
# SaBHoEWGQ2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0Nv
# ZFNpZ1BDQTIwMTFfMjAxMS0wNy0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsG
# AQUFBzAChkVodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01p
# Y0NvZFNpZ1BDQTIwMTFfMjAxMS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkq
# hkiG9w0BAQsFAAOCAgEARIkCrGlT88S2u9SMYFPnymyoSWlmvqWaQZk62J3SVwJR
# avq/m5bbpiZ9CVbo3O0ldXqlR1KoHksWU/PuD5rDBJUpwYKEpFYx/KCKkZW1v1rO
# qQEfZEah5srx13R7v5IIUV58MwJeUTub5dguXwJMCZwaQ9px7eTZ56LadCwXreUM
# tRj1VAnUvhxzzSB7pPrI29jbOq76kMWjvZVlrkYtVylY1pLwbNpj8Y8zon44dl7d
# 8zXtrJo7YoHQThl8SHywC484zC281TllqZXBA+KSybmr0lcKqtxSCy5WJ6PimJdX
# jrypWW4kko6C4glzgtk1g8yff9EEjoi44pqDWLDUmuYx+pRHjn2m4k5589jTajMW
# UHDxQruYCen/zJVVWwi/klKoCMTx6PH/QNf5mjad/bqQhdJVPlCtRh/vJQy4njpI
# BGPveJiiXQMNAtjcIKvmVrXe7xZmw9dVgh5PgnjJnlQaEGC3F6tAE5GusBnBmjOd
# 7jJyzWXMT0aYLQ9RYB58+/7b6Ad5B/ehMzj+CZrbj3u2Or2FhrjMvH0BMLd7Hald
# G73MTRf3bkcz1UDfasouUbi1uc/DBNM75ePpEIzrp7repC4zaikvFErqHsEiODUF
# he/CBAANa8HYlhRIFa9+UrC4YMRStUqCt4UqAEkqJoMnWkHevdVmSbwLnHhwCbww
# ggd6MIIFYqADAgECAgphDpDSAAAAAAADMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYD
# VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
# MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3Nv
# ZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAxMTAeFw0xMTA3MDgyMDU5
# MDlaFw0yNjA3MDgyMTA5MDlaMH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIw
# MTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCr8PpyEBwurdhuqoIQ
# TTS68rZYIZ9CGypr6VpQqrgGOBoESbp/wwwe3TdrxhLYC/A4wpkGsMg51QEUMULT
# iQ15ZId+lGAkbK+eSZzpaF7S35tTsgosw6/ZqSuuegmv15ZZymAaBelmdugyUiYS
# L+erCFDPs0S3XdjELgN1q2jzy23zOlyhFvRGuuA4ZKxuZDV4pqBjDy3TQJP4494H
# DdVceaVJKecNvqATd76UPe/74ytaEB9NViiienLgEjq3SV7Y7e1DkYPZe7J7hhvZ
# PrGMXeiJT4Qa8qEvWeSQOy2uM1jFtz7+MtOzAz2xsq+SOH7SnYAs9U5WkSE1JcM5
# bmR/U7qcD60ZI4TL9LoDho33X/DQUr+MlIe8wCF0JV8YKLbMJyg4JZg5SjbPfLGS
# rhwjp6lm7GEfauEoSZ1fiOIlXdMhSz5SxLVXPyQD8NF6Wy/VI+NwXQ9RRnez+ADh
# vKwCgl/bwBWzvRvUVUvnOaEP6SNJvBi4RHxF5MHDcnrgcuck379GmcXvwhxX24ON
# 7E1JMKerjt/sW5+v/N2wZuLBl4F77dbtS+dJKacTKKanfWeA5opieF+yL4TXV5xc
# v3coKPHtbcMojyyPQDdPweGFRInECUzF1KVDL3SV9274eCBYLBNdYJWaPk8zhNqw
# iBfenk70lrC8RqBsmNLg1oiMCwIDAQABo4IB7TCCAekwEAYJKwYBBAGCNxUBBAMC
# AQAwHQYDVR0OBBYEFEhuZOVQBdOCqhc3NyK1bajKdQKVMBkGCSsGAQQBgjcUAgQM
# HgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1Ud
# IwQYMBaAFHItOgIxkEO5FAVO4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuGSWh0
# dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0Nl
# ckF1dDIwMTFfMjAxMV8wM18yMi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUF
# BzAChkJodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0Nl
# ckF1dDIwMTFfMjAxMV8wM18yMi5jcnQwgZ8GA1UdIASBlzCBlDCBkQYJKwYBBAGC
# Ny4DMIGDMD8GCCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtp
# b3BzL2RvY3MvcHJpbWFyeWNwcy5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcA
# YQBsAF8AcABvAGwAaQBjAHkAXwBzAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZI
# hvcNAQELBQADggIBAGfyhqWY4FR5Gi7T2HRnIpsLlhHhY5KZQpZ90nkMkMFlXy4s
# PvjDctFtg/6+P+gKyju/R6mj82nbY78iNaWXXWWEkH2LRlBV2AySfNIaSxzzPEKL
# UtCw/WvjPgcuKZvmPRul1LUdd5Q54ulkyUQ9eHoj8xN9ppB0g430yyYCRirCihC7
# pKkFDJvtaPpoLpWgKj8qa1hJYx8JaW5amJbkg/TAj/NGK978O9C9Ne9uJa7lryft
# 0N3zDq+ZKJeYTQ49C/IIidYfwzIY4vDFLc5bnrRJOQrGCsLGra7lstnbFYhRRVg4
# MnEnGn+x9Cf43iw6IGmYslmJaG5vp7d0w0AFBqYBKig+gj8TTWYLwLNN9eGPfxxv
# FX1Fp3blQCplo8NdUmKGwx1jNpeG39rz+PIWoZon4c2ll9DuXWNB41sHnIc+BncG
# 0QaxdR8UvmFhtfDcxhsEvt9Bxw4o7t5lL+yX9qFcltgA1qFGvVnzl6UJS0gQmYAf
# 0AApxbGbpT9Fdx41xtKiop96eiL6SJUfq/tHI4D1nvi/a7dLl+LrdXga7Oo3mXkY
# S//WsyNodeav+vyL6wuA6mk7r/ww7QRMjt/fdW1jkT3RnVZOT7+AVyKheBEyIXrv
# QQqxP/uozKRdwaGIm1dxVk5IRcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIW
# CjCCFgYCAQEwgZUwfjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEoMCYGA1UEAxMfTWljcm9zb2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAA
# AI6HkaRXGl/KPgAAAAAAjjANBglghkgBZQMEAgEFAKCB9TAZBgkqhkiG9w0BCQMx
# DAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkq
# hkiG9w0BCQQxIgQgmPPbVpjSV1PM984sphN6fGT3YkD1B8dZvg9cyiiIqV4wgYgG
# CisGAQQBgjcCAQwxejB4oFqAWABNAGkAYwByAG8AcwBvAGYAdAAgAEQAeQBuAGEA
# bQBpAGMAcwAgAE4AQQBWACAAQwBvAGQAZQBzAGkAZwBuACAAUwB1AGIAbQBpAHMA
# cwBzAGkAbwBuAC6hGoAYaHR0cDovL3d3dy5taWNyb3NvZnQuY29tMA0GCSqGSIb3
# DQEBAQUABIIBAL4M1NiBjQgoBmWmLFgl/7QgzzYCFrLbEeC+sTxHDkGoCun1GZ5Q
# aYIZ/EWhcSXq42CgD1Q0HN0fkKM1U9qH+Ka6Xt/3zRrAO0AryhZ09Cr1MIjtBZfI
# khzhNzT9pDumjGabLR9AHnmJ9rWAsb8irbRjSEbldAigI45JI37u8P+aMcGJLh14
# 2SHSEqS0UgU2xHRXNcziXkLzjeOJkfr1k/mDxbU0d1hAj7flQdKJQ0QsDvDhZYLA
# KabZsaMiACs2yXWJvR9Pd4f2gWcxvhyicm4leyMUxNsp5rEz/Tc7hcg/RRimrGeC
# lLsYY6td+D0oXI/wgvRlqcOukus4H5K5SA+hghNNMIITSQYKKwYBBAGCNwMDATGC
# EzkwghM1BgkqhkiG9w0BBwKgghMmMIITIgIBAzEPMA0GCWCGSAFlAwQCAQUAMIIB
# PQYLKoZIhvcNAQkQAQSgggEsBIIBKDCCASQCAQEGCisGAQQBhFkKAwEwMTANBglg
# hkgBZQMEAgEFAAQgdCDwPJrNNZdcJ03fABFUqdW1pzxy9O6e72VQ5kDGIAICBlmS
# ONl0kBgTMjAxNzA5MDQyMDMyMTIuNjQ2WjAHAgEBgAIB9KCBuaSBtjCBszELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjENMAsGA1UECxMETU9QUjEn
# MCUGA1UECxMebkNpcGhlciBEU0UgRVNOOjdEMkUtMzc4Mi1CMEY3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloIIO0DCCBnEwggRZoAMCAQIC
# CmEJgSoAAAAAAAIwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRp
# ZmljYXRlIEF1dGhvcml0eSAyMDEwMB4XDTEwMDcwMTIxMzY1NVoXDTI1MDcwMTIx
# NDY1NVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQG
# A1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQCpHQ28dxGKOiDs/BOX9fp/aZRrdFQQ1aUKAIKF
# ++18aEssX8XD5WHCdrc+Zitb8BVTJwQxH0EbGpUdzgkTjnxhMFmxMEQP8WCIhFRD
# DNdNuDgIs0Ldk6zWczBXJoKjRQ3Q6vVHgc2/JGAyWGBG8lhHhjKEHnRhZ5FfgVSx
# z5NMksHEpl3RYRNuKMYa+YaAu99h/EbBJx0kZxJyGiGKr0tkiVBisV39dx898Fd1
# rL2KQk1AUdEPnAY+Z3/1ZsADlkR+79BL/W7lmsqxqPJ6Kgox8NpOBpG2iAg16Hgc
# sOmZzTznL0S6p/TcZL2kAcEgCZN4zfy8wMlEXV4WnAEFTyJNAgMBAAGjggHmMIIB
# 4jAQBgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQU1WM6XIoxkPNDe3xGG8UzaFqF
# bVUwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1Ud
# EwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYD
# VR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwv
# cHJvZHVjdHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEB
# BE4wTDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9j
# ZXJ0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcnQwgaAGA1UdIAEB/wSBlTCB
# kjCBjwYJKwYBBAGCNy4DMIGBMD0GCCsGAQUFBwIBFjFodHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vUEtJL2RvY3MvQ1BTL2RlZmF1bHQuaHRtMEAGCCsGAQUFBwICMDQe
# MiAdAEwAZQBnAGEAbABfAFAAbwBsAGkAYwB5AF8AUwB0AGEAdABlAG0AZQBuAHQA
# LiAdMA0GCSqGSIb3DQEBCwUAA4ICAQAH5ohRDeLG4Jg/gXEDPZ2joSFvs+umzPUx
# vs8F4qn++ldtGTCzwsVmyWrf9efweL3HqJ4l4/m87WtUVwgrUYJEEvu5U4zM9GAS
# inbMQEBBm9xcF/9c+V4XNZgkVkt070IQyK+/f8Z/8jd9Wj8c8pl5SpFSAK84Dxf1
# L3mBZdmptWvkx872ynoAb0swRCQiPM/tA6WWj1kpvLb9BOFwnzJKJ/1Vry/+tuWO
# M7tiX5rbV0Dp8c6ZZpCM/2pif93FSguRJuI57BlKcWOdeyFtw5yjojz6f32WapB4
# pm3S4Zz5Hfw42JT0xqUKloakvZ4argRCg7i1gJsiOCC1JeVk7Pf0v35jWSUPei45
# V3aicaoGig+JFrphpxHLmtgOR5qAxdDNp9DvfYPw4TtxCd9ddJgiCGHasFAeb73x
# 4QDf5zEHpJM692VHeOj4qEir995yfmFrb3epgcunCaw5u+zGy9iCtHLNHfS4hQEe
# gPsbiSpUObJb2sgNVZl6h3M7COaYLeqN4DMuEin1wC9UJyH3yKxO2ii4sanblrKn
# QqLJzxlBTeCG+SqaoxFmMNO7dDJL32N79ZmKLxvHIa9Zta7cRDyXUHHXodLFVeNp
# 3lfB0d4wwP3M5k37Db9dT+mdHhk4L7zPWAUu7w2gUDXa7wknHNWzfjUeCLraNtvT
# X4/edIhJEjCCBNowggPCoAMCAQICEzMAAACiTI4d2qkhfIQAAAAAAKIwDQYJKoZI
# hvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAO
# BgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEm
# MCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwHhcNMTYwOTA3
# MTc1NjQ5WhcNMTgwOTA3MTc1NjQ5WjCBszELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjENMAsGA1UECxMETU9QUjEnMCUGA1UECxMebkNpcGhlciBE
# U0UgRVNOOjdEMkUtMzc4Mi1CMEY3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1T
# dGFtcCBTZXJ2aWNlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApgF3
# BXvDfQ52aL3GqIPGgnsBcKiwaoRyT1SObb5nIGq+7C3dL0dx4ZL9dGJrvnTbhTbb
# NMjHaQrmNhJJQEe4QTRZYj3xE6euCQEo0RRYYx85sGg2BNhZ2k1b4JFxEvxBsw3O
# wXKhFSb285lb6OCKrhB1qjnX8Q7yCcExdQwpKind7I43Kt9rquMyuNhNe8hxEJDB
# vjqGGQvo6a0fuDQjrWGMli77PkwvQmXGCx6xsFjCa5vnz4sEx5NBneZ5uOX3llfc
# gMUFBQCmQSI3Fvm060esLzmt0MXTDETXCVtp0QnzAytjJ1oHkPTvjKMzJY03LD8l
# mbPzFT6mkur5URjl1QIDAQABo4IBGzCCARcwHQYDVR0OBBYEFG672cHC2hawfK3C
# U3/n0BcTPbxXMB8GA1UdIwQYMBaAFNVjOlyKMZDzQ3t8RhvFM2hahW1VMFYGA1Ud
# HwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3By
# b2R1Y3RzL01pY1RpbVN0YVBDQV8yMDEwLTA3LTAxLmNybDBaBggrBgEFBQcBAQRO
# MEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2Vy
# dHMvTWljVGltU3RhUENBXzIwMTAtMDctMDEuY3J0MAwGA1UdEwEB/wQCMAAwEwYD
# VR0lBAwwCgYIKwYBBQUHAwgwDQYJKoZIhvcNAQELBQADggEBADWZV20z9kidnkHc
# zKlg7lxHSFQRCoa5Vz+nbZiOynxppmqWg845sr1kDpkwu77c4HWCa0Ip4YVEjjF7
# c2hZeZidV7QWB/yiKbyjcIIhJh1lSxnmiSpVza+6kmreyJoJAlslFpfHq7la2vTz
# oBuCcKpKxka1eoDEYkKD93FaZCsm/fOOIwtOFvIb8tA1CkPaPPOpGpGKxDV42RCo
# YwajZH+svyjuqBwVeI+g98Jxxdi4ks6ql3I5TA9oZEROyoblLcuyArEoPf0ZvwDW
# SNPfDbTtDCSQRRS8lXk6A+xjhjw07nGyPS5qeZCCtusbGlm7r4uLefGp/Uox8jxq
# GxVdOsahggN5MIICYQIBATCB46GBuaSBtjCBszELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjENMAsGA1UECxMETU9QUjEnMCUGA1UECxMebkNpcGhl
# ciBEU0UgRVNOOjdEMkUtMzc4Mi1CMEY3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBTZXJ2aWNloiUKAQEwCQYFKw4DAhoFAAMVAF4vF+lxhNIyy+zXXko7
# +E63h+n1oIHCMIG/pIG8MIG5MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMQ0wCwYDVQQLEwRNT1BSMScwJQYDVQQLEx5uQ2lwaGVyIE5UUyBFU046
# NTdGNi1DMUUwLTU1NEMxKzApBgNVBAMTIk1pY3Jvc29mdCBUaW1lIFNvdXJjZSBN
# YXN0ZXIgQ2xvY2swDQYJKoZIhvcNAQEFBQACBQDdWAZAMCIYDzIwMTcwOTA0MTcw
# NTA0WhgPMjAxNzA5MDUxNzA1MDRaMHcwPQYKKwYBBAGEWQoEATEvMC0wCgIFAN1Y
# BkACAQAwCgIBAAICCUoCAf8wBwIBAAICGI4wCgIFAN1ZV8ACAQAwNgYKKwYBBAGE
# WQoEAjEoMCYwDAYKKwYBBAGEWQoDAaAKMAgCAQACAxbjYKEKMAgCAQACAwehIDAN
# BgkqhkiG9w0BAQUFAAOCAQEAqt7XBP/BgF7JGF9t4NmitV6Zhu9k+7Tpqced5CMM
# RWYdW5Nrlw7axO7GXUhJRFhE2RyCgY886xK9XVwNaT/OQPKT+syjq8DAuL8D65dF
# 3VrKcY/y22Z8O7lhCFSE45K0t2JBwPyXhdzsTDE0blc5J9N8rZLYsejk0ocaa0sf
# GpaOsgF2fVe1iw5ko5GY6aFXL9CbIgPnoIPifCbVB/2nEoo5Jf7Lam/zxHDkbgMR
# JGtj1DxmTsZH97x/cg2/ANZo3jmF8IRn4wkRP08odJ6l6TNAiPyFb5V1dB2vNNPK
# 7PygM138aJQoQcG3h/mII8DTcsJUE+Y0XdsziMKhqIhXAzGCAvUwggLxAgEBMIGT
# MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMT
# HU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAAokyOHdqpIXyEAAAA
# AACiMA0GCWCGSAFlAwQCAQUAoIIBMjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQ
# AQQwLwYJKoZIhvcNAQkEMSIEID/ncy6iQ6mVUqbG+GqZn3LRhS698r4KUNCk9bFe
# U7aLMIHiBgsqhkiG9w0BCRACDDGB0jCBzzCBzDCBsQQUXi8X6XGE0jLL7NdeSjv4
# TreH6fUwgZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
# bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAA
# AKJMjh3aqSF8hAAAAAAAojAWBBQt76ZVQORK6hliTp8g0pMcKRAFFjANBgkqhkiG
# 9w0BAQsFAASCAQABDpnmlHsVWcbSVxe6sJzgrSaQEdo2J9hJnR5pTMqpYW9M9ZVS
# wtpsM4ZM4ZgRVTi9ShHaSJYCAGkTqOyVIYBRMo2Geh3VwjxHTumBZ0WebzhYA4T0
# 2OpPOKrz1S4e4GcTW4xE0uZlNxlM48tD3jTGfSb/IlrPkCDS64VjrCiB1oR3A59/
# js5dP1bJageBQQFkEJ/RRvtoKCXtAFg4FQ/RQi2e93nebAkLxEkGQLiK8Bn6imAH
# BgixfXaZL01flCX2uTJIk7H3qNxp3dNqrmLk8C5UoeexwPqDmVwjk4VDyfSsU45g
# 8sYmq+sGDvJEBl1/6BFXX28er7piZ+BtHBfG
# SIG # End signature block

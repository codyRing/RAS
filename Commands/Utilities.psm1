<#
.SYNOPSIS
Return the directory of the calling script.
 
.DESCRIPTION
This cmdlet will throw an exception if run from the command line, but will work from within another script.
 
.EXAMPLE
Get-ScriptRoot
Returns the path of the script in which it's called.
 
.NOTES
The $PSScriptRoot variable is not reliably set, since it depends on the host.  This script, however, is reliable.
#>
Function Get-ScriptRoot {

    [CmdletBinding()]
    Param()

    End {
        $CallersDirectory = Split-Path -Path $MyInvocation.ScriptName -Parent
        $CallersDirectory
    }
}

<#

Set the current directory for .NET and when not running in the console.
Note that changing the working directory (or the environment in general) when a module is imported is bad practice,
but the SQLPS module imported by SQL Server Agent does it, so we have to undo it somehow.

See also:
    https://connect.microsoft.com/SQLServer/feedback/details/2434605

#>

If ($Host.Name -ne "ConsoleHost") {
    Get-ScriptRoot | Set-Location
}
[System.IO.Directory]::SetCurrentDirectory($Pwd.ProviderPath)

<#
.SYNOPSIS
For a given database, return a connection string for use with SSIS connections.

.DESCRIPTION
Databases ending with 'production' yield a connection string pointing to SQL1.  Databases ending with 'demo', 'operations', 'stage', 'uat', or 'test' yield a connection string to STAGESQL1.  All other databases yield a connection string pointing to DATASQL1.

.PARAMETER Database
The initial catalog to connect to.

.INPUTS
A string representing the database to connect to.

.OUTPUTS
A connection string.

.EXAMPLE
Get-ConnectionString helios-production
Returns a connection string suitable for connection to the helios-production database on SQL1, such as "Data Source=sql1.colo1.arrayhealth.com;Initial Catalog=helios-production;Integrated Security=SSPI;"

.NOTES
Integrated Security is assumed, so users must be signed into the production network to use the connection strings.
#>

Function Get-ConnectionString {
    [CmdletBinding()]
    Param(
	    [parameter(Position = 0, Mandatory = $true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
	    [string] $Database
    )

    Begin {
        [String] $Reference = @'
Data Source=$Server;Initial Catalog=$Database;Integrated Security=SSPI;
'@
        [String] $ProductionServer = 'sql1.colo1.arrayhealth.com'
        [String] $StageServer = 'stagesql1.colo1.arrayhealth.com'
	    [String] $DataServer = 'datasql1.colo1.arrayhealth.com'
        [String] $AtlServer = 'ATL1-SQL02'
    }

    Process {

	    $Server = $DataServer

        if ($Database.EndsWith('production')) {
            $Server = $ProductionServer
        }

        if ($Database.EndsWith('MBI')) {
            $Server = $AtlServer
        }
	
	    if ($Database.EndsWith('demo') -or $Database.EndsWith('operations') -or $Database.EndsWith('stage') -or $Database.EndsWith('uat') -or $Database.EndsWith('test')) {
		    $Server = $StageServer
	    }

        $Reference.Replace('$Server', $Server).Replace('$Database', $Database)

    }
}

<#

This is the date-time stamp format used in Out-Log.  It conforms to ISO-8601.

See also:
    https://msdn.microsoft.com/en-us/library/8kb3ddd4(v=vs.110).aspx
    https://en.wikipedia.org/wiki/ISO_8601

#>
$LogDateFormat = "yyyy-MM-ddTHH:mm:ss.fff"

<#
.SYNOPSIS
Output a message line in common logging format.
 
.DESCRIPTION
The message is appended to the timestamp and the name of the calling script.
 
.PARAMETER Message
The string of text to be logged.

.INPUTS
Message strings to be logged.
 
.OUTPUTS
Log-formatted strings of text.

.EXAMPLE
"Hello World" | Out-Log
Displays a message such as "2017-04-10T14:03:28.383 HelloWorld.ps1 : Hello World"
#>

Function Out-Log {
    [CmdletBinding()]
    Param(
	    [parameter(Position = 0, Mandatory = $true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
	    [String] $Message
    )

    Begin {
        $LogSource = Split-Path -Path $MyInvocation.ScriptName -Leaf
    }

    Process {
        $(Get-Date -Format $LogDateFormat) + " $LogSource : " + $Message
    }
}

<#
.SYNOPSIS
Format a block of XML for pretty printing.
 
.DESCRIPTION
Opening tags are put on new lines, and the indentation is set to 2 spaces.  The caller can also specify a left margin, useful for processing subtrees.
 
.PARAMETER Xml
A string representation of the XML to format.

.PARAMETER Margin
An optional number of spaces that all lines should begin with.  The default is 0.
 
.INPUTS
XMLs and margins.
 
.OUTPUTS
Strings of formatted XML.
 
.EXAMPLE
"<book ISBN=""1-861001-57-8""><title>Pride And Prejudice</title><price>24.95</price></book>" | Out-PrettyXml -Margin 2 | Set-Content .\pride.xml
Writes the book record into an XML file with two spaces before each line.
 
.NOTES
Because the input here is a string, use Get-Content to retrieve the XML from existing files before piping it to this cmdlet.
#>

Function Out-PrettyXml {
    [CmdletBinding()]
    Param(
        [parameter(Position = 0, Mandatory = $True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
	    [String] $Xml,

        [parameter(Position = 1, Mandatory = $False, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
	    [Int] $Margin = 0
    )

    Begin {
	    $Indent = 2
    }


    Process {
    	$CastedXml = [Xml] ($Xml)
	    $StringWriter = New-Object System.IO.StringWriter
	    $XmlWriter = New-Object System.XML.XmlTextWriter($StringWriter)
	    $XmlWriter.Formatting = "indented"
	    $XmlWriter.Indentation = $Indent
	    $CastedXml.WriteContentTo($XmlWriter)
	    $XmlWriter.Flush()
	    $StringWriter.Flush()

        $MarginSpaces = " " * $Margin
        $OutputString = $MarginSpaces + $StringWriter.ToString().Replace("`n", "`n" + $MarginSpaces)

	    Write-Output $OutputString
    }
}

<#
.SYNOPSIS
Execute with the Windows cmd shell.

.DESCRIPTION
This cmdlet creates a temporary batch file, which executes the commands passed as input.

.PARAMETER Command
The command line string to be executed.

.INPUTS
A string representing a command.

.OUTPUTS
None.

.EXAMPLE
Invoke-Cmd "`"$exe`" $args"
Runs the command as if the contents of $exe and $args had been entered on the command line.

.NOTES
Powershell offers other ways of executing commands (&, for example), but only this method is immune to the vagaries of special character handling.
#>

Function Invoke-Cmd {
    [CmdletBinding()]
    Param(
	    [parameter(Position = 0, Mandatory = $true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
	    [string] $Command
    )

    Begin {
        $Temp = [System.IO.Path]::GetTempFileName()
        $TempBat = $Temp + ".bat"
        Rename-Item $Temp $TempBat
    }

    Process {
        Add-Content $TempBat $Command
    }

    End {
        & $TempBat
        Remove-Item $TempBat
    }
}

<#
.SYNOPSIS
Execute an SSIS package.
 
.DESCRIPTION
The cmdlet calls the local machine's dtexec.exe to execute an SSIS package.  An exception is thrown if the message "DTExec: The package execution returned DTSER_SUCCESS (0)." doesn't appear in the output.
 
.PARAMETER Package
Path to the dtsx file to execute.

.PARAMETER Connections
Hashtable of SSIS connections to configure, with the connection name as the key and connection string as the value.
 
.INPUTS
Package and connections.
 
.OUTPUTS
Strings of logged activity from the SSIS package execution.
 
.EXAMPLE
Invoke-SSIS ".\example.dtsx"
Executes the example.dtsx package using the default package connection configuration.

.EXAMPLE
Invoke-SSIS ".\example.dtsx" @{"Connection1"="database1"; "Connection2"="database2"}
Executes the example.dtsx package using database1 for the SSIS connection named Connection1 and database2 for the SSIS connection names Connection2.

.EXAMPLE
[PSCustomObject]@{Package=".\piped1.dtsx"; Connections=@{"A"="1"; "B"="2"}}, [PSCustomObject]@{Package=".\piped2.dtsx"; Connections=@{"C"="3"; "D"="4"}} | Invoke-SSIS
Executes the piped1.dtsx package with configured connections A and B as well as the piped2.dtsx package with configured connections C and D.
 
.NOTES
SSIS reporting is suppressed for non-errors unless the -Verbose parameter is used.  Also, while the path to the package itself can be relative, it's up to the caller to make sure the connection strings are absolute.
#>

Function Invoke-SSIS {

    [CmdletBinding()]
    Param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [String] $Package,

        [Parameter(Position = 1, Mandatory = $False, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [Hashtable] $Connections
    )

    Begin {
        # SQL Server Agent hates the -All parameter in Get-Command for some unfathomable reason:
        #   The command could not be retrieved because the ArgumentList parameter can be specified only when retrieving a single cmdlet or script.
        # So do these acrobatics instead.
        $Exe = (
            $env:Path.Split(';') |
            % { Join-Path $_ dtexec.exe } |
            ? { Test-Path $_ } |
            % { Get-Command -Name $_ } |
            Sort-Object -Property @{Expression={$_.FileVersionInfo.FileVersion}; Descending = $True} |
            Where-Object { $_.FileVersionInfo.FileVersion -lt "2013" -and $_.Path -notlike "*(x86)*" } |
            Select-Object -First 1
        ).Path

        $DefaultReportingEvents = "EWCDI"
        $ErrorsReportingEvents = "E"
        $ReportingEvents = $DefaultReportingEvents
        If ($VerbosePreference -eq [System.Management.Automation.ActionPreference]::SilentlyContinue) {
            $ReportingEvents = $ErrorsReportingEvents
        }

 	    $ArgsTemplate = @'
/FILE "\"$Package\"" $ConnectionMaps /CHECKPOINTING OFF  /REPORTING $ReportingEvents
'@
        $argsTemplate = $argsTemplate.Replace('$ReportingEvents', "$ReportingEvents")

        $SuccessMessage = "DTExec: The package execution returned DTSER_SUCCESS \(0\)\."
    }

    Process {

        $TempLog = [System.IO.Path]::GetTempFileName()

        $Package = [System.IO.Path]::GetFullPath($Package)
        $Args = $ArgsTemplate.Replace('$Package', "$Package")

        $ConnectionMaps = ""
        ForEach ($ConnectionKey in $Connections.Keys) {
            $ConnectionMaps += " /CONNECTION ""\""$ConnectionKey\"""";""\""$($Connections[$ConnectionKey])\"""" "
        }
        $Args = $Args.Replace('$ConnectionMaps', "$ConnectionMaps")

        Invoke-Cmd "`"$Exe`" $Args" | Tee-Object $TempLog

        Try {
            If (-Not (Select-String -Path $TempLog -Pattern $SuccessMessage -Quiet)) {
                Throw("No success message logged for SSIS package $Package")
            }
        } Finally {
            Remove-Item -Path $TempLog
        }
    }
}

<#
.SYNOPSIS
Executes T-SQL statements using a given database.
 
.DESCRIPTION
The cmdlet connects to a database with a given connection string and executes T-SQL statements.  Either an integer reflecting the number of rows affected by UPDATE, INSERT, and DELETE statements or a DataTableCollection containing results (for example, from a SELECT statement) are returned.  The statement can be optionally wrapped in a transaction.
 
.PARAMETER ConnectionString
The connection string used to connect to the database where the T-SQL statements should be executed.
 
.PARAMETER Sql
A string containing valid T-SQL to be executed.
 
.PARAMETER Results
A switch specifying that a DataTableCollection should be returned rather than the number of affected rows.
 
.PARAMETER Transaction
A switch specifying that the T-SQL should be committed or rolled back as a whole.
 
.INPUTS
A connection string, SQL statements as a string, the Results switch, and the Transaction switch.
 
.OUTPUTS
Either a DataTableCollection or an integer number of rows affected, depending on the Results switch.
 
.EXAMPLE
$Results = Invoke-Tsql -ConnectionString "Data Source=localhost;Initial Catalog=AdventureWorks2012;Integrated Security=SSPI;" -Sql "select * from HumanResources.[Shift]" -Results
Connects with Windows security to the AdventureWorks2012 database and returns the results of the SELECT statement, which are accessible at $Results[0].

.EXAMPLE
$RowsUpdated = Invoke-Tsql -ConnectionString "Data Source=localhost;Initial Catalog=AdventureWorks2012;Integrated Security=SSPI;" -Sql "update s set s.Name = 'Long Day' from HumanResources.[Shift] s where s.Name = 'Day'" -Transaction
Connects with Windows security to the AdventureWorks2012 database and performs the UPDATE.  If the update fails, the transaction is rolled back and an exception is thrown.  Otherwise, the number of updated rows is returned.

.NOTES
If a transaction is rolled back, an exception is thrown.

Database connections from this cmdlet are pooled using standard ADO.NET SQL Server Connection Pooling.  For more details, see https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/sql-server-connection-pooling

Comments and batches separated by GO are acceptable SQL input for this cmdlet, since it uses the same parser as SSMS.

If there are no UPDATE, INSERT, or DELETE statements, the return value of the number of rows affected will be listed as -1.  If multiple UPDATE, INSERT, or DELETE statements are run, then the return value of the number of rows affected will be the sum of the rows affected by each statement.  In addition, if more than one result set is returned in the DataTableCollection (for example, from multiple SELECT statements), they can be accessed by index from the return value.

Though UPDATE, INSERT, DELETE, and SELECT statements can be mixed in the T-SQL input, only one return type - either an integer or DataTableCollection - will be returned.  For that reason, SELECT statements should usually be run in a separate call to this cmdlet.
#>
Function Invoke-Tsql {
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [String] $ConnectionString,

        [Parameter(Position = 1, Mandatory = $True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [String] $Sql,

        [Parameter(Position = 2, Mandatory = $False, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [Switch] $Results,

        [Parameter(Position = 3, Mandatory = $False, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [Switch] $Transaction
    )

    Begin {
        $ErrorActionPreference = "Stop"

        # Deprecated per https://msdn.microsoft.com/en-us/library/12xc5368(v=vs.110).aspx, but still an option per
        # https://docs.microsoft.com/en-us/sql/relational-databases/scripting/load-the-smo-assemblies-in-windows-powershell
        # We're not importing SQLPS because it has way more than we need, slows things down, and messes with the environment.
        [Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
        #[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo, Version=12.0.0.0") | Out-Null
        




    }

    Process {
        $SqlConnection = $NULL
        $ServerConnection = $NULL
        $DataSetResults = $NULL
        $RowCountResults = $NULL
        $ErrorMessage = $NULL

        Try {

            # https://docs.microsoft.com/en-us/sql/relational-databases/server-management-objects-smo/create-program/connecting-to-an-instance-of-sql-server
            # SMO will automatically establish a connection when required, and release the connection to the connection pool after it
            # has finished performing operations.  Note that the pooling here ensures connections are re-used where possible rather
            # than being re-established for each SQL statement in the pipeline.
            $SqlConnection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
            $ServerConnection = New-Object Microsoft.SqlServer.Management.Common.ServerConnection($SqlConnection)
        
            If ($Transaction) {
                Write-Verbose "Transaction beginning"
                $ServerConnection.BeginTransaction()
            }

            If ($Results) {
                $DataSetResults = New-Object System.Data.DataSet
                $DataSetResults = $ServerConnection.ExecuteWithResults($Sql)
            } Else {
                $RowCountResults = [Int]::MinValue
                $RowCountResults = $ServerConnection.ExecuteNonQuery($Sql)
            }

            If ($Transaction) {
                $ServerConnection.CommitTransaction()
                Write-Verbose "Transaction committed"
            }

        } Catch {

            $Exception = $_
            $ErrorString = $Exception.Message

            $Exception | Get-Member -Type Property | % {
                $ErrorString += "`n`n" + $_.Name.ToUpper() + "`n" + "$($Exception.$($_.Name))"
            }

            $ErrorMessage = $ErrorString | Out-Log

        } Finally {

            Write-Verbose ("Transaction depth is {0}." -f $ServerConnection.TransactionDepth)
            If ($ServerConnection.TransactionDepth -gt 0) {
                $ServerConnection.RollBackTransaction()
                If ($ErrorMessage -ne $NULL) {
                    $ErrorMessage += "`n`n"
                }
                $ErrorMessage += "The transaction has been rolled back."
            }

        }

        If ($ErrorMessage -ne $NULL) {

            $ErrorCategory = [System.Management.Automation.ErrorCategory]::OperationStopped
            $ErrorMessage = $ErrorCategory.ToString() + "`n" + $ErrorMessage
            $CurrentException = New-Object System.Exception($ErrorCategory.ToString())

            $CurrentErrorRecord = New-Object System.Management.Automation.ErrorRecord($CurrentException, $ErrorMessage, $ErrorCategory, $NULL)

            Throw $CurrentErrorRecord

        }

        If ($Results) {
            Return $DataSetResults.Tables
        } Else {
            Return $RowCountResults
        }
    }
}

Export-ModuleMember -Function Get-ScriptRoot
Export-ModuleMember -Function Get-ConnectionString
Export-ModuleMember -Function Out-Log
Export-ModuleMember -Function Out-PrettyXml
Export-ModuleMember -Function Invoke-Cmd
Export-ModuleMember -Function Invoke-SSIS
Export-ModuleMember -Function Invoke-Tsql

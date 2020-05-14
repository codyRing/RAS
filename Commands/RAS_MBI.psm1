Push-Location $PWD
Pop-Location

<#
.SYNOPSIS
Determines whether a string represents a valid MBI.
 
.DESCRIPTION
The cmdlet verifies that the string is 11 characters long, with letters in positions 2, 5, 8, and 9, digits in positions 1, 4, 7, 10, 11, and alphanumeric characters in positions 3 and 6.
 
.PARAMETER Id
A potential MBI to test.
 
.INPUTS
Id
 
.OUTPUTS
Boolean true or false
 
.EXAMPLE
Test-Mbi -Id 123456789
Returns FALSE for this invalid MBI.

.EXAMPLE
Test-Mbi -Id 1B34E67HI01
Returns TRUE for this valid MBI.
 
.NOTES
The MBI format specification can be found here: https://www.cms.gov/Medicare/New-Medicare-Card/Understanding-the-MBI.pdf
#>
Function Test-Mbi {
    [CmdletBinding()]
    Param(
	    [parameter(Position = 0, Mandatory = $TRUE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
        [AllowEmptyString()]
	    [string] $Id
    )

    Begin {
    }

    Process {
        $Trimmed = $Id.Trim()

        If ($Trimmed.Length -ne 11) {
            Return $False
        }

        Foreach ($Pos in @(2, 5, 8, 9)) {
            If (-not [char]::IsLetter($Trimmed[$Pos - 1])) {
                Return $False
            }
        }

        Foreach ($Pos in @(1, 4, 7, 10, 11)) {
            If (-not [char]::IsDigit($Trimmed[$Pos - 1])) {
                Return $False
            }
        }

        Foreach ($Pos in @(3, 6)) {
            If (-not [char]::IsLetterOrDigit($Trimmed[$Pos - 1])) {
                Return $False
            }
        }

        Return $True
    }

    End {
    }

}

<#
.SYNOPSIS
Determines whether a string represents a valid SSN.
 
.DESCRIPTION
The cmdlet verifies that the string is composed of 9 digits.
 
.PARAMETER Id
A potential SSN to test.
 
.INPUTS
Id
 
.OUTPUTS
Boolean true or false
 
.EXAMPLE
Test-Ssn -Id 123456789
Returns TRUE for this valid SSN.

.EXAMPLE
Test-Ssn -Id 1234567B9
Returns FALSE for this invalid SSN.
 
.NOTES
The cmdlet does not check that each component of the SSN is within a valid range, only that each character is numeric.
#>
Function Test-Ssn {
    [CmdletBinding()]
    Param(
	    [parameter(Position = 0, Mandatory = $TRUE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    [string] $Id
    )

    Begin {
    }

    Process {
        $Trimmed = $Id.Trim()

        If ($Trimmed.Length -ne 9) {
            Return $False
        }

        Foreach ($Pos in 1..9) {
            If (-not [char]::IsDigit($Trimmed[$Pos - 1])) {
                Return $False
            }
        }

        Return $True
    }

    End {
    }

}

<#
.SYNOPSIS
Determines whether a string represents a valid HICN.
 
.DESCRIPTION
The cmdlet verifies that the string is has an appropriate length, with letters and numbers in an approved order.
 
.PARAMETER Id
A potential HICN to test.
 
.INPUTS
Id
 
.OUTPUTS
Boolean true or false
 
.EXAMPLE
Test-Hicn -Id 123456789A
Returns TRUE for this valid HICN.

.EXAMPLE
Test-Hicn -Id ABC1234567
Returns FALSE for this invalid HICN.
 
.NOTES
The HICN specificantion can be found here: https://manual.jointcommission.org/releases/Archive/TJC2010B1/DataElem0098.html
#>
Function Test-Hicn {
    [CmdletBinding()]
    Param(
	    [parameter(Position = 0, Mandatory = $TRUE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    [string] $Id
    )

    Begin {

        Function HasDigits([string] $Trimmed, [int] $Start, [int] $End) {

            Foreach ($Pos in $Start..$End) {
                If (-not [char]::IsDigit($Trimmed[$Pos - 1])) {
                    Return $False
                }
            }
            Return $True

        }

        Function HasLetters([string] $Trimmed, [int] $Start, [int] $End) {

            Foreach ($Pos in $Start..$End) {
                If (-not [char]::IsLetter($Trimmed[$Pos - 1])) {
                    Return $False
                }
            }
            Return $True

        }

        Function HasLettersOrDigits([string] $Trimmed, [int] $Start, [int] $End) {

            Foreach ($Pos in $Start..$End) {
                If (-not [char]::IsLetterOrDigit($Trimmed[$Pos - 1])) {
                    Return $False
                }
            }
            Return $True

        }

    }

    Process {
        $Trimmed = $Id.Trim()

        If (($Trimmed.Length -lt 7) -or ($Trimmed.Length -gt 12)) {
            Return $False
        }

        If (HasDigits $Trimmed 1 1) {
            
            Switch($Trimmed.Length) {
                
                10 {
                    Return (
                        (HasDigits $Trimmed 2 9) -and
                        (HasLetters $Trimmed 10 10)
                    )
                }
                
                11 {
                    Return (
                        (HasDigits $Trimmed 2 9) -and
                        (HasLetters $Trimmed 10 10) -and
                        (HasLettersOrDigits $Trimmed 11 11)
                    )
                }
                
                default {
                    Return $False
                }

            }

        } Else {

            Switch($Trimmed.Length) {

                7 {
                    Return (
                        (HasLetters $Trimmed 1 1) -and
                        (HasDigits $Trimmed 2 7)
                    )
                }

                8 {
                    Return (
                        (HasLetters $Trimmed 1 2) -and
                        (HasDigits $Trimmed 3 8)
                    )
                }

                9 {
                    Return (
                        (HasLetters $Trimmed 1 3) -and
                        (HasDigits $Trimmed 4 9)
                    )
                }

                10 {
                    Return (
                        (HasLetters $Trimmed 1 1) -and
                        (HasDigits $Trimmed 2 10)
                    )
                }

                11 {
                    Return (
                        (HasLetters $Trimmed 1 2) -and
                        (HasDigits $Trimmed 3 11)
                    )
                }

                12 {
                    Return (
                        (HasLetters $Trimmed 1 3) -and
                        (HasDigits $Trimmed 4 12)
                    )
                }

                default {
                    Return $False
                }

            }

        }

        Return $True
    }

    End {
    }
}

# Single item cache for Get-MbiMapping
$LastInput_GetMbiMapping = $NULL
$LastOutput_GetMbiMapping = $NULL

Function FlushGetMbiMapppingCache {
    $script:LastInput_GetMbiMapping = $NULL
    $script:LastOutput_GetMbiMapping = $NULL
}

<#
.SYNOPSIS
Retrieves details of an MBI mapping.
 
.DESCRIPTION
The cmdlet returns details associated with a given MBI.  Details can include HICN and SSN, as well as the the organizational source, date, and data source reference of the mapping information.
 
.PARAMETER Mbi
The MBI to look up.  The wildcard character % is supported.
 
.INPUTS
Mbi
 
.OUTPUTS
MBI lookup details
 
.EXAMPLE
Get-MbiMapping -Mbi 1B34E67HI01
Retrieves details from the database for the MBI 1B34E67HI01.

.NOTES
For each MBI, only the latest match by date is considered. A warning will be output if there is not exactly 1 match returned.
#>
Function Get-MbiMapping {
    [CmdletBinding()]
    Param(
	    [parameter(Position = 0, Mandatory = $TRUE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    [string] $Mbi
    )

    Begin {
        $ConnectionString = Get-ConnectionString -Database "RAS_MBI"
        $SqlTemplate = "select * from Crosswalk c where c.MBI like '{Mbi}'"
    }

    Process {
        If ($script:LastInput_GetMbiMapping -eq $Mbi) {
            Return $script:LastOutput_GetMbiMapping
        }

        $Sql = $SqlTemplate.Replace('{Mbi}', $Mbi)
        $Results = Invoke-Tsql -ConnectionString $ConnectionString -Sql $Sql -Results
        $ResultCount = $Results.Rows.Count
        If ($ResultCount -ne 1) {
            "Found {0} mapping(s) for MBI {1}" -f $ResultCount, $Mbi | Write-Warning
             $Mbi | Add-Content "L:\RAS\Projects\RAS_Operations\commands\Need_MBI_Mapping.txt"
        }

        $script:LastInput_GetMbiMapping = $Mbi
        $script:LastOutput_GetMbiMapping = $Results
        Return $Results
    }

    End {
    }
}

<#
.SYNOPSIS
Sets other identifiers for the person referenced by a given MBI.
 
.DESCRIPTION
An existing mapping from MBI to HICN and SSN is updated.
 
.PARAMETER Mbi
The MBI of the mapping to update.

.PARAMETER Hicn
The HICN of the person associated with the MBI.

.PARAMETER Ssn
The SSN of the person associated with the MBI.
 
.INPUTS
Mbi, Hicn, and Ssn
 
.OUTPUTS
None
 
.EXAMPLE
Set-MbiMapping -Mbi 1B34E67HI01 -Hicn 123456789A -Ssn 123456789
Overwrites the existing mapping for MBI 1B34E67HI01 and associates it with HICN 123456789A and SSN 123456789.
 
.NOTES
An interactive confirmation prompt is displayed before the update is applied.
#>
Function Set-MbiMapping {

    [CmdletBinding()]
    Param(
	    [parameter(Position = 0, Mandatory = $TRUE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    [string] $Mbi,

	    [parameter(Position = 1, Mandatory = $FALSE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    [string] $Hicn,

	    [parameter(Position = 2, Mandatory = $FALSE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    [string] $Ssn
    )

    Begin {
        $ConnectionString = Get-ConnectionString -Database "RAS_MBI"
        $MbiCheckTemplate = "select * from DataOpsIds do where do.MBI like '{Mbi}'"
        $ExpectedCheckCount = 1
        $HicnUpdateTemplate = "update do set do.HICN = '{Hicn}', do.Date = getdate() from DataOpsIds do where do.MBI = '{Mbi}'"
        $SsnUpdateTemplate = "update do set do.SSN = '{Ssn}', do.Date = getdate() from DataOpsIds do where do.MBI = '{Mbi}'"
    }

    Process {
        If (-not (Test-Mbi -Id $Mbi)) {
            throw "{0} is not a valid MBI" -f $Mbi
        }

        If ([string]::IsNullOrEmpty($Hicn) -and [string]::IsNullOrEmpty($Ssn)) {
            throw "No update value specified"
        }

        If ((-not [string]::IsNullOrEmpty($Hicn)) -and (-not (Test-Hicn $Hicn))) {
            throw "{0} is not a valid HICN" -f $Hicn
        }

        If ((-not [string]::IsNullOrEmpty($Ssn)) -and (-not (Test-Ssn $Ssn))) {
            throw "{0} is not a valid SSN" -f $Ssn
        }

        $MbiCheckSql = $MbiCheckTemplate.Replace('{Mbi}', $Mbi)
        $Results = Invoke-Tsql -ConnectionString $ConnectionString -Sql $MbiCheckSql -Results
        $Count = $Results.Rows.Count
        If ($Count -ne $ExpectedCheckCount) {
            throw "Found {0} existing mapping(s) for MBI {1}, but expected {2}" -f $Count, $Mbi, $ExpectedCheckCount
        }

        $Caption  = "Update Confirmation"
        $Message = "You are about to update the mapping for MBI {0} to " -f $Mbi
        If (-not [string]::IsNullOrEmpty($Hicn)) { $Message += "HICN {0}" -f $Hicn }
        If ((-not [string]::IsNullOrEmpty($Hicn)) -and (-not [string]::IsNullOrEmpty($Ssn))) { $Message += " and " }
        If (-not [string]::IsNullOrEmpty($Ssn)) { $Message += "SSN {0}" -f $Ssn }
        $Message += ". Are you sure you want to proceed?"
        $Choices = @()
        $Choices += (New-Object Management.Automation.Host.ChoiceDescription -ArgumentList "&Yes", "Proceed with the update")
        $Choices += (New-Object Management.Automation.Host.ChoiceDescription -ArgumentList "&No", "Abort the update")

        $Decision = $Host.UI.PromptForChoice($Caption, $Message, $Choices, 1)
        if ($Decision -ne 0) {
          Return
        }

        If (-not [string]::IsNullOrEmpty($Hicn)) {
            $HicnSql = $HicnUpdateTemplate.Replace('{Mbi}', $Mbi).Replace('{Hicn}', $Hicn)
            $RecordsUpdated = Invoke-Tsql -ConnectionString $ConnectionString -Sql $HicnSql -Transaction
            If ($RecordsUpdated -ne 1) {
                throw "HICN update failure with {0} record(s) updated for MBI {1}" -f $RecordsUpdated, $Mbi
            }
        }

        If (-not [string]::IsNullOrEmpty($Ssn)) {
            $SsnSql = $SsnUpdateTemplate.Replace('{Mbi}', $Mbi).Replace('{Ssn}', $Ssn)
            $RecordsUpdated = Invoke-Tsql -ConnectionString $ConnectionString -Sql $SsnSql -Transaction
            If ($RecordsUpdated -ne 1) {
                throw "SSN update failure with {0} record(s) updated for MBI {1}" -f $RecordsUpdated, $Mbi
            }
        }

    }

    End {
        FlushGetMbiMapppingCache
    }
}

<#
.SYNOPSIS
Create an MBI mapping to a HICN and SSN.
 
.DESCRIPTION
A DataOps record is added relating a given MBI, HICN, and SSN.
 
.PARAMETER Mbi
The MBI to map.
 
.PARAMETER Hicn
The HICN to which the given MBI should be mapped.

.PARAMETER Ssn
The SSN to which the given MBI should be mapped.

.INPUTS
Mbi, Hicn, and Ssn
 
.OUTPUTS
None
 
.EXAMPLE
Add-MbiMapping -Mbi 1B34E67HI01 -Hicn 123456789A
Maps the MBI 1B34E67HI01 to the HICN value of 123456789A while leaving the SSN as null.
 
.NOTES
An error will be thrown if the given MBI is already part of a mapping in the database.
#>
Function Add-MbiMapping {

    [CmdletBinding()]
    Param(
	    [parameter(Position = 0, Mandatory = $TRUE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    [string] $Mbi,

	    [parameter(Position = 1, Mandatory = $FALSE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    [string] $Hicn,

	    [parameter(Position = 2, Mandatory = $FALSE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    [string] $Ssn
    )

    Begin {
        $ConnectionString = Get-ConnectionString -Database "RAS_MBI"
        $MbiCheckTemplate = "select * from dbo.DataOpsIds do where do.MBI like '{Mbi}'"
        $ExpectedCheckCount = 0
        $InsertTemplate = "insert into DataOpsIds values (newid(), '{Mbi}', {Hicn}, {Ssn}, getdate())"
    }

    Process {
        If (-not (Test-Mbi -Id $Mbi)) {
            throw "{0} is not a valid MBI" -f $Mbi
        }

        If ([string]::IsNullOrEmpty($Hicn) -and [string]::IsNullOrEmpty($Ssn)) {
            throw "No mapping value specified"
        }

        If ((-not [string]::IsNullOrEmpty($Hicn)) -and (-not (Test-Hicn $Hicn))) {
            throw "{0} is not a valid HICN" -f $Hicn
        }

        If ((-not [string]::IsNullOrEmpty($Ssn)) -and (-not (Test-Ssn $Ssn))) {
            throw "{0} is not a valid SSN" -f $Ssn
        }

        $MbiCheckSql = $MbiCheckTemplate.Replace('{Mbi}', $Mbi)
        $Results = Invoke-Tsql -ConnectionString $ConnectionString -Sql $MbiCheckSql -Results
        $Count = $Results.Rows.Count
        If ($Count -ne $ExpectedCheckCount) {
            throw "Found {0} existing mapping(s) for MBI {1}, but expected {2}" -f $Count, $Mbi, $ExpectedCheckCount
        }

        $InsertSql = $InsertTemplate.Replace('{Mbi}', $Mbi)

        $HicnReplacement = "{0}" -f "null"
        If (-not [string]::IsNullOrEmpty($Hicn)) {
            $HicnReplacement = "'{0}'" -f $Hicn
        }
        $InsertSql = $InsertSql.Replace('{Hicn}', $HicnReplacement)

        $SsnReplacement = "{0}" -f "null"
        If (-not [string]::IsNullOrEmpty($Ssn)) {
            $SsnReplacement = "'{0}'" -f $Ssn
        }
        $InsertSql = $InsertSql.Replace('{Ssn}', $SsnReplacement)

        $RecordsInserted = Invoke-Tsql -ConnectionString $ConnectionString -Sql $InsertSql -Transaction
        If ($RecordsInserted -ne 1) {
            throw "Failure with {0} record(s) inserted for MBI {1}" -f $RecordsInserted, $Mbi
        }
    }

    End {
        FlushGetMbiMapppingCache
    }
}

<#
.SYNOPSIS
Deletes an MBI mapping.
 
.DESCRIPTION
A DataOps MBI mapping that was added through the Add-MbiMapping cmdlet is deleted from the database.
 
.PARAMETER Id
The SourceId of the mapping to delete.
 
.INPUTS
Id
 
.OUTPUTS
None
 
.EXAMPLE
Remove-MbiMapping -Id 6c792734-a96b-48cb-8882-838b56d38ae9                      
An Id was found using Get-MbiMapping.  If the Organization for the mapping is DataOps, then the mapping will be deleted.
 
.NOTES
An interactive prompt will ask for confirmation before the deletion is performed.
#>
Function Remove-MbiMapping() {

    [CmdletBinding()]
    Param(
	    [parameter(Position = 0, Mandatory = $TRUE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    $Id
    )

    Begin {
        $ConnectionString = Get-ConnectionString -Database "RAS_MBI"
        $IdCheckTemplate = "select * from DataOpsIds do where do.Id like '{Id}'"
        $ExpectedCheckCount = 1
        $DeleteTemplate = "delete do from DataOpsIds do where do.Id like '{Id}'"
    }

    Process {
        $IdCheckSql = $IdCheckTemplate.Replace('{Id}', $Id)
        $Results = Invoke-Tsql -ConnectionString $ConnectionString -Sql $IdCheckSql -Results
        $Count = $Results.Rows.Count
        If ($Count -ne $ExpectedCheckCount) {
            throw "Found {0} existing mapping(s) for ID {1}, but expected {2}" -f $Count, $Id, $ExpectedCheckCount
        }

        $Caption  = "Update Confirmation"
        $Message = "You are about to delete the mapping"
        If (-not [string]::IsNullOrWhiteSpace($Results.Mbi)) { $Message += " MBI: {0}" -f $Results.Mbi }
        If (-not [string]::IsNullOrWhiteSpace($Results.Hicn)) { $Message += ", HICN: {0}" -f $Results.Hicn }
        If (-not [string]::IsNullOrWhiteSpace($Results.Ssn)) { $Message += ", SSN: {0}" -f $Results.Ssn }
        $Message += ". Are you sure you want to proceed?"
        $Choices = @()
        $Choices += (New-Object Management.Automation.Host.ChoiceDescription -ArgumentList "&Yes", "Proceed with the deletion")
        $Choices += (New-Object Management.Automation.Host.ChoiceDescription -ArgumentList "&No", "Abort the deletion")

        $Decision = $Host.UI.PromptForChoice($Caption, $Message, $Choices, 1)
        if ($Decision -ne 0) {
          Return
        }

        $DeleteSql = $DeleteTemplate.Replace('{Id}', $Id)
        $RecordsDeleted = Invoke-Tsql -ConnectionString $ConnectionString -Sql $DeleteSql -Transaction
        If ($RecordsDeleted -ne 1) {
            throw "Failure with {0} record(s) deleted" -f $RecordsUpdated
        }
    }

    End {
        FlushGetMbiMapppingCache
    }
}

# Helper function for Export-MappedFile
Function ReplaceMbi($SearchPattern, $MbiMatchIndex, $ReplacementPattern, $Line) {
    $Result = $Line

    If ($Line -match $SearchPattern) {
        $Mbi = $Matches[$MbiMatchIndex]
        $MappedId = $Mbi

        If (Test-Mbi $Mbi) {
            $MbiMapping = Get-MbiMapping $Mbi
            If (($MbiMapping -ne $NULL) -and ($MbiMapping.GetType().Name -eq "DataRow")) {
                If( -not ([string]::IsNullOrWhiteSpace($MbiMapping.HICN))) {
                    $MappedId = $MbiMapping.HICN.Trim()
                } ElseIf (-not ([string]::IsNullOrWhiteSpace($MbiMapping.SSN))) {
                    $MappedId = $MbiMapping.SSN.Trim()
                }
            }
        } Else {
            "{0} is not an MBI" -f $Mbi | Write-Verbose
        }

        $ReplacementPattern = $ReplacementPattern.Replace("{MappedId}", $MappedId)
        $Result = $Line -replace $SearchPattern, $ReplacementPattern
    }

    Return $Result
}

<#
.SYNOPSIS
Copies a premium payment file of MBIs to a premium payment file of HICNs.
 
.DESCRIPTION
A lookup is performed for each MBI in the source file, and a corresponding record is written in the destination file replacing the MBI with an associated HICN.
 
.PARAMETER Carrier
The code for the carrier that is the file source.  Used to determine the file format.
 
.PARAMETER Path
The path to the source file.

.PARAMETER Destination
The path to the output file.

.PARAMETER Test
Switch that disables writing to the output file.

.INPUTS
Carrier, Path, Destination, Switch
 
.OUTPUTS
None.
 
.EXAMPLE
Export-MappedFile -Carrier Coventry -Path ~\Desktop\premium_payments.txt -Destination ~\Desktop\premium_payments_HICN.txt -Test
Performs the MBI-HICN translation for all records in premium_payments.txt and outputs any warnings, but does not write the translated to the premium_payments_HICN.txt file due to the presence of the -Test switch.
 
.NOTES
None.
#>
Function Export-MappedFile {

    [CmdletBinding()]
    Param(
	    [parameter(Position = 0, Mandatory = $TRUE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
        [ValidateSet("Aetna", "Coventry", "CVS_Caremark", "Cigna", "Cigna_Status", "UHC_AARP", "Humana","Wellcare")]
	    $Carrier,

	    [parameter(Position = 1, Mandatory = $TRUE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    $Path,

	    [parameter(Position = 2, Mandatory = $TRUE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    $Destination,

	    [parameter(Position = 3, Mandatory = $FALSE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    [switch] $Test
    )

    Begin {
        $MbiMatchIndex = 2
        $ReplacementPattern = '${1}{MappedId}${3}'
        $SearchPatterns = @{
            "Aetna" = "(^D\t)(\w*?)(\s*\t)";
            "Coventry" = "(^D\t\w*?\t)(\w*?)(\t)";
            "CVS_Caremark" = "(^D\t)(\w*?)(\t)";
            "Cigna" = "(^D\t)(\w*?)(\t)";
            "Cigna_Status" = "(^D,)(\w*?)(,)";
            "UHC_AARP" = "(^D\t)(\w*?)(\t)";
            "Humana" = "(^D,)(\w*?)(,)"
			"Wellcare" = "(^D\t)(\w*?)(\s*\t)"
        }
    }

    Process {
        $SearchPattern = $SearchPatterns[$Carrier]

        $Output = ""
        ForEach ($Line in (Get-Content $Path)) {
            $UpdatedLine = ReplaceMbi $SearchPattern $MbiMatchIndex $ReplacementPattern $Line -Test:$Test
            $Output += ("{0}{1}" -f $UpdatedLine, [Environment]::NewLine)
        }
        $Output = $Output.Remove($Output.Length - [Environment]::NewLine.Length)

        If ($Test) {
            "TEST: {0} characters to output to {1}" -f $Output.Length, $Destination
        } Else {
            Set-Content -Path $Destination -Value $Output
        }
    }

    End {
    }
}

<#
.SYNOPSIS
 Pull ID out of delimited files
.DESCRIPTION
 
.PARAMETER Id
 
.INPUTS
 
.OUTPUTS
 

.EXAMPLE
#Extract-ID -Carrier "UHC_AARP" -InFile "BUGTI4BF_GI*" -OutFile "BCUHI2BF_BUCK_LAZENBY" -Del "`t" -Col "1" -EXT ".txt"
 
.NOTES

#>
Function Get-APRID {
    [CmdletBinding()]
    Param(
		[parameter(Position = 0, Mandatory = $TRUE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    [string] $Carrier,
		
		[parameter(Position = 1, Mandatory = $TRUE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    [string] $InFile,
		
		[parameter(Position = 2, Mandatory = $TRUE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    [string] $OutFile,

		[parameter(Position = 3, Mandatory = $TRUE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    [string] $Del,	
		
	    [parameter(Position = 4, Mandatory = $TRUE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    [string] $Col,	
	
		[parameter(Position = 5, Mandatory = $TRUE, ValueFromPipeline = $TRUE, ValueFromPipelineByPropertyName = $TRUE)]
	    [string] $Ext
		
		)
		
    Begin{
		$ValidIds = @()
		$base = "L:\RAS\Projects\RAS_Operations\"
		}
		
    Process{
	
	Get-Content ($base + "Commands\ID_List.txt") | % {
	$ValidIds += $_
	}
	
Get-ChildItem ($base + $carrier + "\original\" + $InFile  + $Ext) | % {
    $APRFile = $_
	    Get-Content $APRFile | % {
				$Row = $_
				        write-verbose $row
						$Id = $Row.ToString().Split($Del )[$Col]
                        #$TrimmedID = $Id.Trim()
						If ($ValidIds -contains $Id) {
                        $csv_file = ($base + $carrier + "\Altered\" + $OutFile + $Ext)
                        $RowFinal = $Row + [Environment]::NewLine
                        [System.IO.File]::AppendAllTExt($csv_file,$RowFinal )
        }
    }
}}
    End {
    }
}


Export-ModuleMember -Function Get-APRID

Export-ModuleMember -Function Test-Mbi
Export-ModuleMember -Function Test-Ssn
Export-ModuleMember -Function Test-Hicn

Export-ModuleMember -Function Get-MbiMapping
Export-ModuleMember -Function Set-MbiMapping
Export-ModuleMember -Function Add-MbiMapping
Export-ModuleMember -Function Remove-MbiMapping

Export-ModuleMember -Function Export-MappedFile

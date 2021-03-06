cd "Y:\RAS_Operations\External_Files\Census\Scotts"
$CSV= @()
gci ".\*.CSV"  |
    ForEach-Object {$CSV +=  Import-Csv $_ |
                    Select-Object "SSSN","HSSN","Last Name","First Name","DOB","Relationship Code","Retirement Date","RHE Transition Date","RHE Exchange","Employer Subsidy Contribution","Subsidy Type","Subsidy Start Date","Employer Subsidy Contribution 1","Employer Subsidy Contribution 2","Employer Subsidy Contribution 3","Years of Service"}

$CSV |Export-CSV  ".\Scotts_Merged.csv"  -NoTypeInformation -Force


 gci "Y:\RAS_Operations\External_Files\Census\Scotts\*.csv" |  % { $_ | 
            select name , 
            #@{n="header";e={get-content $_ |  Select-Object -First 1 }}  
            @{n="rows";e={get-content $_ |  measure-object -line | select -expa lines }}                                      
			} | export-csv ".\Headers.csv"
            #} | set-content ".\Row_Count.txt"
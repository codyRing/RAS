$CSV= @()

gci "C:\Users\cody.ringrissler\Downloads\*.CSV"  |
    ForEach-Object {
                    $CSV = Import-CSV -Path $_.FullName -Delimiter ","
                    $FileName = $_.Name
                    $CSV | select-object @{N='Filename';E={$FileName}},"AID","Enrollment Start Year","Enrollment","Eligible","SSN","Holderssn","PIN","RHE Exchange","TransitionDate","Last Name","First Name","Middle Initial","Suffix","RELATION CODE","FamilySize","Gender","Date Of Birth","DECEASED","Date Of Death","HireDate","Retirement Date","Employee ID","Address 1","Address 2","City","State","Zip","ZipPlus","Country","Telephone Number","AddressType","EmailAddress","VIP","AnnualIncome","EmployerSubsidyContrib","SubsidyStartDate","SubsidyEndDate","SubsidyType","CNX_EmployerGroup","RRACompanycode","CNX_Message","VIP Reason","Eligible Reason","Family Split","Coverage Interest","Employer Subsidy Contribution 1","Employer Subsidy Contribution 2","Employer Subsidy Contribution 3","Employer HRA Estimated StartDate","Current Medical Plan","Current Drug Plan","Current Dental Plan","YOS","Updated","Created"
                    } |
      Export-CSV  "C:\Users\cody.ringrissler\Downloads\result\MMA_Merged.CSV"  -NoTypeInformation -Force
 
 
 gci "C:\Users\cody.ringrissler\Downloads\*.CSV" |  % { $_ | 
            select name , 
            #@{n="header";e={get-content $_ |  Select-Object -First 1 }}  
            @{n="rows";e={get-content $_ |  measure-object -line | select -expa lines }}                                      
			} | export-csv ".\Headers.csv"
            #} | set-content ".\Row_Count.txt"
            
            
            #@{N='Filename';E={$FileName}}
cd "C:\Users\cody.ringrissler\Downloads"

$files = @{}

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
   


Get-ChildItem | %{
   $newFilename = ($_.BaseName.ToUpper())+($_.Extension.ToUpper());
   Rename-Item $_ -NewName $newFilename
   if($_  -match '[0-9]{8}' )
                    {$files.Add($_.basename,$matches[0] )}   
                    
   #if($_ -match 'BUGTI4BF_45_1_AETNA')
    #                {$files.Add('Aetna PDP')}
                       
}

$files.GetEnumerator() |
    Select-Object -Property Key,Value |
        Export-Csv -NoTypeInformation -Path .\data.txt

# =Date(LEFT(B2,4),MID(B2,5,2),RIGHT(B2,2))
    
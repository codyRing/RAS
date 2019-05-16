
$base = "C:\Projects\RAS_Operations\BCBS"
$filename = "BUGTI4BF_27_IN317A_GETINSURED_HRA_FILE_20190506"
$ext = ".csv"

Clear-Content ($base  + "\Altered\" + $Filename +"_ValidID"  + $Ext)
Clear-Content ($base  + "\Altered\" + $Filename +"_ErrorID"  + $Ext)



Get-Content ($base  + "\Original\" + $Filename  + $Ext) | % {
    $row = $_
    Write-verbose $Row
    $Hicn = $Row.ToString().Split(",")[1].trim()
    $Ssn = $Row.ToString().Split(",")[2].trim()

    If (Test-Hicn -Id $Hicn) {
Try{
        if (Test-Ssn -Id $Ssn){
            $row|Add-Content ($base  + "\Altered\" + $Filename +"_ValidID"  + $Ext)
                #Write-Host  $Hicn ":Valid Hicn"  $Ssn ":Valid SSN"
        
        
        }else{$row|Add-Content ($base  + "\Altered\" + $Filename +"_ErrorID"  + $Ext)}
        }Catch{$row|Add-Content ($base  + "\Altered\" + $Filename +"_ErrorID"  + $Ext)}

    }else{$row.replace($hicn,'')|Add-Content ($base  + "\Altered\" + $Filename +"_ErrorID"  + $Ext)}
#}Finally {$row|Add-Content ($base  + "\Altered\" + $Filename +"_ErrorID"  + $Ext)}
}



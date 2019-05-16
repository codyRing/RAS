CD "L:\RAS\Projects\RAS_Operations\"
Import-Module .\commands\RAS_MBI.psm1 -Force
Import-Module .\commands\Utilities.psm1 -Force

$base = "C:\Projects\RAS_Operations\"
$carrier = "CVS_Caremark"
$filename = "BUCKCONSULTING_20190514"
$Ext = ".txt"



Export-MappedFile -Carrier $carrier `
-Path ($base + $carrier + "\Original\" + $Filename + $Ext) `
-Destination ($base + $carrier + "\Mapped\" + $Filename + "_Mapped" + $Ext ) 

#altered
#original
#mapped



Start-Process notepad++ ($base + "commands\Need_MBI_Mapping.txt")


#Add-MbiMapping -MBI 7QM2RC3FK06 -SSN 250781664

#Get-ChildItem -Path $path | % {Rename-Item $_.FullName -NewName ([string]$_.Name).ToUpper()};

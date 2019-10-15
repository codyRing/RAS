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
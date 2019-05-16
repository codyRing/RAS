$ValidIds = @()
$base = "C:\Projects\RAS_MBI\"
$carrier = ""
$filename = ""
$Outfile = ""
$Ext = ""
$Delimiter = "`t"

Get-Content "C:\Projects\RAS_MBI\RAS_Operations_Commands\ID_list.txt" | % {
$ValidIds += $_
}

Get-ChildItem ($base + $carrier + "\original_Files\" + $Filename  + $Ext) | % {
    $APRFile = $_
    Get-Content $APRFile | % {
        $Row = $_
        write-verbose $row
        $Id = $Row.ToString().Split($Delimiter )[2]
        If ($ValidIds -contains $Id) {
            $Row | Add-Content ($base + $carrier + "\Altered_Files\" + $Outfile + $Ext)
        }
    }
}

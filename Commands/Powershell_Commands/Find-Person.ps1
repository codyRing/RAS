$base = "L:\RAS\Projects\RAS_Operations\"
$Pattern = ""
$carrier = ""


Select-String -Path ($base + $carrier + "\original\*")  -Pattern $Pattern |
Select-Object Line | Where-Object {!($_.psiscontainer)} | foreach {$_.Line} | set-content ($base + "output.txt")
#Select-Object   Filename,Line | set-content ($base + "output.txt")



Get-Content ($base + "output.txt") | Sort-Object { $_.split("`t")[1] } -Descending | set-content ($base + "output.txt")
#Get-Content ($base + "output.txt") | Sort-Object { $_.split(",")[1] } -Descending | set-content ($base + "output.txt")



#Sort-Object ($base + "output.txt")
Start-Process notepad++ ($base + "output.txt")



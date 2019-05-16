$base = "C:\Projects\RAS_Operations\"
$Pattern = "8V02AW8TY90"
$carrier = "UHC_AARP"


Select-String -Path ($base + $carrier + "\Original\*")  -Pattern $Pattern |
#Select-Object Line | Where-Object {!($_.psiscontainer)} | foreach {$_.Line} | set-content ($base + "output.txt")

Select-Object   Filename,Line | set-content ($base + "output.txt")



Get-Content ($base + "output.txt") | Sort-Object { $_.split("`t")[5] } -Descending | set-content ($base + "output.txt")



#Sort-Object ($base + "output.txt")
Start-Process notepad++ ($base + "output.txt")
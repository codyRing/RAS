$Path ="C:\Users\cody.ringrissler\Downloads\"
$output = "C:\Users\cody.ringrissler\Documents\TextFiles\output.txt"
cd $path
Get-ChildItem -Path $path | % {Rename-Item $_.FullName -NewName ([string]$_.Name).ToUpper()}|set-content $output;
#Get-ChildItem -Path $path | rename-item -newname { $_.name.substring(11) }

gci $path |set-content $output
Start-Process notepad++ $output
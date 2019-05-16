$path = "C:\Users\cody.ringrissler\Downloads\"
$output = "C:\Users\cody.ringrissler\Documents\TextFiles\output.txt"

GCI $path -Include *.csv -Recurse | 
   % { $_ | select name, @{n="lines";e={
       get-content $_ | 
         measure-object -line |
             select -expa lines }
                                       } 
     } | Set-Content $output
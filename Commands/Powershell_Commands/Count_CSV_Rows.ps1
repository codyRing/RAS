$path = "C:\Users\cody.ringrissler\Downloads"
gci ".\*.csv" |  % { $_ | 
            select name , 
            #@{n="header";e={get-content $_ |  Select-Object -First 1 }}  
            @{n="rows";e={get-content $_ |  measure-object -line | select -expa lines }}                                      
			} | export-csv ".\Headers.csv"
            #} | set-content ".\Row_Count.txt"
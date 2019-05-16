$path = "C:\Projects\RAS_Operations\UHC_AARP\Original\"
$string = "*20190513*"
$pathnew = "C:\Projects\RAS_Operations\UHC_AARP\Altered\"


gci ($path + $string) |Select-Object BaseName,FullName | % {
    $file = $_
    #(Get-Content $file.FullName -Raw).Replace("`r`n","`n") | Set-Content ($pathnew +"New_" + $file.BaseName) #CRLF > LF
    (Get-Content $file.FullName -Raw).Replace("`n","`r`n") | Set-Content ($pathnew  + $file.BaseName + ".txt") #LF > CRLF
    
    }



  #Get-ChildItem "C:\Projects\RAS_Operations\UHC_AARP\Altered\*"| Rename-Item -NewName { [io.path]::ChangeExtension($_.name, "txt") }
  #Get-ChildItem "C:\Projects\RAS_Operations\UHC_AARP\Altered\New_BCUHI2BF_BUCK_CONSUL_PREMIUMS_20190505"| Rename-Item -NewName { $_.name.Replace("New_","")}
cd "C:\Users\cody.ringrissler\Downloads"

$files = @{}
$test = 'Test'
 


Get-ChildItem | %{
   #$newFilename = ($_.BaseName.ToUpper())+($_.Extension.ToUpper());
   #Rename-Item $_ -NewName $newFilename
   if($_  -match '[0-9]{8}' )
      {$files.Add($matches[0])
      
      if($_  -match 'BUGTI4BF_45_1_AETNA') 
        {
          $files.Add($_.basename )
          #$files.Add($_.basename)
          }
               
              
                       
}}

$files

    
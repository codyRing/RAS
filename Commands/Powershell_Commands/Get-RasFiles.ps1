$base = "L:\RAS\Projects\RAS_Operations\"
$output = "L:\RAS\Projects\RAS_Operations\Ras_Files_temp.csv"
$output2 = "L:\RAS\Projects\RAS_Operations\Ras_Files.csv"
$output3 = "L:\RAS\Projects\RAS_Operations\Ras_Files_Rows.csv"


gci $base -File -R | ?{$_.fullname -like '*Original*' }|
Select-Object `
    Directory, 
    basename,
    Extension,
    @{label='DateSubString';expression = { $_.BaseName.substring($_.BaseName.length-8,8)}} |
   # @{l="rows";e={ $_.FullName |  measure-object -line | select -expa lines }} |
Export-Csv $output


Import-Csv $output |select *, @{l='DateFormat' ; expression = {[datetime]::parseexact($_.DateSubString , 'yyyyMMdd', $null).ToString('yyyy-MM-dd')}} |Export-Csv $output2
Remove-Item $output




#Still want to Get the number of Rows as well as the Carrier out of the Filepath







#GCI ($base) -R | ?{$_.fullname -like '*Original*' } | 
#   % { $_ | select name, @{n="lines";e={
#       get-content $_ | 
#         measure-object -line |
#             select -expa lines }                                       } 
#     } | Export-Csv $output3


#Get-ChildItem -Path ($base +'UHC_AARP\Original\*' | % {Rename-Item $_.FullName -NewName ([string]$_.Name).ToUpper()};
$url = @{
"RAS" = "https://www.retireehix.com/";
"Ticket" = "https://jira.getinsured.com/secure/Dashboard.jspa";
"BW" = "https://bwadmin.lh1ondemand.com/Login.aspx";
"WW" = "https://employer.wageworks.com/Login";
"Cap" = "https://www.getinsured.com/account/user/login";
}

Function Open-Url{
Param(
    [parameter(Position = 0, Mandatory = $true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [string] $url
)

[System.Diagnostics.Process]::Start("firefox.exe","$url")
 
[System.Diagnostics.Process]::Start("chrome.exe", $url)

[System.Diagnostics.Process]::Start("chrome.exe","--incognito $url")

}



#Open-Url $url.ras
#Open-Url $url.BW
#Open-Url $url.WW
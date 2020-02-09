$ErrorActionPreference = 'silentlycontinue'

 

$head = @'

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">

<html><head><title>$($ReportTitle)</title>

<style type=”text/css”>

<!–

body {

    font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;

}

h2{ clear: both; font-size: 100%;color:#354B5E; }

h3{

    clear: both;

    font-size: 75%;

    margin-left: 20px;

    margin-top: 30px;

    color:#475F77;

}

table{

    border-collapse: collapse;

    border: none;

    font: 10pt Verdana, Geneva, Arial, Helvetica, sans-serif;

    color: black;

    margin-bottom: 10px;

}

 

table td{

    font-size: 12px;

    padding-left: 0px;

    padding-right: 20px;

    text-align: left;

}

 

table th {

    font-size: 12px;

    font-weight: bold;

    padding-left: 0px;

    padding-right: 20px;

    text-align: left;

}

->

</style>

'@

 

$logfile = new-item -itemtype File -name "SOCTools.html" -force

 

$sites = @('www.google.com', 'www.facebook.com')

 

foreach ($site in $sites)

{

    # Create the request.

    $HTTP_Request = [System.Net.WebRequest]::Create("$site")

 

    # Get a response from the site

    $HTTP_Response = $HTTP_Request.GetResponse()

    $HTTP_Time = (Measure-Command {$HTTP_Response}).TotalMilliseconds

 

    # Get the integer of the HTTP response code

    $HTTP_Status = [int]$HTTP_Response.StatusCode

 

    If ($HTTP_Status -eq 200) {

        #Write-Host "$site is ok" -ForegroundColor Green

        Add-Content $logfile "<tr><td>$site is ok</td><td>$HTTP_Time Millisecond ping</td></tr>, | "

        #Write-Host "$HTTP_Time Millisecond ping"

    }

    Else {

        Write-Host "The Site may be down, please check!" -ForegroundColor DarkRed

    }

 

Add-Content $logfile "<tr><td>$HTTP_Status</td><td>$HTTP_Time</td></tr>"

 

    # Clean up after request complete!

    $HTTP_Response.Close()

}

 

C:\scripts\SOCTools.html | ConvertTo-Html -As LIST -Body $global:Html -Title SOC TOOLS STATUS -head $head

 

Invoke-Item "C:\scripts\SOCTools.html"

 

Start-Sleep -Seconds 15

 

#Rm "C:\scripts\SOCTools.html"
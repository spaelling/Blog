Just as the title says, in this post I will show how to write a simple
website using Azure Function App in the still \"experimental language\"
PowerShell. You can skip ahead and view there result
[here](https://funcapppswebsite.azurewebsites.net/api/PSWebsite).

Doug Finke already
[showed](https://dfinke.github.io/powershell/2018/04/24/PowerShell-Serving-an-HTML-Page-from-Azure-Functions.html)
how to do this, but in his example you need to write the HTML code
yourself. Being the lazy programmer I am, I wanted to use
[ConvertTo-Html](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertto-html?view=powershell-6).
I am assuming you are familiar with rolling a Function App. Go ahead and
create a HTTP trigger function and language set to PowerShell.
::: {.separator}
[![](https://4.bp.blogspot.com/-IGM7kc0hqgc/W1jIRdZYnMI/AAAAAAAAk_c/UoMZTFvJEbc2pyglBdIMf_rQ6Iy09JMdgCLcBGAs/s640/funcappps.PNG){width="640"
height="152"}](https://4.bp.blogspot.com/-IGM7kc0hqgc/W1jIRdZYnMI/AAAAAAAAk_c/UoMZTFvJEbc2pyglBdIMf_rQ6Iy09JMdgCLcBGAs/s1600/funcappps.PNG)
:::
Name it however you like and leave other settings to default.
The real magic happens with the discovery of the -Fragment switch to
ConvertTo-Html. It will provide you only with the body, meaning you can
combine multiple fragments, and that is exactly what is needed to output
HTML in a Function App.
The code part is pretty basic. We have some CSS, some semi-static HTML,
and then using ConvertTo-Html to output available PS-modules.
```
# inline CSS - stole this somewhere, sorry dude, can't remember
$style = @"
h1, h2, h3, h4, h5, th { text-align: center; }
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
"@
# html part - show Azure modules and non-Azure modules available in Function Apps
$html = @"
<head><style>$style</style></head>
<title>Hello PS Website</title>
<h1>Hello PS Website</h1>
<h5>Time is $(Get-Date)</h2>
<h2>Azure modules</h2>
$(get-module -ListAvailable | where-object {$_.name -like "*azure*"} | ConvertTo-Html -Fragment -property Name, version)
<h2>Other modules</h2>
$(get-module -ListAvailable | where-object {$_.name -notlike "*azure*"} | ConvertTo-Html -Fragment -property Name, version)
"@
# thank you Doug!
@{
headers = @{ "content-type" = "text/html"}
body    = $html
} | ConvertTo-Json | Out-File -Encoding Ascii -FilePath $res
```
The output will look something like this
::: {.separator}
[![](https://1.bp.blogspot.com/-no_Vx6uWTME/W1jKs0wQPBI/AAAAAAAAk_o/2dRsltX3Elk2qWBdrrsFa7upA4MZGUl_wCLcBGAs/s640/websiteout.PNG){width="330"
height="640"}](https://1.bp.blogspot.com/-no_Vx6uWTME/W1jKs0wQPBI/AAAAAAAAk_o/2dRsltX3Elk2qWBdrrsFa7upA4MZGUl_wCLcBGAs/s1600/websiteout.PNG)
:::
```
```

I love writing PowerShell in Azure Functions - it is a mixed blessing
not having to worry about a VM (or VMs), but I hope to share a few tips
that will result in fewer hairs being torn.

Forget Write-\* except Write-Output. Write-Error will work just like
throw (which I would then much prefer to use).
It can be inconvenient that Write-Verbose in (ordinary PowerShell)
functions is lost, and you cannot use Write-Output in a function as that
would go towards the output of the function, and not the log stream. But
there is a trick if you really need that verbose output, you can
redirect it (read more on that
here](https://blogs.technet.microsoft.com/heyscriptingguy/2014/03/30/understanding-streams-redirection-and-write-host-in-powershell/)).
Try running below.
```
# this will do nothing
Write-Verbose "Verbose"
# redirect verbose stream
Write-Verbose "Verbose redirected to success stream" -Verbose 4>&1
# verbose output in function
function function_with_verbose {
[CmdletBinding()]
param (
)
Write-Verbose "this is verbose"
Write-Verbose "more verbose"
# output result
4
}
# redirect verbose stream
$result = function_with_verbose -Verbose 4>&1
# assuming just a single out
Write-Output "output from function"
($result | Select-Object -Last 1)
Write-Output "The verbose stream"
# everything but the last
$result[0..($result.length-2)]
```
All depending this may or may not be worth the trouble. I think that at
some point the other streams will be displayed in the logging output.
There is some documentation on importing modules in a Function App, but
what I found the best was to first use Save-Module to download to disk,
then in Platform features in the app there is something called Advanced
tools (Kudu). Click that and a new tab opens. In the top click Debug
Console and select either.
I usually create a new folder (the big + sign) in root, lib, and in that
another folder modules. Here you can drag and drop the module folder you
just downloaded.
You can zip the module folders before uploading if you like, they are
unzipped automatically. Note down the full path to the psd1 file that
you will import. When importing in the function app simply
```
Import-Module "D:\home\lib\modules\AzureRM.profile\5.3.4\AzureRM.Profile.psd1"
```
I I have often seen a -global appended to this command. Not sure why, I
have had no luck getting global variables to work. This leads to my next
point, when using any Azure PowerShell modules you need to authenticate
using ex. Login-AzureRmAccount. Problem with this is that if you have
multiple functions running at the same time they will leak into each
other, especially something like Select-AzureRmSubscription will mess
you up!
Luckily there is a solution for this (same for Login-AzureRmAccount).
```
$DefaultProfile = Select-AzureRmSubscription -SubscriptionId $SubscriptionId -Tenant $TenantId -Scope Process
```
The \$DefaultProfile is then used in all subsequent calls ex.
```
Get-AzureRmResource -ResourceType 'Microsoft.DevTestLab/labs/virtualMachines' -ResourceGroupName $ResourceGroupName -ExpandProperties -DefaultProfile $DefaultProfile
```
Now in case a different instance of the same function runs at the same
time, it will not interfere. As it is tedious to add this everywhere you
can
use [\$PSDefaultParameterValues](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_parameters_default_values?view=powershell-6) and
also removes the risk you forgot this somewhere.
```
$PSDefaultParameterValues = @{'*:DefaultProfile' = $DefaultProfile}
```
I use a Managed Service Identity to login to Azure. Under Platform
features there is an item \"Managed service identity\" - click it and
select On.
To run below you need the MSI application Id. You find it in Azure
Active Directory under App Registrations (select All apps) and search
for your function app name. Copy the application Id. I have added it to
Application Settings, and then accessible from \$env:
```
$apiVersion = "2017-09-01"
$resourceURI = "https://management.azure.com/"
$tokenAuthURI = $env:MSI_ENDPOINT + "?resource=$resourceURI&api-version=$apiVersion"
$tokenResponse = Invoke-RestMethod -Method Get -Headers @{"Secret"="$env:MSI_SECRET"} -Uri $tokenAuthURI
$accessToken = $tokenResponse.access_token
$DefaultProfile = Login-AzureRmAccount -Tenant $TenantId -AccountId $env:ApplicationId -AccessToken $accessToken -Scope Process
```
Note that this may fail if the MSI has access to no resources in any
subscription. Anyways, it would be rather pointless if it does not.

**Converted from html using [convert.ps1](https://github.com/spaelling/Blog/blob/master/convert.ps1)**


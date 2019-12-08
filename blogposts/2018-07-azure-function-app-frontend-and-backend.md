There are (many) different ways Function Apps can call other function
apps. The perhaps most obvious (classic) way is making a web-request,
from one function-endpoint to another. I have my \"frontends\" in
Function App functions protected with \"App Service Authentication\" -
one must login with Azure AD to authenticate one self (use the
\"express\" settings to configure this to get it quickly setup).

Once configured add your users to the *Managed application* in the
\"Users and groups\" tab.
::: {.separator}
[![](https://3.bp.blogspot.com/-CTvkcwfLKRI/W1tiWwkNkCI/AAAAAAAAlCs/lJ9igVQM7mIqqSCgwM79zhnJdjYH4qtkgCLcBGAs/s640/blog1.PNG){width="640"
height="338"}](https://3.bp.blogspot.com/-CTvkcwfLKRI/W1tiWwkNkCI/AAAAAAAAlCs/lJ9igVQM7mIqqSCgwM79zhnJdjYH4qtkgCLcBGAs/s1600/blog1.PNG)
:::
::: {.separator}
:::
These users will be allowed access to all the functions in your Function
App. That seems pretty secure! You can even add Conditional Access to
the application for added security.
Only problem is that if you want to make requests to other functions in
the same Function App, then you would also have to authenticate, from
the function, and I have so far given up to get this to work.
So I had to cook up some alternative. What I found was having 2 Function
App instances, one is the frontend, and authentication is done using AAD
as mentioned before, the backend is not protected by AAD authentication,
but you do need a function key to access a given function (ie. no
anonymous calls to this endpoint), and we can encrypt the response (also
with a key), and both keys will be stored in Azure Key Vault.
Create 2 function apps and a key vault. In the key vault create a secret
called encryptionKey, the value should be 32 characters long (256 bits),
and the other is named to match the function and the value being the
functions key (found in the *Manage* tab of a function, named default).
::: {.separator}
[![](https://2.bp.blogspot.com/-CHiA6D538bE/W1t2pU3WfZI/AAAAAAAAlDI/YBBpzuUer_gq5XFdqqpLWGsW-vlWq5-4ACLcBGAs/s640/kv.PNG){width="640"
height="176"}](https://2.bp.blogspot.com/-CHiA6D538bE/W1t2pU3WfZI/AAAAAAAAlDI/YBBpzuUer_gq5XFdqqpLWGsW-vlWq5-4ACLcBGAs/s1600/kv.PNG)
:::
Next step is to enable *Managed service identity* on both Function Apps.
You can do this under *platform features*, same place as you find
*Application settings*. Now you need to note down the application id of
both function apps, you can find that in the Azure portal under *Azure
Active Directory-\>Enterprise Applications*. They will be named the same
as your function apps.
Add these values to their respective application settings under the name
*ApplicationId*.
In both Function Apps create a PowerShell Http trigger function.
**Code for the frontend**
```
# get a token for the key vault
$apiVersion = "2017-09-01"
$resourceURI = "https://vault.azure.net"
$tokenAuthURI = $env:MSI_ENDPOINT + "?resource=$resourceURI&api-version=$apiVersion"
$tokenResponse = Invoke-RestMethod -Method Get -Headers @{"Secret"="$env:MSI_SECRET"} -Uri $tokenAuthURI
$accessToken = $tokenResponse.access_token
# remember to set these
if(-not $accessToken) {throw "unable to fetch access token"}
if(-not $env:ApplicationId) {throw "application id not set in environmental settings"}
# get the function key first
# get the base url from the "overview" tab in the key vault
$secretName = 'somebackend'
$uri = "https://cbfuncappkv.vault.azure.net/secrets/{0}?api-version=2016-10-01" -f $secretName
$Headers = @{Authorization ="Bearer $accessToken"}
$KeyvaultResponse = (Invoke-WebRequest -UseBasicParsing -Uri $uri -Method Get -Headers $Headers).Content | ConvertFrom-Json
# get the value of the secret
$FunctionKey = $KeyvaultResponse | Select-Object -ExpandProperty value
# now ready to make a request to the backend
$uri = "https://cbfuncappbackend.azurewebsites.net/api/somebackend?code={0}" -f $FunctionKey
$Headers = @{'content-type' = "application/x-www-form-urlencoded"}
# oh oh, the response we got back is encrypted!
$EncryptedOutput = (Invoke-WebRequest -UseBasicParsing -Uri $uri -Method Get -Headers $Headers).Content | ConvertFrom-Json
# retrieve the encryption key from key vault
$secretName = 'encryptionKey'
# get the base url from the "overview" tab in the key vault
$uri = "https://cbfuncappkv.vault.azure.net/secrets/{0}?api-version=2016-10-01" -f $secretName
$Headers = @{Authorization ="Bearer $accessToken"}
$KeyvaultResponse = (Invoke-WebRequest -UseBasicParsing -Uri $uri -Method Get -Headers $Headers).Content | ConvertFrom-Json
# get the value of the secret
$encryptionKey = $KeyvaultResponse | Select-Object -ExpandProperty value
$Key = ([system.Text.Encoding]::UTF8).GetBytes($encryptionKey)
# decrypt the secure string
$DecryptedSecureString = $EncryptedOutput | ConvertTo-SecureString -Key $Key
# copies the content of the secure string into unmanaged memory
$ptr = [System.Runtime.InteropServices.marshal]::SecureStringToBSTR($DecryptedSecureString)
# convert to a string
$DecryptedOutput = [System.Runtime.InteropServices.marshal]::PtrToStringAuto($ptr)
# html part -
$html = @"
<head><style>$style</style></head>
<title>Hello PS Backend</title>
<h1>Hello PS Backend</h1>
<h5>Time is $(Get-Date)</h2>
$DecryptedOutput
"@
# output as a webpage
@{
headers = @{ "content-type" = "text/html"}
body    = $html
} | ConvertTo-Json | Out-File -Encoding Ascii -FilePath $res
```
**And for the backend**
```
# get a token for the key vault
$apiVersion = "2017-09-01"
$resourceURI = "https://vault.azure.net"
$tokenAuthURI = $env:MSI_ENDPOINT + "?resource=$resourceURI&api-version=$apiVersion"
$tokenResponse = Invoke-RestMethod -Method Get -Headers @{"Secret"="$env:MSI_SECRET"} -Uri $tokenAuthURI
$accessToken = $tokenResponse.access_token
# remember to set these
if(-not $accessToken) {throw "unable to fetch access token"}
if(-not $env:ApplicationId) {throw "application id not set in environmental settings"}
# retrieve the encryption key from key vault
$secretName = 'encryptionKey'
# get the base url from the "overview" tab in the key vault
$uri = "https://cbfuncappkv.vault.azure.net/secrets/{0}?api-version=2016-10-01" -f $secretName
$Headers = @{Authorization ="Bearer $accessToken"}
$KeyvaultResponse = (Invoke-WebRequest -UseBasicParsing -Uri $uri -Method Get -Headers $Headers).Content | ConvertFrom-Json
# get the value of the secret
$encryptionKey = $KeyvaultResponse | Select-Object -ExpandProperty value
# secure and encrypt the below output
$Output = "Hello from the backend"
# convert our encryption key to byte array, if string is 32 characters, we get 8*32=256 bit encryption
$Key = ([system.Text.Encoding]::UTF8).GetBytes($encryptionKey)
# convert to secure string, then to en encrypted string (the string must be secure before it can be encrypted)
$EncryptedOutput = $Output | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString -key $key
# write encrypted output
Out-File -Encoding Ascii -FilePath $res -inputObject $EncryptedOutput
```
Lastly we need to grant access to the secrets in the key vault,
*Get* operation on secrets is sufficient.
::: {.separator}
[![](https://4.bp.blogspot.com/-YWXdVvZQyOA/W1uV3Btp5tI/AAAAAAAAlDU/gWrjrwXEp5MfZ5tMjqSD9-JS45YGQXK5gCLcBGAs/s640/kvaccess.PNG){width="640"
height="566"}](https://4.bp.blogspot.com/-YWXdVvZQyOA/W1uV3Btp5tI/AAAAAAAAlDU/gWrjrwXEp5MfZ5tMjqSD9-JS45YGQXK5gCLcBGAs/s1600/kvaccess.PNG)
:::
Optionally enable AAD authentication on the frontend Function App before
running the example, and in that case remember to add your own user!
For added security you could add a timed trigger function that resets
the keys in the key vault at regular intervals. To make sure matching
encryption keys are used (in both ends), you could provide the version
of the encryption key as part of the response.
I also think that you can use service endpoints on the key vault so that
only these functions are able to retrieve the key in the first place.
The result should look like this
::: {.separator}
[![](https://3.bp.blogspot.com/-2A0dQBIwFig/W1uZeH3lcvI/AAAAAAAAlDg/VnK-LfgXBmgsAgcKCAX-2xDNF5qIqfU6wCLcBGAs/s640/res.PNG){width="640"
height="174"}](https://3.bp.blogspot.com/-2A0dQBIwFig/W1uZeH3lcvI/AAAAAAAAlDg/VnK-LfgXBmgsAgcKCAX-2xDNF5qIqfU6wCLcBGAs/s1600/res.PNG)
:::

Converted from html using https://github.com/spaelling/Blog/blob/master/convert.ps1 


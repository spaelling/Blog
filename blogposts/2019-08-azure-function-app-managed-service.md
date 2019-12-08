I started using MSI in Function Apps a few years ago. Back then it was
still a nice quality of life addition, but you had to jump through a few
hoops to get it working, ex. this was necessary to use the MSI to login
to Azure.


```

    $apiVersion = "2017-09-01"
    $resourceURI = "https://management.azure.com/"
    $tokenAuthURI = $env:MSI_ENDPOINT + "?resource=$resourceURI&api-version=$apiVersion"
    $tokenResponse = Invoke-RestMethod -Method Get -Headers @{"Secret"="$env:MSI_SECRET"} -Uri $tokenAuthURI
    $accessToken = $tokenResponse.access_token
    Login-AzAccount -Tenant $TenantId -AccountId $env:WEBSITE_SITE_NAME -AccessToken $accessToken -Scope Process

```


After not having done too much with Function Apps for a while I jumped
back in and just could not wrap my head around how to get MSI working in
a local development environment (I use VS Code). No help to find on the
Internet, at least not explicitly stating how to do it. And for a good
reason; the trick is to do nothing at all!

When running locally everything is done in the context of the logged in
user, often the developer him/herself.
Above code would also fail (there is no *MSI\_ENDPOINT* and much less an
*MSI\_SECRET*). But all the magic happens in profile.ps1 that is
auto-created for each function app project. It is already outfitted with
below code.



```

    # Authenticate with Azure PowerShell using MSI.
    # Remove this if you are not planning on using MSI or Azure PowerShell.
    if ($env:MSI_SECRET -and (Get-Module -ListAvailable Az.Accounts)) {
        Connect-AzAccount -Identity
    }

```



If there is an *MSI\_SECRET* in the environment variables (which there
should not be in a local development environment), then connect using an
MSI, which I imagine doing something similar to the first piece of code
I posted.
Another advantage is that you only do the login once (when the function
app does a \"cold start\"). Previously it would be rather dodgy, and to
be on the safe side, I would login in each function run, adding
significant overhead.

And when running locally the entire thing is piggybacking off the logged
in user. If you want to simulate the access the MSI has when running in
Azure, just create a service principal, assign it the same roles as the
MSI and login before running your code locally.

Running PowerShell in Azure Function App has come a long way. With the
new **Push-OutputBinding** it is even easier than before to put the
result of a function execution into a queue, table storage, etc.

```

```

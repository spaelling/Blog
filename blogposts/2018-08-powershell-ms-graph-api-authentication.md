I had to access the MS Graph API from Azure Function App and after
wasting some time trying to get it to work with a Managed Service
Identity (you can get a token, but cannot assign the MSI any roles,
yet), I opted for the good ol\' Service Principal (SP).

There are several blogpost on how to get a token for various Microsoft
APIs, and most of the code is very similar, but they are all lacking one
essential detail, without it you may get varying results.

I experienced getting a token that the API claimed was invalid, one that
was expired, not getting a token because the SP secret was incorrect (it
was not), and maybe just that no overload of the function could be
found. Clearly I was doing something wrong.

For good measure, here is a short guide on getting a working SP. Go to
Azure AD,-\> App Registrations, and create a new app registration.
The application type is web app/API, you can put anything in the sign-on
URL.


::: {.separator}
[![](https://1.bp.blogspot.com/-L0q-gDfE_K4/W4A_FLhD8-I/AAAAAAAAlPY/1VIvpySLgtQ3y4DBvdCw_vj7_5JVPwV6QCLcBGAs/s640/newappreg.PNG){width="640"
height="384"}](https://1.bp.blogspot.com/-L0q-gDfE_K4/W4A_FLhD8-I/AAAAAAAAlPY/1VIvpySLgtQ3y4DBvdCw_vj7_5JVPwV6QCLcBGAs/s1600/newappreg.PNG)
:::


This will also create an enterprise application.

In the settings of the newly registered app click Settings, and under
API Access click Required permissions. Add a new permission and select
the Microsoft Graph API, and check off the permissions needed.


::: {.separator}
[![](https://1.bp.blogspot.com/-EJO3n4u4O3s/W4A_9Ucqf-I/AAAAAAAAlPg/cA2u4-pguE8h06skrhrJOqASH5giIfqMgCLcBGAs/s640/newperm.PNG){width="640"
height="394"}](https://1.bp.blogspot.com/-EJO3n4u4O3s/W4A_9Ucqf-I/AAAAAAAAlPg/cA2u4-pguE8h06skrhrJOqASH5giIfqMgCLcBGAs/s1600/newperm.PNG)
:::

::: {.separator}

:::

::: {.separator}

:::

When done you need to click Grant Permissions.

Next click Keys. Fill in a description, select when the key should
expire and click Save. The key will be generated and shown. Save this
for later.

Back in your app registration copy the Application ID.

Next we need a dll
file, Microsoft.IdentityModel.Clients.ActiveDirectory.dll - this is the
main contribution of this blog. It just happens that there is many
different versions of this, and you need the right one to get a working
token.
I found that the one in [AzureRm.Profile
5.3.4](https://www.powershellgallery.com/packages/AzureRM.profile/5.3.4)
works just fine. I would guess versions close to this one is the same.
You can get it using Save-Module:


```

    Save-Module AzureRm.Profile -RequiredVersion 5.3.4 -Path C:\Temp

```


Now find Microsoft.IdentityModel.Clients.ActiveDirectory.dll and use
Add-Type to load it


```

    Add-Type -Path "C:\Temp\AzureRM.profile\5.3.4\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"

```


Next we need an important piece of information. Run this in a fresh
PS-session:


```

    [appdomain]::currentdomain.getassemblies() | Where-Object {$_.fullname -like "Microsoft.IdentityModel.Clients.ActiveDirectory*"} | Select-Object -Property Fullname

```


The result is what we need in the following function. We can use it to
specify that it is that exact dll-file we are referring to. There could
be many of these loaded, and if the wrong one is used we get a
non-desirable result.


```

    Function Get-AADToken {
        [CmdletBinding()]
        [OutputType([string])]
        Param (
            [String]$TenantID,
            [string]$ServicePrincipalId,
            [securestring]$ServicePrincipalPwd,
            $resourceAppIdURI = 'https://graph.microsoft.com/'
        )
        Try {
            # Set Authority to Azure AD Tenant
            $authority = 'https://login.windows.net/' + $TenantId

            $ClientCred = [Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential, Microsoft.IdentityModel.Clients.ActiveDirectory, Version=2.28.3.860, Culture=neutral, PublicKeyToken=31bf3856ad364e35]::new($ServicePrincipalId, $ServicePrincipalPwd)
            $authContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext, Microsoft.IdentityModel.Clients.ActiveDirectory, Version=2.28.3.860, Culture=neutral, PublicKeyToken=31bf3856ad364e35]::new($authority)
            $authResult = $authContext.AcquireTokenAsync($resourceAppIdURI, $ClientCred)

            if($authResult.Exception)
            {
                throw $authResult.Exception.InnerException.Message
            }
            
            $Token = $authResult.Result.AccessToken
        }
        Catch {
            Throw $_
        }
        $Token
    }

```


The function is called as follows


```

    # load this specific Microsoft.IdentityModel.Clients.ActiveDirectory.dll
    Add-Type -Path "C:\temp\AzureRM.profile\5.3.4\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"

    # your Azure AD tenant
    $TenantId = '55da3b96-2993-4ef3-ad6f-f0a066401f60'

    # the application id from the app registration
    $AppId = '135fee95-c7c3-48f5-9821-fcaf29fd8a3c'

    # the key we created - obviously do not store this in cleartext
    $ServicePrincipalPwd = '5a1mXQYcZNZADD8h2lSYxzSGHSF0U+chrpk0L5E0Cgw=' | ConvertTo-SecureString -AsPlainText -Force
    # get the token
    $Token = Get-AADToken -TenantID $TenantId -ServicePrincipalId $AppId -ServicePrincipalPwd $ServicePrincipalPwd

```


Now that we have a token, it is time to put it to work


```

    $Headers = @{
        "Authorization" = "Bearer $token"
    }

    try {
        $Response = Invoke-RestMethod -Uri 'https://graph.microsoft.com/v1.0/users/' -Method Get -UseBasicParsing -Headers $Headers
    }
    catch {
        $_
        $_.Exception.ErrorDetails.Message
    }

```

```

```

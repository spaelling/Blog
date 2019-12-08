I had a hard time finding out how to integrate a Github Repository into
Azure functions, or rather what files and the structure to put in the
repository so that Azure Functions would pick them up. A very basic
setup follows.

This assumes an understanding of Github and Azure Functions. There are
plenty of resources out there explaining that better than I can.
### Github
```
Create a fresh repository and create a file, *host.json*, in the root:
```
```
{
"functions" : [
"HelloAzureFunctions"
],
"id": "ed5d78e575e14f0481c899532d41f5c0"
}
```
```
Now create a folder called *HelloAzureFunctions*. Inside that create a
file, *function.json*:
```
    {
        "bindings": [
            {
                "type": "httpTrigger",
                "name": "req",
                "direction": "in",
                "methods": [ "get" ]
            },
            {
                "type": "http",
                "name": "res",
                "direction": "out"
            }
        ]
    }
```
And in this case we will use PowerShell; we need a file called
*run.ps1:*
```
    $requestBody = Get-Content $req -Raw | ConvertFrom-Json
    $name = $requestBody.name
    if ($req_query_name) 
    {
        $name = $req_query_name 
    }
    Out-File -Encoding Ascii -FilePath $res -inputObject "Hello, $name"
```
That is it! Commit to Github and go to your Azure Function app and
integrate with the repository. The *HelloAzureFunctions* should appear
as a function after a short while.
You can fork my repository if you
like, <https://github.com/spaelling/hello-azure-functions>. There is
also a a [PowerShell script there that can be used for
testing](https://github.com/spaelling/hello-azure-functions/blob/master/test.ps1)
(you can just paste in the webhook URI in a browser if you rather like
that).
Also keep your webhooks a secret. In the aforementioned script I show
how to get the webhook URI from an Azure Key Vault.
[![](https://3.bp.blogspot.com/-V4oxoyz6S28/V-j-sq8WcGI/AAAAAAAASt4/SKTRnfZM4bkMx3O2LuF7xaq4MbOVxw5BwCK4B/s640/1.PNG){width="640"
height="344"}](//3.bp.blogspot.com/-V4oxoyz6S28/V-j-sq8WcGI/AAAAAAAASt4/SKTRnfZM4bkMx3O2LuF7xaq4MbOVxw5BwCK4B/s1600/1.PNG)
```

Converted from html using https://github.com/spaelling/Blog/blob/master/convert.ps1 


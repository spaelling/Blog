I just realized a really easy way to install PS modules to an Azure
Function App. Just run below code in a function.
Make sure that \$ModulePath points to a folder path that exists. Look
into [KUDU](https://docs.microsoft.com/en-us/azure/azure-functions/functions-how-to-use-azure-function-app-settings#kudu) to
set this up.

```
<#
$ModulePath must not already contain the modules or this may fail
#>
$ModulePath = 'D:\home\lib\PSModules'
$NuGet = Get-PackageProvider -Name NuGet
if($null -eq $NuGet)
{
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser
}
"Saving modules to $ModulePath"
Save-Module AzureRm -Path $ModulePath -Force
"Listing import commands for every module"
Get-ChildItem -Path $ModulePath -Include "*.psd1" -Recurse | ForEach-Object {
"Import-Module '$($_.FullName)'"
}
```
I have created a Github repository containing this and other small
function app snippets. Above code will be updated
here: <https://github.com/spaelling/AzureFunctionAppSnippets/blob/master/PowerShell/HT_InstallModule.ps1>

**Converted from html using [convert.ps1](https://github.com/spaelling/Blog/blob/master/convert.ps1)**


If you have your function app running on a consumption plan and ever
considered to move it to a different plan then this may have stopped
you

![](https://4.bp.blogspot.com/-haeog5lBb7E/W4bnQRqK1QI/AAAAAAAAlSA/hycjI6N0dnwqURRUhPivh_UvhVImbd9uQCLcBGAs/s400/consmplan.PNG)
Being greyed out does not mean it is not possible, only that there is
not yet any portal support for it. But luckily this is possible using
PowerShell. The easiest way to achieve this is likely to start the Azure
Cloud Shell (top bar in the portal)
![](https://1.bp.blogspot.com/-fE5a5j1YGXg/W4boEirA6fI/AAAAAAAAlSI/B9QmX3JOlU8544L6SKEWcMhu4avoS_BegCLcBGAs/s400/cloudshell.PNG)
The shell will pop up in the bottom of the browser. Where it reads Bash,
click and select PowerShell.
First we need to select the relevant subscription (you are already
logged in). If you only have a single subscription in your tenant, skip
this step.
The subscription id is what follows /subscriptions/ in the browsers url,
ex.
https://portal.azure.com/\#\@mytenant.onmicrosoft.com/resource/subscriptions/**9734191f-63d9-4b3d-880e-8de9a40942f2**]
/resourceGroups/rgfuncapp/providers/Microsoft.Web/sites/funcapp/appServices]
Copy this value and enter (paste using mouse right click)
Select-AzureRmSubscription -SubscriptionId your\_subscription\_id
Before continuing make sure you have a new plan (the one you wish to
move to) in the same resource group and in the same region.
To move you need just a single command
Set-AzureRmWebApp -Name \"\[function name\]\" -ResourceGroupName
\"\[resource group\]\" -AppServicePlan \"\[new app service plan
name\]\"
You need to reload the browser before you see the change in the portal.
Please refer to <https://github.com/Azure/Azure-Functions/issues/155>
for further details. As you may notice this blogpost is simply
elaborating on a comment made on the issue, but it took me a while to
find that, so hopefully this helps someone while we wait for portal
support.

**Converted from html using [convert.ps1](https://github.com/spaelling/Blog/blob/master/convert.ps1)**


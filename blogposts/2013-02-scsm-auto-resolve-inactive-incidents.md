
::: {.p1}
Anders Bengtsson has provided a solution for [auto-closing
incidents](http://contoso.se/blog/?p=1629) in Service Manager. The
solution works well for closing a resolved incident, as one would
normally not wish to inform the *Affected User* that the incident has
been closed.
:::
::: {.p1}
In our system when an analyst inquires the *Affected User* for
additional information on an incident the status of the incident changes
to \"Pending user response\" which is filtered out in most of our
incident views (out of sight, out of mind). We also decided that these
incidents should automatically resolve after 5 days if we did not get a
response from the *Affected User*. The above mentioned solution could do
this with a minor change to the code, but as most email-templates would
use the *ResolutionDescription* to inform the user *why* the incident
was resolved, these would now provide no information in that regard.
The following Powershell-script solves this. I am in no way a PS-expert,
and I did borrow pieces of code in various places (my apologies for not
giving credit where credit is due). I did borrow code from
[here](http://blogs.technet.com/b/servicemanager/archive/2011/04/22/using-smlets-beta-3-post-3-using-set-scsmobject-to-bulk-update-properties-on-objects.aspx) which
helped me update multiple properties (Status & ResolutionDescription) in
an incident.
:::
::: {.p1}
:::
::: {.p1}
*Possible drawback:* as the criteria is based on *LastModified*,
analysts logging a comment (ex. Called Anne\'s office, but no answer) or
other activity on the incident would prolong the period it could stay in
\"Pending user response\". A way to get around this would be to extend
the incident with a field like \"PendingUserResponseSinceDate\" just
like Service Requests has a \"CompletedDate\", and test on this instead.
As we are using the SendMail plugin (which extends the incident with
Message and MessageType), I did not use this solution.
**Note**: Requires SCSM Powershell Cmdlets
from <http://smlets.codeplex.com/>
formatted using <http://codeformatter.blogspot.dk/>
:::
     Import-Module smlets  
     ######################################################################################################  
     # Author: Anders Spælling, spaelling@gmail.com  
     # Closes all incidents with pending status and unchanged for more than 5 days  
     ######################################################################################################  
     # set a resolution description  
     $ResolutionDescription = "Closed automatically due to inactivity"  
     # inactive for more than 5 days  
     $InactiveFordays = 5  
     $Incidents = @()  
     $Class = get-SCSMClass -Name System.WorkItem.Incident$  
     # Get Id of status enumeration  
     $PendingStatusId = (Get-SCSMEnumeration -Name "IncidentStatusEnum.Active.Pending").Id  
     # type is an object criteria  
     $cType = "Microsoft.EnterpriseManagement.Common.EnterpriseManagementObjectCriteria"  
     # get resolved status enumeration  
     $StatusResolved = Get-SCSMEnumeration -Name IncidentStatusEnum.Resolved  
     # set these properties on the incident  
     $PropertyHash = @{"ResolutionDescription" = $ResolutionDescription; "Status" = $StatusResolved}  
     $Then = (Get-Date).AddDays(-$InactiveFordays)  
     # criteria to filter on  
     $cString = "Status = '$PendingStatusId' and LastModified < '$Then'"  
     # create the object criteria  
     $criteria = new-object $cType $cString, $Class  
     Get-SCSMObject -criteria $criteria | Set-SCSMObject -PropertyHashtable $PropertyHash  

Converted from html using https://github.com/spaelling/Blog/blob/master/convert.ps1 


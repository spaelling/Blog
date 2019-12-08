The integration between Operations Manager and Service Manager is sadly
lacking. A connector can import SCOM alerts and create an incident, but
configuring incident properties based on the alert is simple (one can
set a number of custom fields on the alert), but an incident template is
required for each combination of properties (urgency, impact, and
support group). Depending on the number of possible (relevant) support
groups this can amount to quite a large number of templates. This issue
will be addressed later on, but to begin with we need to identify what
support group should handle which alert.\
\
I may (quite possibly) be missing a few details in the following, so
feel free to post a comment below.\
\
My approach is similar to how [ip
tables](http://en.wikipedia.org/wiki/Iptables) work. A list of rules
where one starts from the top going down until a rule criteria matches a
given alert. An [example](//goo.gl/99u4eh) could look like this where
each row corresponds a rule.\

Index

SCSM\_SG

Tag

Rule\_ID

MP\_name

Group

Comment

1

SG1

b59f78ce-c42a-8995-f099-e705dbb34fd4

Health Service Heartbeat Failure

2

SG2

308c0379-f7f0-0a81-a947-d0dbcf1216a7

Failed to Connect to Computer

3

SG2

Microsoft.Windows.\*.Cluster.Management.Monitoring

Cluster

4

SG2

Microsoft.Windows.Server.\*

OS

5

SG2

Microsoft.SystemCenter.2007

OS

6

SG1

Microsoft.SystemCenter.ServiceManager.Monitoring

OS

7

SG2

CB - Sharepoint servers

Sharepoint

8

SG2

Microsoft.SharePoint.\*

Sharepoint

9

SG1

Microsoft.Windows.FileServer.\*

File Service

10

SG2

Microsoft.Exchange.Server.\*

Exchange

11

SG2

Microsoft.SystemCenter.2012.Orchestrator

System Center

12

SG1

Microsoft.SystemCenter.OperationsManager.Infra

System Center

13

SG2

Microsoft.SystemCenter.OperationsManager.DataAccessService

System Center

14

SG2

Microsoft.SystemCenter.Apm.Infrastructure.Monitoring

System Center

15

SG2

Microsoft.SystemCenter.Apm.Infrastructure

System Center

16

SG2

Microsoft.SQLServer.\*

SQL

17

SG2

Microsoft.SystemCenter.Apm.NTServices

Application Performance

18

SG1

Microsoft.SystemCenter.Apm.Web

Application Performance

19

SG3

\*

Catch all

\
Where index defines the priority of the alert, SCSM\_SG is the support
group the alert (incident) should be mapped to, Tag, Rule\_ID, MP\_name,
Group are alert criterias and comment is well, a comment for the reader
to better understand each rule.\
Each alert is then matched against this table, stopping when the first
match is found. This allows generic alerts such as a heartbeat failure
to be handled by a specific support group, while all alerts for a
specific computer group mush be handled by the specified support group.
In this example rule index 7 is a sharepoint group in the Codebeaver
firm (possibly containing sharepoint related computers) is handled by
SG2 unless the alert matches one of the rules with a lower index (ie.
higher priority).\
Note that reach row/rule should only contain a single a single criteria
as the logic cannot handle multiple criteria (it should be fairly
trivial to edit the script to allow for multiple criteria on a single
rule).\

-   Tag is a well, tag, that is defined in the description of an alert,
    allowing custom alerts to be tagged by adding \#tag:mytag to the end
    of the alert description. This allows alerts defined in the same
    management pack to be routed based on a tag in the description
    (possibly inserted based on some variable)
-   Rule\_ID is just that, the rule ID
-   MP\_name is the name of a management pack. It supports wildcards,
    basically anything that the powershell -like comparison will acccept
-   Group is a computer group. Some monitoring objects will be child
    monitoring objects of a given computer group, ie. a disk monitor in
    the CB - Sharepoint Servers group.

\
The script is listed below (this is a long one, you may want to get a
cup of coffee/mug of beer before proceeding).\
\
*\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#*\
*\# Processes alerts in SCOM and marks the alert as ready to be*\
*\# forwarded to Service Manager.*\
*\#*\
*\# Authored by:*\
*\# Anders Spælling, spaelling\@gmail.com*\
*\# And a little help from my friends*\
*\#*\
*\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#*\
*\
\# EVENT IDs*\
*\# 600 - Information - Enumerating monitoring objects from specific
group*\
*\# 601 - Information - Forwarding alerts from specific group*\
*\# 602 - Information - Is alive ping*\
*\# 603 - Information - Forwarding remaining alerts (not member of
specified groups)*\
*\# 604 - Information - No new alerts*\
*\# 605 - Information - Going to sleep*\
*\# 606 - Information - Alert processed and forwarded to SM*\
*\# 607 - Information - Connected to SCOM mgt. srv.*\
*\# 700 - Error       - No matching group found*\
*\# 701 - Error       - Unable to connect to SCOM mngt. server*\
*\# 702 - Error       - Unable to update alert*\
*\# 703 - Error       - Alert forwarding for group failed*\
*\# 703 - Error       - Alert forwarding for remaining alerts failed*\
*\# 704 - Error       - Alert mapping failed*\
*\# 705 - Error       - Unable to load alert mapping rules*\
*\
\# will not commit changes to alerts or write to event-log*\
*\# will instead output these to write-host*\
*\$DEBUG\_MODE = \$false*\
*\
\# Load SCOM snap-in*\
*Import-Module OperationsManager*\
*\
\# Define constants*\
*\$SCOMComputerName = \"FILL THIS OUT\"*\
*\$EventLogName = \"SCOM Alert Forwarding\"*\
*\# sleep loop for 240 seconds*\
*\$SLEEPTIME = 240*\
*\# how long the loop runs, in minutes, set to 3h55m*\
*\$LOOPTIME = 3\*60+55*\
*\
\# customfield1 values - used by the SCSM connector to route IRs*\
*\$HIGH =  \"High\"*\
*\$MEDIUM = \"Medium\"*\
*\$LOW = \"Low\"*\
*\$NOT\_DEFINED = \"Not defined\"*\
*\$NOT\_MEMBER\_OF\_GROUP = \"Not member of group\"*\
*\
\# MAPPING*\
*\
\# recursive depth to list monitoring objects*\
*\$MAXDEPTH = 8*\
*\# location of alert mapping data*\
*\$RuleMappingFileLocation = \"AlertMapping.csv\"*\
*\
\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#*\
*\# HELPER FUNCTIONS \#*\
*\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#*\
*\
Function Write-SCOMEventLog*\
*{*\
*    Param(\$EventDescription,\$EventID,\$Type)*\
*\
    \$EventlogExists = Get-EventLog -ComputerName \$SCOMComputerName
-List \| Where-Object {\$\_.LogDisplayName -eq \$EventLogName}*\
*\
    If(-not \$EventlogExists)*\
*    {*\
*        New-EventLog -LogName \$EventLogName -Source AlertUpdate
-ComputerName \$SCOMComputerName*\
*    }*\
*\
    \# will not write to event log in debug mode*\
*    if(-not \$DEBUG\_MODE)*\
*    {*\
*        Write-EventLog -ComputerName \$SCOMComputerName -LogName
\$EventLogName -Source AlertUpdate -Message \"\$EventDescription\"
-EventId \$EventID -EntryType \$Type*\
*    }*\
*    else*\
*    {*\
*        Write-Host \"\*DEBUG\_MODE: Write-EventLog -ComputerName
\$SCOMComputerName -LogName \$EventLogName -Source AlertUpdate -Message
\`\"\$EventDescription\`\" -EventId \$EventID -EntryType \$Type\"*\
*    }*\
*   *\
*}*\
*\
\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#*\
*\# MAPPING FUNCTIONS \#*\
*\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#*\
*\
\# Get parent monitoring objects recursively*\
*Function Get-ParentMonitoringObject*\
*{*\
*    Param(\$MonitoringObjects, \[int\]\$Depth=0)*\
*\
    \# keep an eye on how deep we go in the recursion but only report it
in debug mode*\
*    if(++\$Depth -gt \$MAXDEPTH)*\
*    {*\
*        if(\$DEBUG\_MODE)*\
*        {*\
*            Write-Host \"Reached max depth for recursion, depth =
\$Depth\"*\
*        }*\
*    }*\
*\
    \$S = \[array\]\$MonitoringObjects*\
*\
    \# Get all parent monitoring objects for each monitoring object and
append these to \$S*\
*    foreach(\$MonitoringObject in \$S)*\
*    {*\
*        \$Result = Get-ParentMonitoringObject
\$MonitoringObject.GetParentMonitoringObjects() \$Depth*\
*        \#Write-Host \$Result*\
*        \$S += \$Result*\
*    }*\
*   *\
*    return \$S*\
*}*\
*\
Function Get-SupportGroup*\
*{*\
*    Param(\$Alert, \[array\]\$Groups)*\
*\
    \# Check if rules are loaded*\
*    if(\$Rules -eq \$null)*\
*    {*\
*        throw \"Alert mapping rules not loaded\"*\
*    }*\
*\
    \# We wish to map according to \'\#tag\' in the alert description,
rule id, MP name and finally group*\
*    \# The rules are loaded from a CSV file*\
*\
    \# \*\*\* optimizations/todo \*\*\**\
*        \# if the index is 1 then return support group*\
*\
    \# \* TAG MATCH \* \#*\
*\
    \# check if the alert description is tagged. this is possible in
custom made monitors where we wish to direct an alert to a specific
support group*\
*    \$AlertDescription = \$Alert.Description.ToLower()*\
*    \$IndexOfTag = \$AlertDescription.IndexOf(\"\#tag:\")*\
*    \$TagMatch = \$null*\
*    if(\$IndexOfTag -gt 0)*\
*    {*\
*        \$Tag =
\$AlertDescription.Substring(\$IndexOfTag).Replace(\"\#tag:\",\"\")*\
*\
        \# look for the first tag match in the rules*\
*        \$TagMatch = \$Rules \| ? {\$Tag -ilike \$\_.Tag} \|
Sort-Object {\[int\] \$\_.Index} \| select -First 1 \| select Index,
SCSM\_SG*\
*    }*\
*\
    \# DEBUG*\
*    if(\$TagMatch -and \$DEBUG\_MODE)*\
*    {*\
*        Write-Host (\"Tag match for \'\" + \$Alert.Name + \"\': \" +
\$TagMatch)*\
*    }*\
*\
    \# \* RULE ID MATCH \* \#*\
*\
    \$RuleId = \$Alert.RuleId.Guid*\
*   *\
*    \#*\
*    \$RuleIdMatch = \$Rules \| ? {\$\_.Rule\_ID -eq \$RuleId} \|
Sort-Object {\[int\] \$\_.Index} \| select -First 1 \| select Index,
SCSM\_SG*\
*\
    \# DEBUG*\
*    if(\$RuleIdMatch -and \$DEBUG\_MODE)*\
*    {*\
*        Write-Host (\"Rule ID match for \'\" + \$Alert.Name + \"\': \"
+ \$RuleIdMatch)*\
*    }*\
*\
    \# \* MANAGEMENT PACK NAME MATCH \* \#*\
*\
    \# Get the management pack name*\
*    if(\$Alert.IsMonitorAlert)*\
*    {*\
*        \$ManagementPackName = (Get-SCOMMonitor -ComputerName
\$SCOMComputerName -Id
\$Alert.MonitoringRuleId).GetManagementPack().Name*\
*    }*\
*    else*\
*    {*\
*        \$ManagementPackName = (Get-SCOMRule -ComputerName
\$SCOMComputerName -Id \$Alert.MonitoringRuleId).ManagementPackName*\
*    }*\
*\
    \$ManagementPackNameMatch = \$Rules \| ? {\$ManagementPackName
-ilike \$\_.MP\_name} \| Sort-Object {\[int\] \$\_.Index} \| select
-First 1 \| select Index, SCSM\_SG*\
*\
    \# DEBUG*\
*    if(\$DEBUG\_MODE)*\
*    {*\
*        Write-Host (\"Management pack name: \'\" + \$ManagementPackName
+ \"\'\")*\
*        if(\$ManagementPackNameMatch)*\
*        {*\
*            Write-Host (\"Management pack match for \'\" + \$Alert.Name
+ \"\': \" + \$ManagementPackNameMatch)*\
*        }*\
*    }*\
*\
\
    \# \* COMPUTER GROUP MATCH \* \#*\
*\
    \$ComputerGroupMatch = @()*\
*    if(\$Groups.Count -gt 1)*\
*    {*\
*        Write-Host \"More than 1 matching group found for
\$(\$Alert.Name)\"*\
*    }*\
*    \# There may not be a matching computergroup*\
*    if(\$Groups)*\
*    {*\
*        foreach(\$Group in \$Groups)*\
*        {*\
*            \$ComputerGroupMatch += \$Rules \| ? {\$Group -ilike
\$\_.Group} \| Sort-Object {\[int\] \$\_.Index} \| select -First 1 \|
select Index, SCSM\_SG*\
*        }*\
*    }*\
*\
    \# DEBUG*\
*    if(\$ComputerGroupMatch -and \$DEBUG\_MODE)*\
*    {*\
*        Write-Host (\"Computer group match for \'\" + \$Alert.Name +
\"\': \" + \$ComputerGroupMatch)*\
*    }*\
*\
    \# \* GET THE FIRST MATCHING RULE \* \#*\
*\
    \# add all the matching rules, sort them by index and select the
first rule*\
*    \$SupportGroup = (\[array\]\$TagMatch + \[array\]\$RuleIdMatch +
\[array\]\$ManagementPackNameMatch + \[array\]\$ComputerGroupMatch) \|
Sort-Object Index \| select -First 1 \|  select -ExpandProperty
\"SCSM\_SG\"*\
*   *\
*    \#write-host (\[array\]\$TagMatch + \[array\]\$RuleIdMatch +
\[array\]\$ManagementPackNameMatch + \[array\]\$ComputerGroupMatch)*\
*\
    Return \$SupportGroup*\
*}*\
*\
Function Get-AlertMapping*\
*{*\
*    Param(\$Alert)*\
*\
    \#Write-Host \"Getting all monitoring objects for
\`\"\$(\$Alert.Name)\`\"\"*\
*\
    \# Get monitoring object associated with alert*\
*    \$MonObj = Get-SCOMMonitoringObject -Id \$Alert.MonitoringObjectId
-ComputerName \$SCOMComputerName*\
*    \# we only care about monitoring objects that will potentially
match \"CB groups\"*\
*    \$MonitoringObjects = Get-ParentMonitoringObject \$MonObj \| select
-ExpandProperty DisplayName \| Sort-Object -Unique \| ? {\$\_ -ilike
\"CB -\*\"}*\
*\
    \# Find matching groups*\
*    \#Write-Host \"\`\"\$(\$Alert.Name)\`\" monitoring objects\"*\
*    \$MatchingGroups = @()*\
*    foreach(\$MyGroup in \$MyGroups)*\
*    {*\
*        if(\$MyGroup -in \$MonitoringObjects)*\
*        {*\
*            \$MatchingGroups += \$MyGroup*\
*        }*\
*    }*\
*\
    return (Get-SupportGroup \$Alert \$MatchingGroups)*\
*}*\
*\
\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#*\
*\# FORWARDING FUNCTIONS \#*\
*\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#*\
*\
Function Update-SCOMAlert*\
*{*\
*    Param(\$Alert, \$CustomFieldText, \$ResState)*\
*\
    try*\
*    {*\
*        try*\
*        {*\
*            \$SupportGroup = Get-AlertMapping \$Alert*\
*        }*\
*        catch \[System.Exception\]*\
*        {*\
*            Write-SCOMEventLog \"Unable to map alert to support group
for alert: \$(\$Alert.Name)\`nException message:
\$(\$\_.Exception.Message)\" 704 \"Error\"*\
*            \# we will route it to RTI server*\
*            \$SupportGroup = \"RTI Server\"*\
*        }*\
*\
        \$Alert.Refresh()*\
*        \$Alert.customfield2 = \$CustomFieldText*\
*        \$Alert.customfield3 = \$SupportGroup*\
*        \$Alert.resolutionstate = \$ResState*\
*\
        \# we will not commit changes to alert in debug mode*\
*        if(-not \$DEBUG\_MODE)*\
*        {*\
*            \$Alert.Update(\"Alert processed and ready for Service
Manager\")*\
*        }*\
*        else*\
*        {*\
*            \# Write-Host \"\*DEBUG\_MODE: Updating alert
\$(\$Alert.Name), criticality is set to \$(\$Alert.customfield2),
support group: \$(\$Alert.customfield3)\"*\
*        }*\
*    }*\
*    catch \[System.Exception\]*\
*    {*\
*        Write-SCOMEventLog \"Unable to update alert:
\$(\$Alert.Name)\`nException message: \$(\$\_.Exception.Message)\" 702
\"Error\"*\
*        \$Alert = \$Null*\
*    }*\
*    finally*\
*    {*\
*        \#*\
*    }  *\
*\
    \# Alert variable set to null if unable to update*\
*    if(\$Alert -ne \$Null)*\
*    {*\
*        \$EventDescription = \"Alert processed and ready for Service
Manager.  Alert: \" + \$Alert.Name + \", \" + \"AlertID: \" + \$Alert.ID
+ \". Priority : \" + \$CustomFieldText + \". Support group: \" +
\$SupportGroup*\
*        Write-SCOMEventLog \$EventDescription 606 \"Information\"*\
*    }*\
*}*\
*\
Function Forward-SCOMAlert*\
*{*\
*    Param(\$GroupDisplayName,\$CustomFieldText,\$ResState)*\
*\
    \$Alerts = \$null*\
*    \$Alert = \$null*\
*\
    try*\
*    {*\
*        \$SCOMGroup = Get-SCOMGroup -DisplayName \$GroupDisplayName*\
*        if (\$SCOMGroup)*\
*        {*\
*\
            Write-SCOMEventLog \"Enumerating related monitoring objects
from \`\"\$GroupDisplayName\`\"\" 600 \"Information\"*\
*           *\
*            \$ClassInstances =
\$SCOMGroup.GetRelatedMonitoringObjects(\'Recursive\')*\
*            \$Alerts = Get-SCOMAlert -ComputerName \$SCOMComputerName
-Instance \$ClassInstances -ResolutionState (0) -Severity 2*\
*\
            Write-SCOMEventLog \"Forwarding \$(\$Alerts.Count) alerts in
\`\"\$GroupDisplayName\`\"\" 601 \"Information\"*\
*            Foreach (\$Alert in \$Alerts)*\
*            {*\
*                Update-SCOMAlert \$Alert \$CustomFieldText \$ResState*\
*            }*\
*        }*\
*        Else*\
*        {*\
*            Write-SCOMEventLog \"No matching Group was found
\$GroupDisplayName\`nException message: \$(\$\_.Exception.Message)\" 700
\"Error\"*\
*        }*\
*    }*\
*    catch \[System.Exception\]*\
*    {*\
*        Write-SCOMEventLog \"Alert forwarding for group
\$GroupDisplayName failed\`nException message:
\$(\$\_.Exception.Message)\" 703 \"Error\"*\
*    }*\
*    finally*\
*    {*\
*       *\
*    }*\
*}*\
*\
\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#*\
*\# Connect to SCOM Management Server\#*\
*\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#*\
*try*\
*{*\
*    new-SCOMmanagementGroupConnection -ComputerName
\$SCOMComputerName*\
*\
    Write-SCOMEventLog \"Connected to SCOM management server:
\$SCOMComputerName\" 607 \"Information\"*\
*}*\
*catch \[System.Exception\]*\
*{*\
*    Write-SCOMEventLog \"Unable to connect to \$SCOMComputerName,
terminating script\...\`nException message: \$(\$\_.Exception.Message)\"
701 \"Error\"*\
*    Exit*\
*}*\
*finally*\
*{*\
*    \#*\
*}*\
*\
\#\#\#\#\#\#\#\#\#\#\#\#*\
*\# TEH LOOP \#*\
*\#\#\#\#\#\#\#\#\#\#\#\#*\
*\
\$Starttime = Get-Date*\
*Do*\
*{*\
*    \$LoopStart = (Get-Date)*\
*    \# sleep for \$SLEEPTIME seconds if no new alerts (no adjusting for
time spent in loop)*\
*    \$SleepTimeInSeconds = \$SLEEPTIME*\
*\
    try*\
*    {*\
*        \# load mapping rules*\
*        \$Rules = Import-Csv \$RuleMappingFileLocation*\
*    }*\
*    catch \[System.Exception\]*\
*    {*\
*        Write-SCOMEventLog \"Unable to load mapping rules\`nException
message: \$(\$\_.Exception.Message)\" 705 \"Error\"*\
*        \$Rules = \$null*\
*    }*\
*    finally*\
*    {*\
*    }*\
*\
    \# My groups starts with CB (filter for relevant computer groups
here)*\
*    \$MyGroups = Get-SCOMGroup -DisplayName \"CB - \*\" -ComputerName
\$SCOMComputerName \| select -ExpandProperty DisplayName*\
*\
\
    \# Get number of new alerts with critical severity*\
*    \$AlertCount = (\[array\](Get-SCOMAlert -ComputerName
\$SCOMComputerName -ResolutionState (0) -Severity 2)).Count*\
*\
    \# only forward alerts if there are any new*\
*    if(\$AlertCount -gt 0)*\
*    {*\
*        \# Ping!*\
*        Write-SCOMEventLog \"Is Alive\" 602 \"Information\"*\
*\
        \# forward alerts for different groups at a time - here 3
differently rated servers in terms of criticality*\
*        Forward-SCOMAlert \"High Criticality Servers\" \$HIGH 10*\
*        Forward-SCOMAlert \"Medium Criticality Servers\" \$MEDIUM 10*\
*        Forward-SCOMAlert \"Low Criticality Servers\" \$LOW 10*\
*        Forward-SCOMAlert \"Criticality Undefined\" \$NOT\_DEFINED 10*\
*\
        try*\
*        {*\
*            \# handle remaining alerts*\
*            \$Alerts = \[array\](Get-SCOMAlert -ComputerName
\$SCOMComputerName -ResolutionState (0) -Severity 2)*\
*            if(\$Alerts.Count -gt 0)*\
*            {*\
*                Write-SCOMEventLog \"Forwarding \$(\$Alerts.Count)
remaining alerts (not member of group)\" 603 \"Information\"*\
*                Foreach (\$Alert in \$Alerts)*\
*                {*\
*                    Update-SCOMAlert \$Alert \$NOT\_MEMBER\_OF\_GROUP
10*\
*                }*\
*            }*\
*        }*\
*        catch \[System.Exception\]*\
*        {*\
*            Write-SCOMEventLog \"Alert forwarding for remaining alerts
failed\`nException message: \$(\$\_.Exception.Message)\" 704 \"Error\"*\
*        }*\
*        finally*\
*        {*\
*           *\
*        }*\
*\
        \$LoopEnd = (Get-Date)*\
*\
\
        \# adjust for time spent forwarding alerts*\
*        \$SleepTimeInSeconds = \$SLEEPTIME - (New-TimeSpan -Start
\$LoopStart -End \$LoopEnd).TotalSeconds*\
*        Write-Host \"sleep time \$SleepTimeInSeconds\"*\
*        \# account for a loop that takes longer than the default sleep
time*\
*        if(\$SleepTimeInSeconds -lt 0) { \$SleepTimeInSeconds = 0 }*\
*    }*\
*    Else*\
*    {*\
*        Write-SCOMEventLog \"No new alerts\" 604 \"Information\"*\
*    }*\
*   *\
*    if(\$DEBUG\_MODE)*\
*    {*\
*        Write-Host \"\*DEBUG\_MODE: Exiting loop\"*\
*        break;*\
*    }*\
*\
    Write-SCOMEventLog \"Sleeping for \$SleepTimeInSeconds Seconds\" 605
\"Information\"*\
*    Start-Sleep -s \$SleepTimeInSeconds*\
*}*\
*Until ((Get-Date).AddMinutes(-\$LOOPTIME) -gt \$Starttime)*\
\
Note that the script does not forward alerts as such, it simply updates
the custom fields on the alert and sets the status to a custom alert
status that a SCOM connector should then pick up on and lift the alert
to Service Manager. This is a fairly trivial setup I will not be
covering here.\
\
Now that the alert is updated in a way that allows us to identify which
support group should be assigned to the incident we need to do the
mapping. One way is to create a bunch of templates and use the SCOM
alert connector, or we can just use Orchestrator!\
I will not go through the details on how to do this but describe an
outline on how. Start by creating a \"Monitor Object\" activity that
monitors the Operations Manager-Generated Incident class for new
instances (trigger on new). Either invoke a different runbook (do not
check \"Wait for completion\") or add the activities directly in the
runbook (not at all best practice).\
The runbook should first retrieve the SCOM incident (using Get Object)
and then update the Support Group field with the value from custom field
3 (this is the field where the script puts the support group). Note that
the support group must match one of the support groups listed in the
incident tier queue list.\
\
That\'s it. The alert has gone all the way from SCOM to an incident and
the proper support group is assigned.\
\
Obviously the alert mapping script must be scheduled to run
automatically. It is designed in a way so that one can run it of 2 (or
more) SCOM management servers but at different times. The script is set
to run for 3 hours 55 minutes where each loop is 240 seconds long. Now
in order to provide high availability, schedule the script at both
servers but at different times (with a 120 seconds offset). This will
make the forwarding effectivly run every 2 minutes as long as both
servers are up. As the loops stop after 3 hours 55 minutes it should be
restarted every 4 hours. This is a good alternative to a scheduled task
that runs every 2 minutes (replicating the loop in the script).\
The script requires more or less admin rights on SCOM. I was having
issues on running it with anything less (on top of needing some rights
in the context of running a scheduled task).\
\
*I have had this lying around as draft for weeks now. I have a million
other things to do, so little time to keep polishing before publishing
:D*\
\

<div>

</div>

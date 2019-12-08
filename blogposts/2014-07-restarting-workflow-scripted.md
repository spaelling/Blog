In my [previous
post](http://codebeaver.blogspot.dk/2014/06/managing-activities-and-restarting.html)
I showed a way to restart a stuck Service Request workflow. Now,
detecting SRs that are stuck can be quite tedious using the console. I
wrote a script that can detect a possibly stuck workflow. It is actually
rather simple, looping all relevant SRs and testing if there is no
active activity and one or more pending activities.\
\

    Import-Module SMLets

    # Activity statuses
    $ContainsActivity = Get-SCSMRelationshipClass System.WorkItemContainsActivity
    $InProgressStatus = Get-SCSMEnumeration ActivityStatusEnum.Active
    $PendingStatus = Get-SCSMEnumeration ActivityStatusEnum.Ready
    # SR in progress statuses
    $SRStatusInProgressId = (Get-SCSMEnumeration ServiceRequestStatusEnum.InProgress$).Id
    $SRStatusInProgressPendingId = (Get-SCSMEnumeration ServiceRequestStatusEnum.InProgress.PendingUserResponse).Id
    $SRStatusInProgressUpdatedId = (Get-SCSMEnumeration ServiceRequestStatusEnum.InProgress.UpdatedByUser).Id

    $Now = Get-Date
    $Then = $Now.AddHours(-2)
    # Get SRs with active status that has not been modified since X hours ago
    $sCriteria = "(Status = '$SRStatusInProgressId' or Status = '$SRStatusInProgressPendingId' or Status = '$SRStatusInProgressUpdatedId') and LastModified < '$Then'"
    $SRClass = Get-SCSMClass system.workitem.servicerequest$

    $Criteria = New-Object "Microsoft.EnterpriseManagement.Common.EnterpriseManagementObjectCriteria" $sCriteria, $SRClass
    # Get all SRs matching the critera
    $SRs = Get-SCSMObject -Criteria $Criteria

    foreach($SR in $SRs)
    {
        $HasActivityInProgress = $false
        $HasPendingActivity = $false
        foreach($Activity in Get-SCSMRelatedObject -SMObject $SR -Relationship $ContainsActivity)
        {
            if($Activity.Status -eq $InProgressStatus)
            {
                $HasActivityInProgress = $true            
            }

            elseif($Activity.Status -eq $PendingStatus)
            {
                $HasPendingActivity = $true
            }
        }

        # If true then the SR is possibly stuck with a pending activity
        if(-not $HasActivityInProgress -and $HasPendingActivity)
        {
            Write-Host $($SR.DisplayName)
        }
    }

Next up is trying to get the workflow started again. One approach is to
put the SR on hold, wait abit (10-20 seconds), activate the SR, and
optionally restore the original SR status (typically some custom status
like \"pending user response\").\
\

    Import-Module SMLets

    $SRID = 'SRxxxx';
    $SR = Get-SCSMObject -Class (Get-SCSMClass system.workitem.servicerequest$) -Filter "DisplayName -like '$SRID*'"
    $PrevStatus = $SR.Status
    $StatusInProgress = Get-SCSMEnumeration ServiceRequestStatusEnum.InProgress$

    # set on hold
    $SR | Set-SCSMObject -PropertyHashtable @{Status = (Get-SCSMEnumeration ServiceRequestStatusEnum.OnHold)}

    # wait for activites to go on hold
    Start-Sleep -s 20

    # resume SR
    $SR | Set-SCSMObject -PropertyHashtable @{Status = $StatusInProgress}

    if($PrevStatus -ne $StatusInProgress)
    {
        # wait for activites to "reset"
        Start-Sleep -s 20
        #restore previous status
        Write-Host "Setting status to: $($PrevStatus.DisplayName)"
        $SR | Set-SCSMObject -PropertyHashtable @{Status = $PrevStatus}
    }

\
Leave in a comment below how many stuck workflows you found ;)

<div>

</div>

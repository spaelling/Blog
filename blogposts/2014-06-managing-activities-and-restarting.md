I recently discovered a bug in the workflow engine by unintended use of
an activity workflow. You can read more on Technet: [Help reproducing a
bug - Activity status stuck in pending mode, Service Request still \"in
progress\"](http://social.technet.microsoft.com/Forums/lync/en-US/e9733aec-18e0-4d3f-8388-aaec4201f04b/help-reproducing-a-bug-activity-status-stuck-in-pending-mode-service-request-still-in-progress?forum=systemcenterservicemanager)

There is however a simple way of kickstarting a Service Request or other
work item with an activity flow - behold the \"Put on Hold\" task (pun
intended).
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [![](//1.bp.blogspot.com/-rxhhM8yP9Zs/U6wiNGeqxGI/AAAAAAAAC7o/WyBY9ZN1_7Q/s1600/SR_stuck01.PNG){width="640" height="96"}](//1.bp.blogspot.com/-rxhhM8yP9Zs/U6wiNGeqxGI/AAAAAAAAC7o/WyBY9ZN1_7Q/s1600/SR_stuck01.PNG)
  This SR will be stuck with a MA in pending mode forever - or until we do something to fix it!
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Now let\'s fix this bugger. Click the \"Put on Hold\" task to the right
and click Ok. Wait abit and the activity flow should look like this.
::: {.separator}
[![](//1.bp.blogspot.com/-NBLGuEcVAfQ/U6wiy0N4Q2I/AAAAAAAAC7w/moPShd105nA/s1600/SR_stuck02.PNG){width="640"
height="89"}](//1.bp.blogspot.com/-NBLGuEcVAfQ/U6wiy0N4Q2I/AAAAAAAAC7w/moPShd105nA/s1600/SR_stuck02.PNG)
:::
Click the \"Resume\" task and click Ok. The workflow engine will
recalculate the flow and will put the activity that was stuck in
progress.
::: {.separator}
[![](//1.bp.blogspot.com/-GweJp58Ye6E/U6wjZrNVjNI/AAAAAAAAC78/lxS6kvSmt80/s1600/SR_stuck03.PNG){width="640"
height="99"}](//1.bp.blogspot.com/-GweJp58Ye6E/U6wjZrNVjNI/AAAAAAAAC78/lxS6kvSmt80/s1600/SR_stuck03.PNG)
:::
This can fix a large number of workflows gone haywire. Tried adding
activities to a Parallel Activity that is already in progress? Forget
about it! They will never get out of pending mode. Atleast not before
you put the request on hold and resumes it.
You can also edit the flow (within reason) in ways you cannot do while
it is running. Suppose you have a sequential flow where you need to put
in an activity before another activity alread in progress. Just put it
on hold, add the activity and place it where needed and resume. The
completed activities will be unchanged, but the first \"not-completed\"
in line will be in progress and the rest following it will be pending.
Activities are also subject to being deleted (if skip is not a valid
option - skip is available for admins only. Rob Ford has a
[workaround](http://gallery.technet.microsoft.com/SCSM-2012-Skip-Activity-5a3a763d)
for that though) - you cannot delete already completed activities - but
really you can if you want to - read on\...
Make sure the request is \"In progress\" - use \"Return to activity\" on
the completed activity that you wish to delete. Note that all completed
activities following this will also be \"un-completed\". Click Ok to
commit the change and reopen when the activity is \"In Progress\". Put
the request on hold. The former completed activity is now subject to
deletion. You really wanted to get rid of that activity did you?
If you \"return to activity\" in a request that is on hold it will
resume again.
```
```

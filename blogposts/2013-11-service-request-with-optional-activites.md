Imagine you have a Service Offering on the Self Service Portal where,
depending on the users answers, an activity must be performed or not.
It could be that the users requests a new workstation, and they can
choose to have it delivered to their office and setup, or they can pick
it up themselves. In this case the first activity could be to prepare
the workstation, and the second, depending on the users wish, to deliver
the workstation to their office. Ie. if the user picks up the
workstation themselves we want to skip the second activity.

If you have an extension to your Manual Activity as below we can monitor
specific fields in Orchestrator and act accordingly. If you have nothing
like this in your Service Manager configuration see the ressources
section in the bottom.
::: {.separator}
[![](//4.bp.blogspot.com/-gFfxwPy79-o/Unkh2kwnu_I/AAAAAAAACvk/jB7wH-rufOc/s400/1.png){width="400"
height="172"}](//4.bp.blogspot.com/-gFfxwPy79-o/Unkh2kwnu_I/AAAAAAAACvk/jB7wH-rufOc/s1600/1.png)
:::
::: {.separator}
:::
Create a new runbook and add a Monitor Object from the SCSM2012 IP and
configure it as below.
::: {.separator}
[![](//1.bp.blogspot.com/-E8POeLaldbA/UnkjtS8CjgI/AAAAAAAACvs/6Yf-ThxI7ZI/s400/2.png){width="400"
height="242"}](//1.bp.blogspot.com/-E8POeLaldbA/UnkjtS8CjgI/AAAAAAAACvs/6Yf-ThxI7ZI/s1600/2.png)
:::
Link it to an Invoke Runbook activity. This runbook will do the real
work, ie. set the status of the Manual Activity to \"skipped\" as
follows:
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [![](//3.bp.blogspot.com/-7kt80LNNXTY/Unkkskh7YdI/AAAAAAAACv4/_cc2uxYSiKU/s400/3.png){width="400" height="220"}](//3.bp.blogspot.com/-7kt80LNNXTY/Unkkskh7YdI/AAAAAAAACv4/_cc2uxYSiKU/s1600/3.png)
  Monitoring runbook
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [![](//1.bp.blogspot.com/-v8gkJ0MCNnk/Unkksl5bqwI/AAAAAAAACwU/7ZfvkBaTC00/s400/4.png){width="400" height="215"}](//1.bp.blogspot.com/-v8gkJ0MCNnk/Unkksl5bqwI/AAAAAAAACwU/7ZfvkBaTC00/s1600/4.png)
  Configuration of the Invoke Runbook activity
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [![](//1.bp.blogspot.com/-Obw95N9BIDc/UnkkskRE1hI/AAAAAAAACwI/pEMap4oQjvk/s400/5.png){width="400" height="216"}](//1.bp.blogspot.com/-Obw95N9BIDc/UnkkskRE1hI/AAAAAAAACwI/pEMap4oQjvk/s1600/5.png)
  The invoked runbook
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [![](//3.bp.blogspot.com/-y3fkwNzmzcs/UnkljirHH0I/AAAAAAAACwc/ekvQFgbJ2z0/s400/6.png){width="400" height="238"}](//3.bp.blogspot.com/-y3fkwNzmzcs/UnkljirHH0I/AAAAAAAACwc/ekvQFgbJ2z0/s1600/6.png)
  Configured the Update Object activity as this
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
All in all fairly simple. Start the monitoring runbook and create a
Service Request Template. Add a Manual Activity and go to the Extensions
tab and enter *\_\_skip\_\_* in the UserInput4 field.
::: {.separator}
[![](//3.bp.blogspot.com/-0tG-xUxuF9A/UnknC3Z6ZsI/AAAAAAAACwk/0Btnkx4jn2A/s400/7.png){width="400"
height="156"}](//3.bp.blogspot.com/-0tG-xUxuF9A/UnknC3Z6ZsI/AAAAAAAACwk/0Btnkx4jn2A/s1600/7.png)
:::
Now create a Request Offering based on this template. A single user
prompt should do the trick:
::: {.separator}
[![](//2.bp.blogspot.com/-XbWOZDyFzBc/Unko76XR3NI/AAAAAAAACxA/je8rSPGCEZY/s320/8.png){width="320"
height="154"}](//2.bp.blogspot.com/-XbWOZDyFzBc/Unko76XR3NI/AAAAAAAACxA/je8rSPGCEZY/s1600/8.png)
:::
::: {.separator}
:::
Map the answer to the activity.
::: {.separator}
[![](//1.bp.blogspot.com/-ZFcictfHCak/UnkoIvxWxoI/AAAAAAAACw0/KnRNN71drWE/s400/9.png){width="400"
height="260"}](//1.bp.blogspot.com/-ZFcictfHCak/UnkoIvxWxoI/AAAAAAAACw0/KnRNN71drWE/s1600/9.png)
:::
Go to your Self Service Portal and submit a request on your newly
published Request Offering. Or if you, like me, haven\'t set up a portal
yet, create a SR using the console.
Wait abit and for the Orchestrator magic to happen. The history tab of
the Manual Activity should look something like this. Also notice that
the Service Request was completed automatically - there were no
activites left to be done.
::: {.separator}
[![](//1.bp.blogspot.com/-K68J6LTyTWk/UnkqJ5vsq3I/AAAAAAAACxM/4v8T4lJr_3Y/s400/10.png){width="400"
height="260"}](//1.bp.blogspot.com/-K68J6LTyTWk/UnkqJ5vsq3I/AAAAAAAACxM/4v8T4lJr_3Y/s1600/10.png)
:::
If you find that there are tons of workflows with optional activities,
you may consider adding a field specifically for this purpose and
monitor that instead.
### Ressources:
-   [How to Extend a Class in the Authoring
    Tool](http://technet.microsoft.com/en-us/library/hh495653.aspx)

Converted from html using https://github.com/spaelling/Blog/blob/master/convert.ps1 


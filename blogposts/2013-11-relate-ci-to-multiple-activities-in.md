**Scenario**: You have a Request Offering on the portal in which the
user will select a CI. The CI is attached to the Service Request as a
Related Item.

::: {.separator}
[![](//1.bp.blogspot.com/-d0Oexb68cn4/Unk60GoA5RI/AAAAAAAACxc/3BljfSdyl8U/s400/1.png){width="400"
height="117"}](//1.bp.blogspot.com/-d0Oexb68cn4/Unk60GoA5RI/AAAAAAAACxc/3BljfSdyl8U/s1600/1.png)
:::

You also need that CI to be available to some of the activities. The
scenario is close to mapping prompt outputs from a Request Offering to
fields in multiple Work Items. Maybe the user entered and ID number of
sorts which is relevant information for more than one activity in a
Service Request.

First create a Service Request Template and add a few activities
similarly to what has been done below

::: {.separator}
[![](//2.bp.blogspot.com/-ZFLo07k04GU/Unk8nzlsmEI/AAAAAAAACxo/NzphfjI_lsI/s400/2.png){width="400"
height="211"}](//2.bp.blogspot.com/-ZFLo07k04GU/Unk8nzlsmEI/AAAAAAAACxo/NzphfjI_lsI/s1600/2.png)
:::

Add a Manual Activity at the end of the flow with the title \"Dummy\".

We need 4 runbooks. one that monitors new Service Requests, one that
will get all the Manual Activities in that Service Request, one that
creates a relation in each Manual Activity to the CI. And the last
runbook ties them all together.

The monitoring runbook is just as one would expect.

::: {.separator}
:::

::: {.separator}
:::

::: {.separator}
:::

::: {.separator}
[![](//3.bp.blogspot.com/-pf7ymYdK-lI/Un-C-klUZUI/AAAAAAAAC04/X7rFaloTEYI/s1600/1.png)](//3.bp.blogspot.com/-pf7ymYdK-lI/Un-C-klUZUI/AAAAAAAAC04/X7rFaloTEYI/s1600/1.png)
:::

::: {.separator}
[![](//2.bp.blogspot.com/-6h0Tk25fJmM/Un-C-mx9TOI/AAAAAAAAC1E/I4ITp5gBPeI/s400/2.png){width="400"
height="111"}](//2.bp.blogspot.com/-6h0Tk25fJmM/Un-C-mx9TOI/AAAAAAAAC1E/I4ITp5gBPeI/s1600/2.png)
:::



  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [![](//4.bp.blogspot.com/-Z1WFcgy0Uug/Un-DaU4dhfI/AAAAAAAAC1I/lEof-uErJCU/s640/3.png){width="640" height="108"}](//4.bp.blogspot.com/-Z1WFcgy0Uug/Un-DaU4dhfI/AAAAAAAAC1I/lEof-uErJCU/s1600/3.png)
  Relate CI to Multiple Activities in a Service Request
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

In this example I get all related \"Windows Computers\" and feed them to
\"Relate CI to MA\".

  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [![](//1.bp.blogspot.com/-ACL3VbqdL3M/Un-ESsbOghI/AAAAAAAAC1U/Ru6wNFgB7cU/s400/4.png){width="400" height="138"}](//1.bp.blogspot.com/-ACL3VbqdL3M/Un-ESsbOghI/AAAAAAAAC1U/Ru6wNFgB7cU/s1600/4.png)
  \"Relate CI to MA\" - This runbook will be called as many times as there are Manual Activities in the Service Request.
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

The magic happens in this runbook:

  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [![](//1.bp.blogspot.com/-lFn7bHj-Eig/Unq9QWTi6dI/AAAAAAAACyw/PBai7amdAOI/s400/4.png){width="400" height="68"}](//1.bp.blogspot.com/-lFn7bHj-Eig/Unq9QWTi6dI/AAAAAAAACyw/PBai7amdAOI/s1600/4.png)
  Get Manual Activity IDs in SR
  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

::: {.separator}
:::

  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [![](//4.bp.blogspot.com/-_RDA1PLg_-I/Unq8BdBZNeI/AAAAAAAACyU/rpXmmb__fCA/s400/5.png){width="400" height="130"}](//4.bp.blogspot.com/-_RDA1PLg_-I/Unq8BdBZNeI/AAAAAAAACyU/rpXmmb__fCA/s1600/5.png)
  Get Related MAs
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [![](//3.bp.blogspot.com/-EZL8PiaDXlI/Unq8NeUDaTI/AAAAAAAACyc/1JJ_5YWLOi0/s400/6.png){width="400" height="242"}](//3.bp.blogspot.com/-EZL8PiaDXlI/Unq8NeUDaTI/AAAAAAAACyc/1JJ_5YWLOi0/s1600/6.png)
  Get \'Dummy\' MA
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

::: {.separator}
:::



  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [![](//2.bp.blogspot.com/-0ixQf6k_brc/Unq8mB-otdI/AAAAAAAACyk/2wc_h4rKhX8/s400/7.png){width="400" height="102"}](//2.bp.blogspot.com/-0ixQf6k_brc/Unq8mB-otdI/AAAAAAAACyk/2wc_h4rKhX8/s1600/7.png)
  Delete MA Relation - Removes the Dummy Activity from the Service Request
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

The Script looks like this:

*Set-ExecutionPolicy Unrestricted -Scope Process -Force*
*
Import-Module -Name \'SMLets\'*
*
\$S = \"MA{ID from \"Get SR\"}\".Replace(\"SR\",\"\");*
*\$E = \"{ID from \"Get \'Dummy\' MA\"}\";*
*
\$MAIDs = Get-SCSMObject -Class (Get-SCSMClass -Name
\"System.WorkItem.Activity.ManualActivity\$\") -Filter \"DisplayName -gt
\`\"\$S\`\" -and DisplayName -lt \`\"\$E\`\"\" \| Select -ExpandProperty
Id;*

This is what we needed the \'dummy\' for. Altenately one could cycle
through all the Manual Activites and pick the one with the highest ID.
The Run .NET Script activity must publish the \$MAIDs variable.

  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [![](//1.bp.blogspot.com/-Xjjfp7CzXTA/UnrBF5OhrQI/AAAAAAAACy8/V4ljHfw_3rE/s400/8.png){width="400" height="47"}](//1.bp.blogspot.com/-Xjjfp7CzXTA/UnrBF5OhrQI/AAAAAAAACy8/V4ljHfw_3rE/s1600/8.png)
  Return Data
  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

And finally we relate the CI to the MA - Under properties for this
runbook in the \"Concurrency\" tab, enter a number greater than 1 for
\"Maximum number of simultaneous jobs\". As many as you expect there
will be of Manual Activities in a Service Request without overloading
your runbook server. 5-10 is a good number (depending on your hardware
setup).

::: {.separator}
[![](//4.bp.blogspot.com/-pcKkrcHgs3Q/Un-E8u4LZJI/AAAAAAAAC1c/KUm3M9fA22A/s400/5.png){width="400"
height="132"}](//4.bp.blogspot.com/-pcKkrcHgs3Q/Un-E8u4LZJI/AAAAAAAAC1c/KUm3M9fA22A/s1600/5.png)
:::

::: {.separator}
[![](//1.bp.blogspot.com/-udYe3y5VnA4/Un-FF__V8mI/AAAAAAAAC1k/dtBXSDKUfl8/s400/6.png){width="400"
height="147"}](//1.bp.blogspot.com/-udYe3y5VnA4/Un-FF__V8mI/AAAAAAAAC1k/dtBXSDKUfl8/s1600/6.png)
:::

**Testing**: Start the monitoring runbook and create an instance of the
template from the beginning of this tutorial and add a \"Windows
Computer\" in the \"Related Items\" tab of the Service Request - or
whatever class of CI your runbook supports.

**Extending**: As you may only want to relate CIs in specific Service
Requests, or different types of CIs for each Service Request you will
have to add some logic to the \"Relate CI to Multiple Activities in a
Service Request\"-runbook.

**Alternatives**: Instead of using a monitor you could add a
runbook-activity as the first activity in the Service Request.

```

```

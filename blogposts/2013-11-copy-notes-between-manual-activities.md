Inspired by Anders Bengtssons [blogpost](http://contoso.se/blog/?p=3648)
I have come up with a different approach, similar to what I showed
in [Service Request with Optional
Activites](http://codebeaver.blogspot.dk/2013/11/service-request-with-optional-activites.html).

Again I exploit the setup where Manual Activities are extended with a
number of properties. First create a Service Request template and add
two activities. In the Extension tab for the first one
enter *\_\_copy\_note\_on\_completion\_\_* in UserInput5 (or whatever
you called yours).


::: {.separator}
[![](//1.bp.blogspot.com/-PdWh1iyKURc/UnrGbIONzHI/AAAAAAAACzk/8GdgXqkUNcg/s400/11.png){width="400"
height="152"}](//1.bp.blogspot.com/-PdWh1iyKURc/UnrGbIONzHI/AAAAAAAACzk/8GdgXqkUNcg/s1600/11.png)
:::

Now create a runbook that monitors Manual Activities matching this
configuration.

::: {.separator}
[![](//3.bp.blogspot.com/-WJ-bZo_1-aM/UnwF3m8lZmI/AAAAAAAACz0/PNc6VFu5wNs/s400/1.png){width="400"
height="158"}](//3.bp.blogspot.com/-WJ-bZo_1-aM/UnwF3m8lZmI/AAAAAAAACz0/PNc6VFu5wNs/s1600/1.png)
:::

The monitor triggers on Manual Activities that are updated to status
Completed, and where UserInput5
equals *\_\_copy\_note\_on\_completion\_\_*. The runbook looks in its
whole as below

::: {.separator}
[![](//4.bp.blogspot.com/-YMAQQTXCV2k/UnwGna6stGI/AAAAAAAACz8/cerQ27cd76k/s320/2.png){width="320"
height="165"}](//4.bp.blogspot.com/-YMAQQTXCV2k/UnwGna6stGI/AAAAAAAACz8/cerQ27cd76k/s1600/2.png)
:::

The runbook invoked by the monitor being triggered looks like this

::: {.separator}
[![](//2.bp.blogspot.com/-FiYUrMtb0Dc/UnwG-ppeGxI/AAAAAAAAC0E/A9bVLyq2Uho/s400/3.png){width="400"
height="62"}](//2.bp.blogspot.com/-FiYUrMtb0Dc/UnwG-ppeGxI/AAAAAAAAC0E/A9bVLyq2Uho/s1600/3.png)
:::

::: {.separator}
The first two activities are just as their title indicates.
:::

  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [![](//1.bp.blogspot.com/-0dwblzQByFE/Unz6fcJm9tI/AAAAAAAAC0U/Gsjf28XwVX4/s400/12.png){width="400" height="243"}](//1.bp.blogspot.com/-0dwblzQByFE/Unz6fcJm9tI/AAAAAAAAC0U/Gsjf28XwVX4/s1600/12.png)
  Get Next MA
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

::: {.separator}
The filter value is: *MA\[Sum(Right({ID from \"Get MA\"},sum(len({ID
from \"Get MA\"}),-2)),1)\]*
:::

::: {.separator}
In short it adds 1 to the Manual Activity ID - for further details
consult the Runbook Designer help on the topic *Data Manipulation.*
:::

  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [![](//4.bp.blogspot.com/-abXzQWm3Vzg/Unz7DWytg2I/AAAAAAAAC0c/c5EJZoVNcaw/s400/13.png){width="400" height="213"}](//4.bp.blogspot.com/-abXzQWm3Vzg/Unz7DWytg2I/AAAAAAAAC0c/c5EJZoVNcaw/s1600/13.png)
  You can configure this anyway you like. Point being that we copy the \"Notes\" property from one activity to the next.
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

::: {.separator}
Now we just need to start the monitor, create a Service Request using
the template described in the beginning of this tutorial. Complete the
first activity and enter something meaningful like \"Red herring tastes
like salty beef\". After a short wait the Orchestrator magic will
provide you with an updated description in the following activity
:::

::: {.separator}
[![](//1.bp.blogspot.com/-uiygEvPALzw/Unz8tzSaTZI/AAAAAAAAC0o/O1Zb0qTOYmw/s400/14.png){width="400"
height="106"} ](//1.bp.blogspot.com/-uiygEvPALzw/Unz8tzSaTZI/AAAAAAAAC0o/O1Zb0qTOYmw/s1600/14.png)
:::

::: {.separator}
**NOTE**: This assumes that ID\'s are ascending sequentially. If
activity order is changed in the template (using the console) the ID is
not changed to follow the new ordering. This is because the sequenceID
is changed to reflect the new order, while the XML order is not (the
activity IDs are definied by the listed order in XML). The MP will need
to be exported, the XML changed to reflect the new ordering and
re-imported.
:::

::: {.separator}
Also sometimes the order in the XML is changed while sequenceID is not,
meaning the ID ordering is messed up. Same fix (export, edit, import).
:::

```

```

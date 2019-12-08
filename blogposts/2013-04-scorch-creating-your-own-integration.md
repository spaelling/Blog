In [\[SCOrch\] Installing Orchestrator Integration
Toolkit](http://codebeaver.blogspot.dk/2013/04/scorch-installing-orchestrator.html) I
showed how to get around installing the necessary tools for creating
your own Integration packs.
I will now show how to create an *activity* that will raise an
error. [\[SCOrch\] Error handling runbooks in SC Orchestrator - Part
1](http://codebeaver.blogspot.dk/2013/04/scorch-error-handling-runbooks-in-sc.html) showed
that there is a need for doing exactly that as I will examplify in part
2 (comming soon).

First we start the *Orchestrator Command-Line Activity Wizard*. Click
*Next* and enter a name for the .NET assembly the wizard will eventually
create. The name is used as a [namespace
identifier](http://en.wikipedia.org/wiki/Namespace) for the assembly.
The assembly file will by default be saved to the* Documents Library*.
::: {.separator}
:::
::: {.separator}
[![](//2.bp.blogspot.com/-49IYqIPeyqk/UXHMycqVaiI/AAAAAAAACMM/w_ebXjOhg1U/s400/1.png){width="400"
height="311"}](//2.bp.blogspot.com/-49IYqIPeyqk/UXHMycqVaiI/AAAAAAAACMM/w_ebXjOhg1U/s1600/1.png)
:::
Click *Next*, then *Add*. Name the *Command* [Raise
Error]{style="FONT-FAMILY: Arial, Helvetica, sans-serif"} and the
*Mode* [Run Windows
PowerShell]{style="FONT-FAMILY: Arial, Helvetica, sans-serif"}[.
Optionally provide a description.]{style="FONT-FAMILY: inherit"}
[
]{style="FONT-FAMILY: inherit"}
::: {.separator}
[![](//4.bp.blogspot.com/-b1ICTmk1L7k/UXHOmnlmKTI/AAAAAAAACMY/uGbdDK_Hvto/s400/2.png){width="400"
height="315"}](//4.bp.blogspot.com/-b1ICTmk1L7k/UXHOmnlmKTI/AAAAAAAACMY/uGbdDK_Hvto/s1600/2.png)
:::
[In the *Arguments* tab click *Add* and enter
]{style="FONT-FAMILY: inherit"}[Message]{style="FONT-FAMILY: Arial, Helvetica, sans-serif"}[.
Click *OK*.]{style="FONT-FAMILY: inherit"}
[
]{style="FONT-FAMILY: inherit"}
::: {.separator}
[![](//2.bp.blogspot.com/-tYiCCnc0TcY/UXHOmlf4YsI/AAAAAAAACMo/hhKW0hYwNvA/s400/3.png){width="400"
height="237"}](//2.bp.blogspot.com/-tYiCCnc0TcY/UXHOmlf4YsI/AAAAAAAACMo/hhKW0hYwNvA/s1600/3.png)
:::
[Again under the *Arguments* tab click *Insert* and select
]{style="FONT-FAMILY: inherit"}[\$(Message)]{style="FONT-FAMILY: Arial, Helvetica, sans-serif"}[.
Edit the Command Line to
]{style="FONT-FAMILY: inherit"}[Throw \$(Message)]{style="FONT-FAMILY: Arial, Helvetica, sans-serif"}.
Click OK.
::: {.separator}
[![](//1.bp.blogspot.com/-m-HY7DY53K8/UXHOmrnrpBI/AAAAAAAACMk/t0MbOtQ5Qik/s400/4.png){width="400"
height="315"}](//1.bp.blogspot.com/-m-HY7DY53K8/UXHOmrnrpBI/AAAAAAAACMk/t0MbOtQ5Qik/s1600/4.png)
:::
We now have a command (activity) that will \"fail\" everytime. We can
even provide a message that will be displayed in the Orchestrator log.
Click next and let it brew. When done click *Build Integration Pack*.
The *Orchestrator Integration Pack Wizard* will start and the assembly
we just created is already added. Click *Next* and enter the details.
Category name is what is displayed in Orchestrator, and Product name is
displayed in the SC 2012 Orchestrator Deployment Manager, but other than
that you can enter pretty much what you like.
::: {.separator}
[![](//1.bp.blogspot.com/-TarZuPiDrm8/UXHQ8i-R-kI/AAAAAAAACMs/dc9fdz16JcY/s400/5.png){width="400"
height="311"}](//1.bp.blogspot.com/-TarZuPiDrm8/UXHQ8i-R-kI/AAAAAAAACMs/dc9fdz16JcY/s1600/5.png)
:::
Click *Next*. If you like you can provide an icon for the Raise Error
activity. Select it and click *edit*, then *modify* and select an icon
of your liking. Click *Next* and then *Next* again. Enter a name for the
Integration Pack (it doesn\'t add .oip itself, so help it out). Click
*Next* and let it brew once again, then *Finish*. The file is saved to
the *Documents Library*.
Next install the IP using the Deployment Manager (I might show how in a
later installment - it\'s really easy!).
**Links**
-   <http://msdn.microsoft.com/en-us/library/hh855854.aspx> - The
    documentation is actually fairly decent. There is a part explaining
    how to test the assembly before putting it in an IP and deploying
    that IP (saves some time!)
```
[tags: Orchestrator, Integration Pack]{style="FONT-SIZE: xx-small"}
```
```
```

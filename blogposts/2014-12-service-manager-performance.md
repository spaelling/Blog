
```
This is intended as a reference compilation of performance optimizations
for Service Manager. I have divided them into multiple parts for quicker
reference.
Everything that follows is from various blogposts, most of them can be
found in my [previous
blogpost](http://codebeaver.blogspot.dk/2014/12/service-manager-2012-performance.html).
All credit goes to the guys and gals who wrote those.
This is work in progress, so keep comming back :D
```
```
```
```
[**SQL**]{style="FONT-SIZE: large"}
```
```
```
```
**[Preparation:]{.underline}**
```
```
-   Make sure the SQL meets the recommended hardware requirements ([Look
up the SM Sizer
tool](http://go.microsoft.com/fwlink/p/?LinkID=232378)). Also in
order of importance *disk IO \> RAM \> CPU*.
-   If possible keep Service Manager, Datawarehouse (and Orchestrator)
on seperate SQL boxes. This makes them easier to scale later on.
```
**[Post install:]{.underline}**
```
```
```
-   Create tempdbs for both service manager and datawarehouse. Rule of
thumb is one per two cpus up to one per cpu. Put them on fast disks
(if possible *seperate* LUNs/disks)
-   Disable autogrow on ServiceManager and tempdbs (size them properly
to begin with). Have SCOM or similar monitor them, and resize
manually if needed.
-   Set Maximum memory for the/each instance so that the OS has 4 gb RAM
available.
-   For Service Manager make sure that SQL broker is set to 1 (read more
[here](http://www.concurrency.com/wp-content/uploads/2013/04/MMS-2013-Service-Manager-Scalability.pptx),
page 14)
-   Make sure autoshrink is disabled (it is by default).
-   Some experience increased performance by setting max degree of
parallelism to between 1 and 4 (read more
[here](http://www.concurrency.com/wp-content/uploads/2013/04/MMS-2013-Service-Manager-Scalability.pptx),
page 15).
```
[**Service Manager**]{style="FONT-SIZE: large"}
```
```
```
```
```
**Preparation:**
```
```
-   Make sure that you will be installing a secondary management server
and have consoles connect to this, and this alone. The primary
management server will be a dedicated workflow server.
Rule of thumb is 12 concurrent console sessions per cpu, but you can
likely handle more.
-   Make sure there is a low latency & high bandwidth connection between
consoles and the (secondary) management server. This can be a
problem with a geographically dispersed organization. If the
connection is an issue consider using remote desktop, citrix or 3rd
party alternatives (Cireson/GridPro) to the console.
```
```
**Post install:**
```
```
-   Apply UR2 - it has a critical console performance fix.
-   Configure the Global Operators Group (read [FAQ: Why Does It Take So
Long to Find Users in the Assigned To and Primary Owner
Fields?](http://blogs.technet.com/b/servicemanager/archive/2012/12/14/faq-why-does-it-take-so-long-to-find-users-in-the-assigned-to-and-primary-owner-fields.aspx))
-   Disable app pool recycling (read [FAQ: Why is the self-service
portal so
slow?](http://blogs.technet.com/b/servicemanager/archive/2011/05/11/faq-why-is-the-self-service-portal-so-slow.aspx))
-   Consider increasing the group calculation interval (read [Service
Manager
Performance](http://technet.microsoft.com/en-us/library/hh519624.aspx))
-   Only create SLOs that are really needed. An alternative to the
builtin service level management is using Orchestrator or SMA.
-   Disable workflow:
Incident\_Adjust\_PriorityAndResolutionTime\_Custom\_Rule.Add if
using SLOs.
-   Disable first assigned workflow if not used (read [SCSM - The item
cannot be updated\.....aka. Click Apply and
die](http://blogs.technet.com/b/thomase/archive/2012/11/15/scsm-the-item-cannot-be-updated-aka-click-apply-and-die.aspx)) -
really frustrating for your analysts to have this enabled.
-   Consider data retention settings. do you really need closed service
requests for more than 90 days? Fewer work items means better
performance.
-   setup workflows to close resolved incidents, completed service
requests, etc. Cireson has an [auto close
app](http://cireson.com/apps/auto-close/) or you can roll your own.
I did [a piece on auto-resolving
incidents](http://codebeaver.blogspot.dk/2013/02/scsm-auto-resolve-inactive-incidents.html),
but you can easily edit the script to close resolved incidents.
-   When creating AD-connectors point only at a specific OU containing
the users you want to import into Service Manager. If you then need
to import from more than one OU then create more AD-connectors. Also
use this ldap query for only importing enabled accounts
(&(ObjectCategory=User)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))
Remember to check the \'Do not write null values for properties not
set in Active Directory\' box.
If you have more than one AD-connector use different runas account
(each based on different AD-users) for each.
Read more on AD-connector optimizations
[here](http://blogs.technet.com/b/thomase/archive/2013/04/08/scsm-active-directory-connector-optimization.aspx).
```
I will try and keep this updated as I learn new tricks. There are tons
more, but I find these to be fairly trivial to apply and still alot to
gain.
```
```
```
```
```
```
```
```
```
```

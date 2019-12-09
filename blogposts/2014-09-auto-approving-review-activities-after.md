I recently needed to auto-approve a review activity if none of the
assigned reviewers responded in a timely manner. As I was pressed for
time I wanted something that I could implement fast and simple (like
this blog-post).

The problem is then: A review activity has not been approved (status =
completed) after x hours. When that time passes it should auto-approve
(ie. set status to completed).
I cannot use a workflow because it is unable to detect this state. I
also cannot use a monitor object activity in Orchestrator to detect this
state. I was left with a scheduled PS-script, but then it occured to me:
Subscription! The subscription is unable to apply a template and thereby
set the status to completed, but I could send the email to Service
Manager with the subject as \[RA1234\] (the ID of the review activity)
and the body: *Automatically approved by Service Manager \[Approved\]*.
The criteria in the subscription is:
*when meets criteria*:
status = in progress
created date is less than or equal to \[now-1d\]
Now I haven\'t actually gotten around testing this, and it may need a
bit of tweaking to get exactly right, but I am pretty confident it will
work. Since the sender is the workflow account which has admin rights it
should be able to approve the RA without being reviewer. I will update
here when I know more.
Read more on approving review activities via.
email [here](http://blogs.technet.com/b/servicemanager/archive/2011/02/08/tricky-way-to-handle-review-activity-approvals-with-the-exchange-connector.aspx).
I have two more blog posts lined up, one on speeding up development
using the SCSM SDK, and one on mapping support groups intelligently (and
automatically) to SCOM generated incidents using a fancy script and an
excel sheet!
I just need some time to polish both posts. Hope to get them out soon.

**Converted from html using [convert.ps1](https://github.com/spaelling/Blog/blob/master/convert.ps1)**


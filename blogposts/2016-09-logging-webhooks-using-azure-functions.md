We recently discussed webhooks internally at
[work](http://www.lumagate.com/) and the question popped on how to
maintain and log the activity. Webhooks normally have a limited timespan
(could be years though), and they should generally be kept a secret even
if they are accompanied by a token that authorizes the caller.

What better way to log the webhook calls than using [OMS Log
Analytics](https://www.microsoft.com/en/server-cloud/solutions/log-analytics.aspx)?
Once the data is logged there you have a plethora of options on what to
do with it. Go ask my colleague
[Stanislav](https://cloudadministrator.wordpress.com/).

I also wanted to try out the fairly new [Azure
Functions](https://azure.microsoft.com/en-us/documentation/articles/functions-overview/),
which acts as a relay to [Log Analytics Data Collector
API](https://azure.microsoft.com/en-us/documentation/articles/log-analytics-data-collector-api/).
The webhook itself comes from an Azure Automation runbook.

I documented the entire solution on Github, and you can find the
repository [here](https://github.com/spaelling/azure-functions-webhook-logger) -
it takes you from A to Z on how to setup the various moving parts in
Azure. I hope you can find some inspiration on how to manage your
webhooks.

```

```

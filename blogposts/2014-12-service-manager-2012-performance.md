Service Manager performance is essential, and almost any SCSM-admin will
be (or already have) tried out some of the tricks in the following.
Before we get started I would like to quote Donald Knuth (First time I
heard about him too):

```



```

```

**\"We should forget about small efficiencies, say about 97% of the
time: premature optimization is the root of all evil\"**

```

```

**
**

```

```

In other words, don\'t just optimize for the sake of it! To quote
another piece of Wikipedia (because I am to lazy to write it myself):

```

```



```

```

**Rewriting sections \"pays off\" in these circumstances because of a
general \"rule of thumb\" known as the 90/10 law, which states that 90%
of the time is spent in 10% of the code, and only 10% of the time in the
remaining 90% of the code. So, putting intellectual effort into
optimizing just a small part of the program can have a huge effect on
the overall speed --- if the correct part(s) can be located.**

```

```

**
**

```

```

Which I believe also applies to Service Manager too.

```

```



```

```

Now let\'s dig into it. I will do a \"lazy summary\" on some of the
links for those who cannot be bothered to read it all ;) And then point
out some nifty optimizations that is worth considering (which may or may
not be valid for your configuration). Or just if I find something cool
or new (to me).

Also I would like to encourage to *comment* on particular tips or tricks
that helped you make Service Manager perform better, or if I left
something out that you feel is worth mentioning.

```

```



```

```

[Service Manager Performance
(Technet)](http://technet.microsoft.com/en-us/library/hh519624.aspx)

```

```

-   Don\'t use the \"advanced type\" for views. Ever!
-   Size your SM DB properly (to avoid it growing on demand in a
    production environment).
-   If possible keep all DB- and log-files on seperate physical disks.
-   Don\'t skimp on console computers. Multiple cores and 4+ GB RAM.

```

The section on \"Group, Queue, and User Role Impact on Performance\" may
apply to you. If you are not using queues for service level management
or to control access to work items, CIs, etc. for users, or if you are
using service level management but it is not a time-critical part of
your process, then this optimization may be for you.

```

```

By default service manager computes what goes into what queue every 30
seconds, and consequently which SLOs should be applied, or who can
access what (defined using groups).  That sounds like hard work, and
quite a waste if we could do it much less often, like every 10 minutes
(as suggested).
*Beware: The value is entered in hexadecimal (base 16, decimal numbers
are in base 10) by default.*

```

```



```

```

[Troubleshooting Workflow Performance and Delays (By Travis
Wright)](http://blogs.technet.com/b/servicemanager/archive/2013/01/14/troubleshooting-workflow-performance-and-delays.aspx)

```

```

-   Download queries from
    [here](https://gallery.technet.microsoft.com/Workflow-Performance-680438ae),
    extract zip, and run the one called \"SubscriptionStatus.sql\"
    against the ServiceManager DB. Look at the top rows and if the
    column \"minutes behind\" is greater than 3 you may have a problem.
    Read the entire article to dig in deeper.

```

I actually had a workflow in my system that was behind by 192 days (and
counting\...). Sorted out to be the same exact workflow being recorded
twice, but only one of them was updated as being run.

Also more on this further down.

```

```



```

```

[Update Rollup 2 for System Center 2012 R2 Service
Manager](http://www.microsoft.com/en-us/download/details.aspx?id=42551)

```

```



```

```

Not really a blogpost, but there is a critical performance update to the
console in UR2. So apply that (no questions asked) if you have
performance issues with the console.

```

```



```

```

[Service Manager - Performance and Scalability best practices (Talk by
Travis
Wright)](http://channel9.msdn.com/Series/SCUE2014/Service-Manager-Performance-and-Scalability-best-practices)

```

```

-   Configuration is key (I think he actually says that somewhere).
-   Simply watch the video. Start at 16:00 if you want to dig right in,
    and watch about 30 minutes (some of it can be skipped where he talks
    about testing at MS bla bla). Remember to take notes, but remember
    the caveat in the beginning of this post - There is alot of possible
    configurations for optimization, but you are likely to get the most
    out of just a few of them.

```

On a personal note: I don\'t get why he is showing that Service Manager
can run on a beast of a backend with many more users, computers, work
items, etc. than Microsoft tested for, and the morale is that
configuration is the critical component (he disables some not-needed
workflows, and reconfigures stuff). Why not then test it out on some
more down-to-earth hardware and then the morale of the story could be
that Service Manager can run on a very large scale on some decent, but
not out-of-this-world hardware, with proper configuration.

```

```

```



```

```

[Configuring Service Manager for Performance and Scale (By Nathan
Lasnoski)](http://www.concurrency.com/infrastructure/configuring-service-manager-for-performance-and-scale/)

```

```



```

```

Just watch it already!

```

```



```

```

[FAQ: A Collection of Tips to Improve System Center 2012 Service Manager
Performance (by Peter
Zerger)](http://www.systemcentercentral.com/faq-a-collection-of-tips-to-improve-service-manager-performance/)

He did a collection of performance hints, so I will include him in this
collection :D

[Service Manager slow perfomance (By Mihai
Sarbulescu)](http://blogs.technet.com/b/mihai/archive/2012/07/13/service-manager-slow-perfomance.aspx)

An elaboration on what Travis talked about troubleshooting workflows and
delays (linked earlier in this post).

```

```



```

```

[Poor Performance on Service Manager 2012? (by Thomas
Mortsell)](http://systemcenterblogs.com/2014/06/10/poor-performance-on-service-manager-2012/)

Some cool tips, especially on the SQL backend. I haven\'t heard about
splitting the SM DB into multiple files (across multiple disks,
controllers, etc.). I would suspect some tables to be alot more busy
than others, and those could possible benefit from being in a seperate
filegroup. Anyone had luck with this?

That was it. Remember to comment below. I may do a post someday with
performance optimizations that might as well be done as part of a
Service Manager installation. Or in most cases some easy to do
post-install optimizations.

[Service Manager Request Query Result Filtering (By Nathan
Lasnoski)](http://www.concurrency.com/infrastructure/service-manager-request-query-result-filtering/)

Keep this in mind if you are using query results in your request
offerings. Not only a performance optimizations, but there are a
(configurable) limit to how many objects are returned which can easily
confuse the requester.

```

```

```

```

```

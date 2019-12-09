
I have not been able to find a whole lot of easy accesible information
(ie. blogposts) on how to do error handling for runbooks in SC
Orchestrator. After having conversed with Jakob from Coretech
(<http://www.coretech.dk/>) and attending one of their seminars I got
alot wiser on an approach to this (which I found very sensible). I hope
this post can help others get started on this necessary aspect of
developing runbooks.
```
```
```
A simple approach can be found in the following, and a good place to get
started. What we want to do is simply get the *Service Request* with a
specific ID. If none is found we wish to log the event.
```
```
```
![](//2.bp.blogspot.com/-80SVnc-AGx8/UXBKczMeJMI/AAAAAAAACKs/7JGpKWeMM9I/s400/demo1.png)
![](//3.bp.blogspot.com/-OEI_qfpJbgk/UXBKeOr4gAI/AAAAAAAACK0/z5iX5cv-mfk/s400/demo2.png)
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [![](//4.bp.blogspot.com/-qW1abBSCNGc/UXBMAddGTyI/AAAAAAAACLE/fVVdcUdEvi8/s400/demo3.png){width="400" height="250"}](//4.bp.blogspot.com/-qW1abBSCNGc/UXBMAddGTyI/AAAAAAAACLE/fVVdcUdEvi8/s1600/demo3.png)
  *Get SR* will return *sucess* even if no objects was found with the given GUID. The link criteria  logic is a double negative, for which I apologize. These are normally not easy to comprehend.
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [![](//2.bp.blogspot.com/-5w1Gr7KuUOg/UXBQA_aH9iI/AAAAAAAACLU/g88YXcvlXE0/s400/demo4.png){width="400" height="250"}](//2.bp.blogspot.com/-5w1Gr7KuUOg/UXBQA_aH9iI/AAAAAAAACLU/g88YXcvlXE0/s1600/demo4.png)
  If no objects are found we log an event.
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
```
```
```
Let\'s try and run it. In my experience the *Runbook Tester* will not
log events, and just clicking *run* will not work for some reason (if
someone knows please tell me in the comments). Instead create yet
another runbook as below.
```
```
```
![](//1.bp.blogspot.com/-QqyGG4Dyc2M/UXBRFznrNJI/AAAAAAAACLc/zOIQm0HZYLY/s400/demo5.png)
```
```
```
An event in your log should appear after running this runbook, and look
something like this:
```
```
```
![](//3.bp.blogspot.com/-FZWV_S2s4tE/UXBRu-sgg_I/AAAAAAAACLk/3QmZ2ydxwv4/s400/demo6.png)
```
```
```
That was easy! But what if the *Get SR* activity failed? And as you may
have noticed, the runbook completed with success although we defined no
Service Request found as a failure. In part 2 (posted soon) I will
address these issues.
```
```
```

**Converted from html using [convert.ps1](https://github.com/spaelling/Blog/blob/master/convert.ps1)**


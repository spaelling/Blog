As I found Microsoft\'s documentation for [Upload
Attachment](http://technet.microsoft.com/en-us/library/hh549280.aspx) somewhat
lacking, so I will share my experience. This tutorial will help you
attach a file to a given Work Item such as a Service Request or an
Incident.
The final product will look something like this:

![](//2.bp.blogspot.com/-PscZpKfIUOc/UWSLCaJqQgI/AAAAAAAACHw/r0zWkuwzb0k/s400/orch01.png)
Add a parameter to *Initialize Data* that will contain the given Work
Items ID, in this case a Service Request.
*Get SR* (*Get Object*) is as expected. Select whatever Work Item class
you wish to attach a file to.
*Get File Status* from the *File Management* integration pack is also
very straightforward. Select the file one wish to attach. If this is a
variable value, one could add the filename (possibly one a network
shared drive) as a parameter to *Initialize Data*.
As opposed to Microsoft\'s step 3.9 in the linked documentation, I would
much rather give the attachment a unique identifier, and for this
purpose I shall use Powershell. Script is as follows:
![](//3.bp.blogspot.com/-gQVSDNKa4aA/UWSNCtVbbmI/AAAAAAAACH4/TMQZiTGX8FM/s400/orch02.png)
For your copy-paste leisure: **\$guid = \[guid\]::NewGuid()**, and in
the Published Data tab do as follows:
![](//4.bp.blogspot.com/-lEJ-adVI6cQ/UWSNuE6oLhI/AAAAAAAACIA/rX6ZzJF_htQ/s400/orch3.png)
which will make the newly created guid available on the databus (and
used in the following activity).
Next we will use the *Create Related Object* activity which looks like:
![](//4.bp.blogspot.com/-i2RrcP8vqZY/UWSOWRDlWiI/AAAAAAAACII/AfMpktc87k8/s400/orch04.png)
And the rest of the fields:
![](//4.bp.blogspot.com/-GXG6H_pPwgk/UWSOj6SGAXI/AAAAAAAACIQ/rrRAtJgNxgg/s400/orch05.png)
At this point the given Work Item would have an attachment. The final
step is to put content into the attachment using *Upload Attachment*:
![](//4.bp.blogspot.com/-iR8iEoQTPiE/UWSO-4ABbHI/AAAAAAAACIY/2B0mjDRLxY8/s400/orch06.png)
Note that the Object Guid is *[Target]{.underline} Object Guid* from the
previous activity (easy detail to miss in the documentation).

**Converted from html using [convert.ps1](https://github.com/spaelling/Blog/blob/master/convert.ps1)**


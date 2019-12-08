No time since I wrote about Service Manager. Something that comes back
to haunt me from time to time is filtering on NULL. I always forget how,
so now I will document it, once and for all!

A script speaks a thousand words:
```
+-----------------------------------+-----------------------------------+
|     1                             |     $IRClass = Get-SC             |
|     2                             | SMClass system.workitem.incident$ |
|     3                             |     # get all IRs wh              |
|     4                             | ere the classification is not set |
|     5                             |                                   |
|     6                             |    Get-SCSMObject -Class $IRClass |
|     7                             |  -Filter "Classification -ISNULL" |
|                                   |                                   |
|                                   |     # if we need to fil           |
|                                   | ter on a property from a class ex |
|                                   | tension, specify that exact class |
|                                   |     $MyClassExt =                 |
|                                   | Get-SCSMClass incident.extension$ |
|                                   |     G                             |
|                                   | et-SCSMObject -Class $MClassExt - |
|                                   | Filter "CustomerProperty -ISNULL" |
+-----------------------------------+-----------------------------------+
```

Converted from html using https://github.com/spaelling/Blog/blob/master/convert.ps1 


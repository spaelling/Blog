As part of the employee onboarding process there is a request offering
on the portal that HR fills out and submits. But recent automation has
made a file available with the same information as was entered into the
portal. Next step is reading the file and submitting the same request
offering programatically (and 100% autonomous).

Using the script I just wrote one can do:


```

    Import-Csv -Path \newemployees.txt -Delimiter ';' | 
        % {\Submit-SCSMRequestOffering.ps1  -RequestOffering $RequestOffering `
                                            -MyInput @($_.firstname, $_.surname, $_.salary)}

```


Imports a csv-file and submits as many request offerings as there are
lines (excluding headers) in the file. One could also just submit a
single request offering:



```

    \Submit-SCSMRequestOffering.ps1  -RequestOffering $RequestOffering -MyInput @(1,2,3)

```


The input corresponds to the questions given in the request offering,
and the answer mapping is retained. This is especially useful in flows
with many activities where the input to the request offering must be
available. Coupled with another script i wrote ([Including extension
properties in the description
field](http://codebeaver.blogspot.dk/2014/02/scorch-including-extension-properties.html))
the activities become a breeze to complete, everything you need right
there in the description in a nice prose.

Download the script from [Technet
Gallery](https://gallery.technet.microsoft.com/Submit-SCSM-Request-22b0488c).
Remember to rate!

```

```

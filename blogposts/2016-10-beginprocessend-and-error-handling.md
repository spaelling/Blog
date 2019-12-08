I had to wrap my mind around error handling and the
*begin..process..end* function in PowerShell. It becomes really fun when
I start throwing different *ErrorActions* after it!

This will be mostly some PowerShell snippets and their result. So
without further ado, lets dive into some code!

This is a really simple function:


```

    function myfunc
    {
        [cmdletbinding()]
        param()

        begin
        {
            # some init code that throws an error
            try
            {
                throw 'some error'
                # code never reaches here
                Write-Output 'begin block'
            }
            catch [System.Exception]
            {
                Write-Error 'begin block'
            }
        }
        process
        {
            Write-Output 'process block'
        }
        end
        {
            Write-Output 'end block'
        }
    }
    Clear-Host
    $VerbosePreference = "Continue"

    Write-Host "-ErrorAction SilentlyContinue: the Write-Error in the begin block is suppressed" `
        -ForegroundColor Cyan
    myfunc -ErrorAction SilentlyContinue
    Write-Host "-ErrorAction Continue: displays the Write-Error in the begin block,
    but the process and end block is executed" `
        -ForegroundColor Cyan
    myfunc -ErrorAction Continue
    Write-Host "-ErrorAction Stop: displays the Write-Error in the begin block. 
    The Write-Error in the begin block becomes a terminating error. 
    The process and end block is not executed" `
        -ForegroundColor Cyan
    myfunc -ErrorAction Stop

```


The output is:

[![](https://2.bp.blogspot.com/-lB5WD9nJN9Q/V_TmYp9VThI/AAAAAAAASuU/iQlI35oy55UikaQMC3nw4s2raZzXINmvwCK4B/s1600/output1.PNG)](//2.bp.blogspot.com/-lB5WD9nJN9Q/V_TmYp9VThI/AAAAAAAASuU/iQlI35oy55UikaQMC3nw4s2raZzXINmvwCK4B/s1600/output1.PNG)


We see that for both ErrorActions *Continue/SilentlyContinue* that the
process block is executed. When we use *Stop* then Write-Error becomes a
terminating error and the pipeline is stopped.

Let us not dwell on that and move onto a function with some actual
input:


```

    # with input
    function myfunc
    {
        [cmdletbinding()]
        param(
            [Parameter(
                Position=0, 
                Mandatory=$true, 
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true)
            ]
            $x
        )

        begin
        {
            # No errors in the begin block this time
            Write-Output 'begin block'
        }
        process
        {
            if($x -gt 2)
            {
                Write-Error "$x is too big to handle!"
            }
            # echo input
            Write-Output $x
        }
        end
        {
            Write-Output 'end block'
        }
    }
    Clear-Host
    $VerbosePreference = "Continue"

    Write-Host "-ErrorAction SilentlyContinue: the Write-Error in the process block is suppressed" `
        -ForegroundColor Cyan
    @(1,2,3) | myfunc -ErrorAction SilentlyContinue

    Write-Host "-ErrorAction Continue: The Write-Error in the process block is displayed,
    but `$x is still echoed" `
        -ForegroundColor Cyan
    @(1,2,3) | myfunc -ErrorAction Continue

    Write-Host "-ErrorAction Stop: The Write-Error in the process block becomes a terminating error, 
    `$x > 2 is NOT echoed" `
        -ForegroundColor Cyan
    @(1,2,3) | myfunc -ErrorAction Stop

```


The output is:

[![](https://1.bp.blogspot.com/-2KwQ82BkqFk/V_TnpPyerjI/AAAAAAAASug/OFNB3-74r9oIP4Hlr4RVQ36kyE57CFi1gCK4B/s1600/output2.PNG)](//1.bp.blogspot.com/-2KwQ82BkqFk/V_TnpPyerjI/AAAAAAAASug/OFNB3-74r9oIP4Hlr4RVQ36kyE57CFi1gCK4B/s1600/output2.PNG)

Now we see that something uninteded is happening for both ErrorActions
*Continue/SilentlyContinue*. 3 is echoed still. With *Stop* the story is
as before, Write-Error becomes a terminating error and 3 is not echoed.

Now we basically just add a return statement:


```

    # with input
    function myfunc
    {
        [cmdletbinding()]
        param(
            [Parameter(
                Position=0, 
                Mandatory=$true, 
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true)
            ]
            $x
        )

        begin
        {
            # No errors in the begin block this time
            Write-Output 'begin block'
        }
        process
        {
            if($x -gt 2)
            {
                Write-Error "$x is too big to handle!"
                # continue on the pipeline. NOTE: continue does NOT continue but rather shuts down the pipeline completely
                return
            }
            # echo input
            Write-Output $x
        }
        end
        {
            Write-Output 'end block'
        }
    }
    Clear-Host
    $VerbosePreference = "Continue"

    Write-Host "-ErrorAction SilentlyContinue: the Write-Error in the process block is suppressed
    (for both 3 and 4), and `$x > 2 is not echoed" `
        -ForegroundColor Cyan
    @(1,2,3,4) | myfunc -ErrorAction SilentlyContinue

    Write-Host "-ErrorAction Continue: The Write-Error in the process block is displayed
    (twice, for both 3 and 4). `$x > 2 is not echoed" `
        -ForegroundColor Cyan
    @(1,2,3,4) | myfunc -ErrorAction Continue
    Write-Host 'The script keeps running' `
        -ForegroundColor Cyan

    Write-Host "-ErrorAction Stop: The Write-Error in the process block becomes a terminating error,
    '3' is NOT echoed. return is not exectuted hence the pipeline stops" `
        -ForegroundColor Cyan
    @(1,2,3,4) | myfunc -ErrorAction Stop
    Write-Host 'this is not reached' `
        -ForegroundColor Cyan

```


The output is:

[![](https://2.bp.blogspot.com/-FlD9mkKEVcQ/V_TpUR1OlgI/AAAAAAAASus/vW3J-KQYSkM70zJkm0hmEZwQIyWl2Zb4ACK4B/s1600/output3.PNG)](//2.bp.blogspot.com/-FlD9mkKEVcQ/V_TpUR1OlgI/AAAAAAAASus/vW3J-KQYSkM70zJkm0hmEZwQIyWl2Zb4ACK4B/s1600/output3.PNG)

We see that in all 3 cases that x greater than 2 is not echoed. Now
ErrorAction Stop makes sense. We indicate that if the function fails for
any input we do not wish to continue the script.

And we can add some error handling:


```

    # with input
    function myfunc
    {
        [cmdletbinding()]
        param(
            [Parameter(
                Position=0, 
                Mandatory=$true, 
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true)
            ]
            $x
        )

        begin
        {
            # No errors in the begin block this time
            Write-Output 'begin block'
        }
        process
        {
            try
            {
                if($x -gt 2)
                {
                    # this puts the error into the $Error variable
                    throw "$x is too big to handle!"

                }
                # echo input
                Write-Output $x
                }
            catch [System.Exception]
            {
                Write-Error $Error[0].Exception
                Write-Verbose "continue on the pipeline '$x'"
                return
            }
            Write-Verbose "continue on the pipeline '$x'"
        }
        end
        {
            Write-Output 'end block'
        }
    }
    Clear-Host
    $VerbosePreference = "Continue"

    Write-Host "-ErrorAction SilentlyContinue: the Write-Error in the process block is suppressed 
    (for both 3 and 4), and `$x is not echoed" `
        -ForegroundColor Cyan
    @(1,2,3,4) | myfunc -ErrorAction SilentlyContinue

    Write-Host "-ErrorAction Continue: The Write-Error in the process block is displayed 
    (twice, for both 3 and 4).`$x is not echoed" `
        -ForegroundColor Cyan
    @(1,2,3,4) | myfunc -ErrorAction Continue
    Write-Host 'The script keeps running' `
        -ForegroundColor Cyan

    Write-Host "-ErrorAction Stop: The Write-Error in the process block becomes a terminating error, 
    '3' is NOT echoed. return is not exectuted and the pipeline stops" `
        -ForegroundColor Cyan
    @(1,2,3,4) | myfunc -ErrorAction Stop
    Write-Host 'this is not reached' `
        -ForegroundColor Cyan

```


The output is:
[![](https://3.bp.blogspot.com/-2vzCyDwazJg/V_TqHGpUgXI/AAAAAAAASu4/w7AGOl0Aj_QNVthd-BwSMVRptbVks4qLACK4B/s1600/output4.PNG)](//3.bp.blogspot.com/-2vzCyDwazJg/V_TqHGpUgXI/AAAAAAAASu4/w7AGOl0Aj_QNVthd-BwSMVRptbVks4qLACK4B/s1600/output4.PNG)

I hope this helps understanding how some of the *begin..process..end*
function works with regards to errors and error handling. I know I will
be returning to this from time and again :D



```

```

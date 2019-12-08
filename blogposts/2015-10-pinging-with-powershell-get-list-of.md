Just about every IT guy or girl on the planet has used *ping* countless
of times. With Powershell those days are over: Meet
[Test-Connection](https://technet.microsoft.com/en-us/library/hh849808.aspx).
It works just as you would expect and similar to ping, the advantage
being that you (by default) get an object of type
\"System.Management.ManagementObject\#root\\cimv2\\Win32\_PingStatus\"
back.

I wont go into details on how to use Test-Connection, there are plenty
of ressources doing just that. But I recently discover a very cool way
to use Test-Connection against a large number of servers. And as they
say, A script is worth a thousand words:


    function Check-Online
    {
        param(
            $ComputerName
            )

        Begin
        {
            # put live servers into this list
            $Script:serverlist = @()
        }

        Process
        {
            If (Test-Connection -Count 1 -ComputerName  $_ -TimeToLive 5 -asJob | 
             Wait-Job |
             Receive-Job |
             ? { $_.StatusCode -eq 0 } )
            {
                $Script:serverlist += $_
            }
        }
        End
        {
            return $Script:serverlist
        }
    }

    # get computer names from hyper-v
    $ComputerNames = Get-VM | Select-Object -ExpandProperty Name
    # check which are online
    $ComputerNames | Check-Online


Simply feed the Check-Online function a list of computernames (IPs
should work just as well) and it will return a list of online servers
within seconds.

I think credit for the original code goes to my
[Lumagate](http://www.lumagate.com/) colleague [Claus
Nielsen](http://www.xipher.dk/WordPress/) who just happens to be a
Powershell MVP.

Download script from [Technet
gallery](https://gallery.technet.microsoft.com/Get-a-list-of-online-ea97e7f7).

```

```

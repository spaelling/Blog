There are plenty of scripts around that helps deploying Nano server. But
there seems to be issues between the various TPs, I had trouble with a
script that worked for TP4 but not at all for TP5.\
\
So I ended up creating my own. It should just run in one go, but I
suggest you take a few lines at at time to sort out any issues.\
\
The script as follows, and found on [Technet
gallery](https://gallery.technet.microsoft.com/Scripted-Nano-server-439ec923).\
\
\

<div>

+-----------------------------------+-----------------------------------+
|      1                            |     # note this is w              |
|      2                            | ritten for Server 2016 TP5 - it p |
|      3                            | robably doesn't work on other TPs |
|      4                            |                                   |
|      5                            |     # create thi                  |
|      6                            | s folder and copy the NanoServerI |
|      7                            | mageGenerator from the 2016 media |
|      8                            |     cd D:\NanoServer              |
|      9                            |                                   |
|     10                            |     Impo                          |
|     11                            | rt-Module .\NanoServerImageGenera |
|     12                            | tor\NanoServerImageGenerator.psm1 |
|     13                            |                                   |
|     14                            |                                   |
|     15                            |     $BasePath = "D:\NanoServer"   |
|     16                            |     $Ta                           |
|     17                            | rgetPath = "$BasePath\Nano01.vhd" |
|     18                            |     $ComputerName = "Nano01"      |
|     19                            |     $Passwo                       |
|     20                            | rd = ConvertTo-SecureString -AsPl |
|     21                            | ainText -String "Password" -Force |
|     22                            |                                   |
|     23                            |     $IPAddress = "192.168.0.42"   |
|     24                            |                                   |
|     25                            |   $GatewayAddress = "192.168.0.1" |
|     26                            |     $DNSAddre                     |
|     27                            | sses = ('192.168.0.21','8.8.8.8') |
|     28                            |                                   |
|     29                            | $Ipv4SubnetMask = "255.255.255.0" |
|     30                            |                                   |
|     31                            |     $Domain = 'my.domain'         |
|     32                            |                                   |
|     33                            |     $Parameters = @{              |
|     34                            |         DeploymentType = 'Guest'  |
|     35                            |         Edition = 'Datacenter'    |
|     36                            |         MediaPath = "E:\"         |
|     37                            |         BasePath = $BasePath      |
|     38                            |         TargetPath = $TargetPath  |
|     39                            |                                   |
|     40                            |      ComputerName = $ComputerName |
|     41                            |                                   |
|     42                            | AdministratorPassword = $Password |
|     43                            |         Ipv4Address = $IPAddress  |
|     44                            |                                   |
|     45                            |  Ipv4SubnetMask = $Ipv4SubnetMask |
|     46                            |                                   |
|     47                            |     Ipv4Gateway = $GatewayAddress |
|     48                            |         Ipv4Dns = $DNSAddresses   |
|     49                            |                                   |
|     50                            | InterfaceNameOrIndex = "Ethernet" |
|     51                            |     }                             |
|     52                            |                                   |
|     53                            |     New-NanoServerIm              |
|     54                            | age @Parameters -ErrorAction Stop |
|     55                            |                                   |
|     56                            |                                   |
|     57                            | # credentials for the nano server |
|     58                            |     $                             |
|     59                            | User = "$IPAddress\Administrator" |
|     60                            |     $Credent                      |
|     61                            | ial = New-Object -TypeName System |
|     62                            | .Management.Automation.PSCredenti |
|     63                            | al -ArgumentList $User, $Password |
|     64                            |                                   |
|     65                            |     # add it to trusted hosts     |
|     66                            |     Set-Item WSMan:\l             |
|     67                            | ocalhost\Client\TrustedHosts -Val |
|     68                            | ue $IPAddress -Force -Concatenate |
|     69                            |                                   |
|     70                            |     # size of the vhd - WOW!      |
|     71                            |     [int]((Get-ChildItem          |
|     72                            |  -Path $TargetPath).Length / 1MB) |
|     73                            |                                   |
|     74                            |     # can o                       |
|     75                            | nly install IIS and SCVMM offline |
|     76                            |     Fi                            |
|     77                            | nd-NanoServerPackage *iis* | Inst |
|     78                            | all-NanoServerPackage -Culture 'e |
|     79                            | n-us' -ToVhd $TargetPath -Verbose |
|     80                            |     Find                          |
|     81                            | -NanoServerPackage *scvmm* | Inst |
|     82                            | all-NanoServerPackage -Culture 'e |
|     83                            | n-us' -ToVhd $TargetPath -Verbose |
|     84                            |                                   |
|     85                            |     # create a new VM             |
|     86                            |     $VMName = "Nano01"            |
|     87                            |     New-VM -                      |
|     88                            | Name $VMName -MemoryStartupBytes  |
|     89                            | 512MB -SwitchName MGMT -VHDPath $ |
|     90                            | TargetPath -Generation 1 -Verbose |
|     91                            |                                   |
|     92                            |     # and start it                |
|     93                            |     Start-VM -Name $VMName        |
|     94                            |                                   |
|     95                            |     # we w                        |
|     96                            | ait - first boot can be "slow" :D |
|     97                            |                                   |
|     98                            |  Write-Verbose "waiting abit for  |
|                                   | VM to boot for the first time..." |
|                                   |     Start-Sleep -Seconds 20       |
|                                   |                                   |
|                                   |                                   |
|                                   |    # need to run this with admini |
|                                   | strative priviliges in the domain |
|                                   |     djoin.exe /provision /dom     |
|                                   | ain $Domain /machine $ComputerNam |
|                                   | e /savefile .\"$ComputerName.txt" |
|                                   |                                   |
|                                   |     # create session object       |
|                                   |     $Sessio                       |
|                                   | n = New-PSSession -ComputerName $ |
|                                   | IPAddress -Credential $Credential |
|                                   |                                   |
|                                   |     # copy dom                    |
|                                   | ain join blob file to nano server |
|                                   |     Copy-Item                     |
|                                   | -ToSession $Session -Path .\"$Com |
|                                   | puterName.txt" -Destination "c:\" |
|                                   |                                   |
|                                   |     # enter the session           |
|                                   |                                   |
|                                   | Enter-PSSession -Session $Session |
|                                   |                                   |
|                                   |     # domain join nano server     |
|                                   |     djoin /requestodj /           |
|                                   | loadfile c:\$env:COMPUTERNAME.txt |
|                                   |  /windowspath c:\windows /localos |
|                                   |                                   |
|                                   |     # and do a restart            |
|                                   |     Restart-Computer              |
|                                   |                                   |
|                                   |     # wait for restart            |
|                                   |                                   |
|                                   |     # need to create a            |
|                                   | new session after it restarts - a |
|                                   | nd we will use domain credentials |
|                                   |                                   |
|                                   |   $User = "$Domain\Administrator" |
|                                   |     $Password                     |
|                                   | = ConvertTo-SecureString "domaina |
|                                   | dminpassword" -AsPlainText -Force |
|                                   |     $Credent                      |
|                                   | ial = New-Object -TypeName System |
|                                   | .Management.Automation.PSCredenti |
|                                   | al -ArgumentList $User, $Password |
|                                   |                                   |
|                                   |     $Sessio                       |
|                                   | n = New-PSSession -ComputerName $ |
|                                   | IPAddress -Credential $Credential |
|                                   |                                   |
|                                   |     # enter the session           |
|                                   |                                   |
|                                   | Enter-PSSession -Session $Session |
|                                   |                                   |
|                                   |     # install                     |
|                                   |  the nano server package provider |
|                                   |                                   |
|                                   |     Install-                      |
|                                   | PackageProvider NanoServerPackage |
|                                   |     Import-                       |
|                                   | PackageProvider NanoServerPackage |
|                                   |                                   |
|                                   |     Find-NanoServerPackage        |
+-----------------------------------+-----------------------------------+

</div>

<div>

</div>

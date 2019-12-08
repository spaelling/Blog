No one likes writing documentation. Even less so updating existing
documentation. But it is nice to have when you need it. Also don\'t just
write documentation for the sake of documentation. Write it down if you
need it later and is not inherently obvious from the code (or whatever).
But good documentation practice is a can of worms I am not going to open
here.

In the following I will present a script that helps with something as
tedious as documenting views in Service Manager. Are you going to do
that manually?
::: {.separator}
[![](//1.bp.blogspot.com/-d2naK9igUCY/VLTj4bAsTeI/AAAAAAAADyE/Cwt-RNNeX9o/s1600/badtime01.jpg){width="640"
height="640"}](//1.bp.blogspot.com/-d2naK9igUCY/VLTj4bAsTeI/AAAAAAAADyE/Cwt-RNNeX9o/s1600/badtime01.jpg)
:::
Also views change, and you would then have to update your documentation.
You really need this script!
```
+-----------------------------------+-----------------------------------+
|       1                           |     # Author: And                 |
|       2                           | ers Spælling, spaelling@gmail.com |
|       3                           |     #                             |
|       4                           |     # This scr                    |
|       5                           | ipt can assist in documenting Ser |
|       6                           | vice Manager views. Extracts SCSM |
|       7                           |  view information to csv and html |
|       8                           |     # View des                    |
|       9                           | cription should include what the  |
|      10                           | view is supposed to show (that is |
|      11                           |  not obvious from the view title) |
|      12                           |     #                             |
|      13                           |                                   |
|      14                           |  # Requirements: SMLets installed |
|      15                           |                                   |
|      16                           |     # enter your servic           |
|      17                           | e manager management server below |
|      18                           |                                   |
|      19                           |  $SCSM_MANAGEMENT_SERVER =  "SM1" |
|      20                           |                                   |
|      21                           |     # start of script             |
|      22                           |                                   |
|      23                           |                                   |
|      24                           |    # remove this module if loaded |
|      25                           |     $SMModule = Get-Module -N     |
|      26                           | ame System.Center.Service.Manager |
|      27                           |     if($SMModule)                 |
|      28                           |     {                             |
|      29                           |         Remove-Module $SMModule   |
|      30                           |     }                             |
|      31                           |                                   |
|      32                           |     Import-Module 'SMLets'        |
|      33                           |     i                             |
|      34                           | f(-not (Get-Module -Name SMLets)) |
|      35                           |     {                             |
|      36                           |         Write-Host                |
|      37                           |  "Unable to import module SMLets" |
|      38                           |         Exit                      |
|      39                           |     }                             |
|      40                           |                                   |
|      41                           |                                   |
|      42                           |   # try and get it from global va |
|      43                           | riable - SMLets will look for thi |
|      44                           | s if ComputerName is not supplied |
|      45                           |     $Compute                      |
|      46                           | rName = $Global:smdefaultcomputer |
|      47                           |     if(-not $ComputerName)        |
|      48                           |     {                             |
|      49                           |         $Compu                    |
|      50                           | terName = $SCSM_MANAGEMENT_SERVER |
|      51                           |     }                             |
|      52                           |                                   |
|      53                           |     #get views and folders        |
|      54                           |     $Views = Get-SCS              |
|      55                           | MView -ComputerName $ComputerName |
|      56                           |     $Folders = Get-SCSMF          |
|      57                           | older -ComputerName $ComputerName |
|      58                           |                                   |
|      59                           |     # tar                         |
|      60                           | get only subclasses of this class |
|      61                           |     $BaseClass                    |
|      62                           | = Get-SCSMClass -ComputerName $Co |
|      63                           | mputerName -Name System.WorkItem$ |
|      64                           |                                   |
|      65                           |     # store output in list        |
|      66                           |     $Out = @()                    |
|      67                           |     # progress counter            |
|      68                           |     $i = 1;                       |
|      69                           |     # iterate over all views      |
|      70                           |     foreach($View in $Views)      |
|      71                           |     {                             |
|      72                           |                                   |
|      73                           |                                   |
|      74                           |        Write-Progress -Activity " |
|      75                           | Processing views..." -Status "Pro |
|      76                           | cessing ($i of $($Views.Count)):  |
|      77                           | `"$($View.DisplayName)`"" -Percen |
|      78                           | tComplete (100*$i/($Views.Count)) |
|      79                           |                                   |
|      80                           |                                   |
|      81                           | if($View.DisplayName -eq $null -o |
|      82                           | r $View.DisplayName.Length -eq 0) |
|      83                           |         {                         |
|      84                           |                                   |
|      85                           |      # not sure what these are... |
|      86                           |             # Write-Ho            |
|      87                           | st $View.Name, has no displayname |
|      88                           |             continue;             |
|      89                           |         }                         |
|      90                           |                                   |
|      91                           |         $Managemen                |
|      92                           | tPack = $View.GetManagementPack() |
|      93                           |         $TargetClass              |
|      94                           |  = Get-SCSMClass -ComputerName $C |
|      95                           | omputerName -Id ($View.Target.Id) |
|      96                           |                                   |
|      97                           |                                   |
|      98                           |      # we only want targetclasses |
|      99                           |  that inherits specific baseclass |
|     100                           |         if($Targ                  |
|     101                           | etClass.IsSubClassOf($BaseClass)) |
|     102                           |         {                         |
|     103                           |                                   |
|     104                           |  $ParentFolders = $Folders | ? {$ |
|     105                           | _.Id -in ($View.ParentFolderIds|  |
|     106                           | select -ExpandProperty Guid)} | s |
|     107                           | elect -ExpandProperty DisplayName |
|     108                           |                                   |
|     109                           |            # if based on a combin |
|     110                           | ation class we want to know which |
|     111                           |             #                     |
|     112                           | first convert to xml so that we c |
|     113                           | an easily traverse the xml-string |
|     114                           |             [xml]$                |
|     115                           | Configuration = [xml]("<xmlroot>$ |
|     116                           | ($View.Configuration)</xmlroot>") |
|     117                           |             # traverse...         |
|     118                           |                                   |
|     119                           | $Value = $Configuration.xmlroot.D |
|     120                           | ata.ItemsSource.AdvancedListSuppo |
|     121                           | rtClass.'AdvancedListSupportClass |
|     122                           | .Parameters'.QueryParameter.Value |
|     123                           |                                   |
|     124                           |        $TypeProjectionName = $Val |
|     125                           | ue.Replace('$MPElement[Name=','') |
|     126                           | .Replace(']$','').Replace("'","") |
|     127                           |             # if defined in an    |
|     128                           | other MP we must remove the alias |
|     129                           |             if($                  |
|     130                           | TypeProjectionName.Contains('!')) |
|     131                           |             {                     |
|     132                           |                                   |
|     133                           |            $TypeProjectionName =  |
|     134                           | $TypeProjectionName.Split('!')[1] |
|     135                           |             }                     |
|     136                           |                                   |
|     137                           |             # we now h            |
|                                   | ave the Id of the type projection |
|                                   |                                   |
|                                   |      $TypeProjection = Get-SCSMTy |
|                                   | peProjection -ComputerName $Compu |
|                                   | terName -Name $TypeProjectionName |
|                                   |                                   |
|                                   |                                   |
|                                   |       # if based on a basic class |
|                                   |             $                     |
|                                   | TypeProjectionDisplayName = 'N/A' |
|                                   |                                   |
|                                   |             if($TypeProjection)   |
|                                   |             {                     |
|                                   |                                   |
|                                   |                 # t               |
|                                   | ypeprojections can share the same |
|                                   |  name. If more than one is found  |
|                                   | we use the one with a displayname |
|                                   |                                   |
|                                   |      if(([array]$TypeProjection | |
|                                   |  ? {$_.DisplayName}).Count -gt 0) |
|                                   |                 { # se            |
|                                   | lect first one with a displayname |
|                                   |                     $TypeProjecti |
|                                   | on = [array]$TypeProjection | ? { |
|                                   | $_.DisplayName} | select -First 1 |
|                                   |                 }                 |
|                                   |                 else              |
|                                   |                 {                 |
|                                   | # no displaynames, select first 1 |
|                                   |                                   |
|                                   |         $TypeProjection = [array] |
|                                   | $TypeProjection | select -First 1 |
|                                   |                 }                 |
|                                   |                                   |
|                                   |                                   |
|                                   |           $TypeProjectionDisplayN |
|                                   | ame = $TypeProjection.DisplayName |
|                                   |                                   |
|                                   |                 # if there w      |
|                                   | as no displayname we use the name |
|                                   |                 if                |
|                                   | (-not $TypeProjectionDisplayName) |
|                                   |                 {                 |
|                                   |                                   |
|                                   |                  $TypeProjectionD |
|                                   | isplayName = $TypeProjection.Name |
|                                   |                 }                 |
|                                   |             }                     |
|                                   |                                   |
|                                   |             $Out +=               |
|                                   |  New-Object PSObject -Property @{ |
|                                   |                                   |
|                                   |        Title = $View.DisplayName; |
|                                   |                                   |
|                                   |  Description = $View.Description; |
|                                   |                 Target            |
|                                   | Class = $TargetClass.DisplayName; |
|                                   |                 TypeProject       |
|                                   | ion = $TypeProjectionDisplayName; |
|                                   |                 ManagementPa      |
|                                   | ck = $ManagementPack.DisplayName; |
|                                   |                                   |
|                                   |    ParentFolder = $ParentFolders; |
|                                   |                                   |
|                                   |      VisibleInUI = $View.Visible; |
|                                   |             };                    |
|                                   |         }                         |
|                                   |                                   |
|                                   |         # update progress         |
|                                   |  counter - used in Write-Progress |
|                                   |         $i++                      |
|                                   |     }                             |
|                                   |                                   |
|                                   |                                   |
|                                   |  # adding some style to the table |
|                                   |     $head = @'                    |
|                                   |     <style>                       |
|                                   |     T                             |
|                                   | ABLE{border-width: 1px; border-st |
|                                   | yle: solid; border-color: black;} |
|                                   |     TH{border-wi                  |
|                                   | dth: 1px; border-style: solid; bo |
|                                   | rder-color: black; padding: 1px;} |
|                                   |     TD{border-wi                  |
|                                   | dth: 1px; border-style: solid; bo |
|                                   | rder-color: black; padding: 1px;} |
|                                   |     </style>                      |
|                                   |     '@                            |
|                                   |     # adding a title              |
|                                   |     $bo                           |
|                                   | dy = '<H2>Request Offerings</H2>' |
|                                   |                                   |
|                                   |     # sort using this order       |
|                                   |     $So                           |
|                                   | rtOrder = 'ParentFolder', 'Title' |
|                                   |     # select th                   |
|                                   | e order of properties (to output) |
|                                   |     $Properties = 'Titl           |
|                                   | e', 'Description', 'TargetClass', |
|                                   |  'TypeProjection', 'ManagementPac |
|                                   | k', 'ParentFolder', 'VisibleInUI' |
|                                   |     # convert to html and csv     |
|                                   |                                   |
|                                   |  $Out | Sort-Object $SortOrder |  |
|                                   | Select-Object -Property $Properti |
|                                   | es | ConvertTo-Html -Head $head - |
|                                   | Body $body > C:\temp\viewdoc.html |
|                                   |     $Out | Sort-Object $SortOr    |
|                                   | der | Select-Object -Property $Pr |
|                                   | operties | Export-Csv -Path C:\te |
|                                   | mp\viewdoc.csv -NoTypeInformation |
+-----------------------------------+-----------------------------------+
```
You can [download the code from Technet
gallery](https://gallery.technet.microsoft.com/Scripted-Service-Manager-50db83d5).
It also includes code on how to do the same with Request Offerings.
I also found
this: <http://www.buchatech.com/2015/03/service-manager-discovery-report/> -
check it out.

Converted from html using https://github.com/spaelling/Blog/blob/master/convert.ps1 


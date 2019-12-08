Are you doing Management Pack backups? Well, you should. Schedule the
script to run daily (during off-hours).\
\
I have had this lying around for a while now, and thought I would share.
Script as follows (Download
[here](https://gallery.technet.microsoft.com/Service-Manager-Management-e5dd00ec)
- please rate):\
\
\

<div>

+-----------------------------------+-----------------------------------+
|       1                           |                                   |
|       2                           |    ############################## |
|       3                           | ################################# |
|       4                           |     # Backup                      |
|       5                           |  service manager management packs |
|       6                           |     #                             |
|       7                           |     # Authored by:                |
|       8                           |     # And                         |
|       9                           | ers Spælling, spaelling@gmail.com |
|      10                           |     #                             |
|      11                           |                                   |
|      12                           |    ############################## |
|      13                           | ################################# |
|      14                           |                                   |
|      15                           |     # EVENT IDs                   |
|      16                           |     # 800 - Warning               |
|      17                           |    - Backup completed with errors |
|      18                           |     # 700 - Erro                  |
|      19                           | r       - Unable to import module |
|      20                           |     # 701 - Error                 |
|      21                           |   - Failed to backup unsealed MPs |
|      22                           |     # 702 - Error                 |
|      23                           |     - Failed to backup sealed MPs |
|      24                           |     # 703 - Error       - F       |
|      25                           | ailed to create new backup folder |
|      26                           |     # 600 - Information - S       |
|      27                           | uccesfully backed up unsealed MPs |
|      28                           |     # 601 - Information -         |
|      29                           |  Succesfully backed up sealed MPs |
|      30                           |     # 602 - Information -         |
|      31                           | Removed old backup (unsealed MPs) |
|      32                           |     # 603 - Information           |
|      33                           | - Removed old backup (sealed MPs) |
|      34                           |                                   |
|      35                           | # 604 - Information - Backup done |
|      36                           |     # 605 - Inf                   |
|      37                           | ormation - Starting MP backup job |
|      38                           |                                   |
|      39                           |     # CONSTANTS                   |
|      40                           |     # Wr                          |
|      41                           | ite to event log on this computer |
|      42                           |     $EventLogComputerName = ''    |
|      43                           |     $                             |
|      44                           | EventLogName = "SCSM backup task" |
|      45                           |     $Date = Get-Date              |
|      46                           |                                   |
|      47                           |     # user defined #              |
|      48                           |                                   |
|      49                           |   # definde rootpath to save mana |
|      50                           | gemen packs. Should be UNC format |
|      51                           |     $RootPath = '\SCSM_MP\'       |
|      52                           |     # Define                      |
|      53                           | service manager management server |
|      54                           |     $SMMS = $EventLogComputerName |
|      55                           |                                   |
|      56                           |     # k                           |
|      57                           | eep MP backups for this many days |
|      58                           |     $BACKUP_RETAIN_IN_DAYS = 28   |
|      59                           |                                   |
|      60                           |     #                             |
|      61                           |  increase if failed to backup MPs |
|      62                           |     $ErrorCount = 0               |
|      63                           |                                   |
|      64                           |     # used to write to event log  |
|      65                           |     # Example                     |
|      66                           |  use, create event with event ID  |
|      67                           | 702 and type Error: CreateEventLo |
|      68                           | g "Error description" 702 "Error" |
|      69                           |     Function CreateEventLog       |
|      70                           |     {                             |
|      71                           |         Param(                    |
|      72                           | $EventDescription,$EventID,$Type) |
|      73                           |                                   |
|      74                           |        $EventlogExists = Get-Even |
|      75                           | tLog -ComputerName $EventLogCompu |
|      76                           | terName -List | Where-Object {$_. |
|      77                           | LogDisplayName -eq $EventLogName} |
|      78                           |         If(-not $EventlogExists)  |
|      79                           |         {                         |
|      80                           |                                   |
|      81                           |        New-EventLog -LogName $Eve |
|      82                           | ntLogName -Source AlertUpdate -Co |
|      83                           | mputerName $EventLogComputerName  |
|      84                           |         }                         |
|      85                           |         Write-EventLog -ComputerN |
|      86                           | ame $EventLogComputerName -LogNam |
|      87                           | e $EventLogName -Source AlertUpda |
|      88                           | te -Message "$EventDescription" - |
|      89                           | EventId $EventID -EntryType $Type |
|      90                           |     }                             |
|      91                           |                                   |
|      92                           |                                   |
|      93                           |  # remove SMLets module (from ses |
|      94                           | sion) if loaded  - needed to load |
|      95                           |  the System.Center.Service.Manage |
|      96                           | r module as command names overlap |
|      97                           |     if(Get-Module -Name SMLets)   |
|      98                           |     {                             |
|      99                           |         Remove-Module 'SMLets'    |
|     100                           |     }                             |
|     101                           |                                   |
|     102                           |     # find module                 |
|     103                           |  in '%SMinstalldir%\Powershell\Sy |
|     104                           | stem.Center.Service.Manager.psd1' |
|     105                           |     $SMInstallDir = (Get          |
|     106                           | -ItemProperty 'HKLM:\SOFTWARE\Mic |
|     107                           | rosoft\System Center\2010\Service |
|     108                           |  Manager\Setup').InstallDirectory |
|     109                           |     $ModuleDir                    |
|     110                           |  = $SMInstallDir + 'Powershell\Sy |
|     111                           | stem.Center.Service.Manager.psd1' |
|     112                           |                                   |
|     113                           |     Import-Module $ModuleDir      |
|     114                           |                                   |
|     115                           |     if(-not (Get-Module -Nam      |
|     116                           | e System.Center.Service.Manager)) |
|     117                           |     {                             |
|     118                           |                                   |
|     119                           |       CreateEventLog "Unable to i |
|     120                           | mport module System.Center.Servic |
|     121                           | e.Manager`nException message: $($ |
|     122                           | _.Exception.Message)" 700 "Error" |
|     123                           |         Exit                      |
|     124                           |     }                             |
|     125                           |                                   |
|     126                           |     #######################       |
|     127                           |     # BACKUP UNSEALED MPS #       |
|     128                           |     #######################       |
|     129                           |                                   |
|     130                           |     CreateEventLog "Starting      |
|     131                           |  MP backup job" 605 "Information" |
|     132                           |                                   |
|     133                           |     # Def                         |
|     134                           | ine path to save todays backup to |
|     135                           |     $Path = $RootPa               |
|     136                           | th + $Date.ToString('yyyy-MM-dd') |
|     137                           |                                   |
|     138                           |     #                             |
|     139                           | create path if it does not exists |
|     140                           |     If (-not (Tes                 |
|     141                           | t-Path $Path -ErrorAction Stop))  |
|     142                           |     {                             |
|     143                           |         try                       |
|     144                           |         {                         |
|     145                           |             $CreateOutput = N     |
|     146                           | ew-Item -ItemType Directory $Path |
|     147                           |         }                         |
|     148                           |         catch [System.Exception]  |
|     149                           |         {                         |
|     150                           |             CreateEventLog        |
|     151                           |  "Unable to create new backup fol |
|     152                           | der $Path`nException message: $($ |
|     153                           | _.Exception.Message)" 703 "Error" |
|     154                           |             $ErrorCount++         |
|     155                           |         }                         |
|     156                           |     }                             |
|     157                           |                                   |
|     158                           |     try                           |
|     159                           |     {                             |
|     160                           |         # ge                      |
|     161                           | t unsealed MPs and export to disk |
|     162                           |         Get-SCMan                 |
|     163                           | agementPack -ComputerName $SMMS | |
|     164                           |  where{$_.sealed -eq $False} | Ex |
|     165                           | port-SCManagementPack -Path $Path |
|     166                           |         Cre                       |
|                                   | ateEventLog "Succesfully backed u |
|                                   | p unsealed MPs" 600 "Information" |
|                                   |     }                             |
|                                   |     catch [System.Exception]      |
|                                   |     {                             |
|                                   |         Cre                       |
|                                   | ateEventLog "Failed to backup uns |
|                                   | ealed MPs`nException message: $($ |
|                                   | _.Exception.Message)" 701 "Error" |
|                                   |         $ErrorCount++             |
|                                   |     }                             |
|                                   |     finally                       |
|                                   |     {                             |
|                                   |         #                         |
|                                   |     }                             |
|                                   |                                   |
|                                   |     #####################         |
|                                   |     # BACKUP SEALED MPS #         |
|                                   |     #####################         |
|                                   |                                   |
|                                   |     # Def                         |
|                                   | ine path to save todays backup to |
|                                   |     $Path = $RootPath  +  $Date.T |
|                                   | oString('yyyy-MM-dd') + "\sealed" |
|                                   |                                   |
|                                   |     #                             |
|                                   | create path if it does not exists |
|                                   |     If (-not (Test-Path $Path))   |
|                                   |     {                             |
|                                   |         $CreateOutput = N         |
|                                   | ew-Item -ItemType Directory $Path |
|                                   |     }                             |
|                                   |     try                           |
|                                   |     {                             |
|                                   |         #                         |
|                                   | get sealed MPs and export to disk |
|                                   |                                   |
|                                   | Get-SCManagementPack -ComputerNam |
|                                   | e $SMMS | where{$_.sealed -eq $Tr |
|                                   | ue -and $_.Name -like "XX*"} | Ex |
|                                   | port-SCManagementPack -Path $Path |
|                                   |         C                         |
|                                   | reateEventLog "Succesfully backed |
|                                   |  up sealed MPs" 601 "Information" |
|                                   |     }                             |
|                                   |     catch [System.Exception]      |
|                                   |     {                             |
|                                   |         Crea                      |
|                                   | teEventLog "Failed to backup seal |
|                                   | ed MPs`nException message: $($_.E |
|                                   | xception.Message)" 702 "Error"    |
|                                   |         $ErrorCount++             |
|                                   |     }                             |
|                                   |     finally                       |
|                                   |     {                             |
|                                   |        #                          |
|                                   |     }                             |
|                                   |                                   |
|                                   |     ###########                   |
|                                   |     # CLEANUP #                   |
|                                   |     ###########                   |
|                                   |                                   |
|                                   |     # remove backup folder fro    |
|                                   | m $BACKUP_RETAIN_IN_DAYS days ago |
|                                   |     $DeleteFolder = $Date         |
|                                   | .AddDays(-$BACKUP_RETAIN_IN_DAYS) |
|                                   |     $DeletePath = $RootPath + $De |
|                                   | leteFolder.ToString('yyyy-MM-dd') |
|                                   |                                   |
|                                   |     # remove folder if it exists  |
|                                   |     If (Test-Path $DeletePath)    |
|                                   |     {                             |
|                                   |         $RemoveOutput =           |
|                                   |  Remove-Item $DeletePath -Recurse |
|                                   |         CreateEventLo             |
|                                   | g "Removed old backup of MPs in ` |
|                                   | "$DeletePath`"" 602 "Information" |
|                                   |     }                             |
|                                   |                                   |
|                                   |                                   |
|                                   |    # remove module (from session) |
|                                   |     if(Get-Module -Na             |
|                                   | me System.Center.Service.Manager) |
|                                   |     {                             |
|                                   |         Remove-Module             |
|                                   |  'System.Center.Service.Manager'  |
|                                   |     }                             |
|                                   |                                   |
|                                   |     if($ErrorCount -gt 0)         |
|                                   |     {                             |
|                                   |         CreateEven                |
|                                   | tLog "Backup completed with $Erro |
|                                   | rCount errors" 800 "Warning"      |
|                                   |     }                             |
|                                   |     else                          |
|                                   |     {                             |
|                                   |         CreateEventLo             |
|                                   | g "Backup done" 604 "Information" |
|                                   |     }                             |
+-----------------------------------+-----------------------------------+

</div>

<div>

</div>

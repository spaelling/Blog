Sounds too good to be true? Well it is. Almost. The script I will be
sharing today will get you a long way though. A high level rundown of
what it will do

-    stop console
-    seal MP
-    bundle MP
-    remove old MP
-    import new MP bundle
-    start console
```
That almost gets you all the way. You will have to do the clicking
yourself. You can then debug the hell out of your code following
[this](http://scsmlab.com/2013/04/09/debugging-custom-scsm-form-in-visual-studio/).
```
```
```
```
Script as follows, and download it
[here](https://gallery.technet.microsoft.com/Automating-Custom-Code-bcfdc401).
```
```
```
```
```
    # Authored by Anders Spælling, spaelling@gmail.com
    # this script automates some of the tasks needed to test custom code in the Service Manager console
    # a high level rundown:
    # stop console
    # seal MP
    # bundle MP
    # remove old MP
    # import new MP bundle
    # start console
    # This script requires 
    # module ScsmPx installed. Just run this if you haven't got it already:  & ([scriptblock]::Create((iwr -uri http://tinyurl.com/Install-GitHubHostedModule).Content)) -ModuleName ScsmPx,SnippetPx
    # need to have fastseal.exe in working dir, download from here: http://blogs.technet.com/cfs-file.ashx/__key/communityserver-components-postattachments/00-03-30-25-60/FastSeal.zip
    # guide on fastseal.exe http://scsmnz.net/sealing-a-management-pack-using-fastseal-exe/
    $DebugPreference = "Continue"
    # this needs to point at where the compiled dll will end up        
    $FullPathDLL = "C:\Users\Administrator\Documents\Visual Studio 2013\Projects\CB.SCSM.CustomWISearch\CB.SCSM.CustomWISearch\bin\Debug\CB.SCSM.CustomWISearch.dll"
    # you will need an snk file. create your own. Follow this guide if you don't know how: http://scsmnz.net/sealing-a-management-pack-using-fastseal-exe/
    # files distributed with this script also needs to go to working dir
    # this is the working dir
    cd c:\temp
    # point at your SCSM management server
    $ManagementServer = "SM01"
    # change to match your own snk file
    $KeyFile = "CB.snk"
    # MP name without extension
    $MPName = "CB.ConsoleTask.CustomWISearch"
    $Company = "Codebeaver"
    # not much need to edit below
    Import-Module ScsmPx -ErrorAction Stop
    # stop console
    Write-Debug "Stopping console..."
    Stop-Process -Name Microsoft.EnterpriseManagement.ServiceManager.UI.Console -ErrorAction SilentlyContinue
    # seal MP
    Write-Debug "Sealing MP..."
    $ArgumentList = ".\$MPNameh.xml /keyfile $KeyFile /company $Company"; #Write-Host "fastseal.exe $ArgumentList"
    Start-Process -FilePath ".\fastseal.exe" -ArgumentList $ArgumentList -Wait -NoNewWindow
    # copy dll to c:\temp
    Copy-Item $FullPathDLL -Destination c:\temp
    # bundle MP and dll
    Write-Debug "Bundling MP..."
    $DLL = $FullPathDLL.Split("\")[-1]
    New-SCSMManagementPackBundle -Name "$($MPName).mpb" -ManagementPack ".\$($MPName).mp" -Resource ".\$($DLL)" -ComputerName $ManagementServer -Force -ErrorAction Stop
    # remove previous MP (cannot overwrite sealed MP with same  MP version)
    # If you delete a sealed MP, all of the data that it defined such as new classes (and all instances of these classes) or class extensions (and all extension data) will be lost.
    $MP = Get-SCSMManagementPack -Name CB.ConsoleTask.CustomWISearch # name is the ID of the MP (as defined in xml)
    if($MP)
    {
        Write-Debug "Removing old MP..."
        Remove-SCSMManagementPack -ManagementPack $MP
    }
    # import MP bundle in new process - current process will block the file otherwise
    Write-Debug "Importing new MP bundle..."
    $MPName | powershell.exe {
        Import-SCSMManagementPack ".\$($input[0]).mpb"
        }
    # start console
    Write-Debug "Starting console..."
    & "C:\Program Files\Microsoft System Center 2012 R2\Service Manager\Microsoft.EnterpriseManagement.ServiceManager.UI.Console.exe"

Converted from html using https://github.com/spaelling/Blog/blob/master/convert.ps1 


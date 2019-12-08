$BlogUrl = 'https://blog.spaelling.xyz/'
$StartYear = 2013
# some temp dir as this is for the html files
$OutDir = "c:\temp\blogposts"
# this is where we put the markdown
$OutDirConverted = ".\blogposts"

<#
    TODO
use runspace for some of the more lengthy loops
#>

$Archive = @{}
$Now = Get-Date
$Years = $StartYear..($now.Year)
foreach ($Year in $Years) {
    $Response = Invoke-WebRequest -Uri "$BlogUrl/$Year"
    $Archive["$Year"] = $Response
}
# Next we get all links to blogposts
$Urls = @()
foreach ($Year in $Years) {
    $ParsedHtml = $Archive["$Year"].ParsedHtml
    # look for <h3 class='post-title entry-title' itemprop='name'>
    $Titles = $ParsedHtml.body.getElementsByClassName('post-title entry-title')
    foreach ($Title in $Titles) {
        $Urls += $Title.children[0].href
    }
}

$BlogPosts = @()
foreach ($Url in $Urls) {
    Write-Host "Getting '$Url'"
    $Response = Invoke-WebRequest -Uri $Url
    # TODO
    # $FileName = ($Url.Split('/') | Select-Object -Last 1)
    # TODO: use this, but make sure it starts with a / so that we can main
    $FileName = $Url.Replace($BlogUrl, '').Replace('/','-')
    $BlogPosts += $Response | Add-Member -Name FileName -Value $FileName -MemberType NoteProperty -PassThru
}

$Overwrite = $true
$OutDir = (Resolve-Path $OutDir).Path
$null = New-Item -ItemType Directory -Path $OutDir -ErrorAction SilentlyContinue
foreach ($BlogPost in $BlogPosts) { 
    [string]$Title = $BlogPost.ParsedHtml.title
    # TODO: Title is a bad filename, use href instead
    # $Title = $Title.Replace("[","").Replace("]","").Replace(":","").Replace(".","").Replace("?","")
    $FilePath = Join-Path $OutDir $BlogPost.FileName
    $FileExists = Test-Path -Path $FilePath
    if((-not $Overwrite) -and $FileExists)
    {
        Write-Host "'$FilePath' already exists, skipping"
        continue
    }
    $Divs = $BlogPost.ParsedHtml.getElementsByTagName('div')
    $TheDiv = $Divs | Where-Object {$_.className -eq 'post-body entry-content'}
    # when we do it like this then innerHTML is empty??
    # $TheDiv = $BlogPost.ParsedHtml.body.getElementsByClassName('post-body entry-content')
    
    # Need to do some housekeeping on each file as I have used hilite.me extensively for formatting code
    
    # the PRE tags really mess with pandoc if they have any style in them
    $PreWithStyle = $TheDiv.getElementsByTagName('pre') | Where-Object {$_.style.length -gt 0}
    $null = $PreWithStyle | ForEach-Object{$_.style.cssText = $null }
    
    # SPAN tags with background color is left by pandoc
    $Spans = $TheDiv.getElementsByTagName('span')
    # this does not work
    # $null = $Spans | ForEach-Object{$_.style.backgroundColor = $null }
    # so we just clear the entire style for the span
    $Spans | Where-Object {$null -ne $_.style.backgroundColor} | ForEach-Object{$_.style.cssText = $null }
    
    $DivsWithStyle = ($TheDiv.getElementsByTagName('div') | Where-Object {$_.style.length -gt 0})
    $null = $DivsWithStyle | ForEach-Object{$_.style.cssText = $null }

    <#
        TODO: 
        pandoc still leaves some stray DIV tags, but maybe it does not matter
        Some lines ends with \
        some IMG tags get garbled
    #>
    
    # The entire blogpost content is in this
    $Content = $TheDiv.innerHTML

    Write-Host "Creating '$FilePath'"
    $Content | Out-File -FilePath $FilePath -Encoding utf8
}

$OutDirConverted = (Resolve-Path $OutDirConverted).Path
foreach ($Doc in (Get-ChildItem -Path $OutDir)) {
    Write-Host "Converting '$($Doc.FullName)' to markdown"
    $FilePath = Join-Path $OutDirConverted "$($Doc.BaseName).md"
    pandoc $Doc.FullName -f html -t markdown -s -o $FilePath
}




# Next step is to convert each to markdown
# One option is to implement https://github.com/domchristie/turndown in Azure Function app, call it with the html as payload
# let reply with html converted to markdown, which we can then save to disk
# javascript cannot write to disk, so we need to do it like this.

# https://pandoc.org/ is a local solution

$IsAdmin = (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
if(-not $IsAdmin)
{
    Read-Host -Prompt 'Will attempt to use chocolatey to install Pandoc, Press any key to continue'
    Start-Process PowerShell -Verb Runas -Wait "choco install chocolatey-core.extension; choco install pandoc; Read-Host -Prompt 'Press any key to close'"
}


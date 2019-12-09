$BlogUrl = 'https://blog.spaelling.xyz/'
$StartYear = 2013
# some temp dir as this is for the html files
$OutDir = "c:\temp\blogposts"
# this is where we put the markdown
$OutDirConverted = ".\blogposts"

# this part will use chocolatey to check if pandoc is installed, and if not, install it
$PandocInstalled = (choco list -lo | Where-object { $_ -like "pandoc*" }).count -gt 0
if(-not $PandocInstalled)
{
    $IsAdmin = (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    if(-not $IsAdmin)
    {
        Read-Host -Prompt 'Will attempt to use chocolatey to install Pandoc, Press any key to continue'
        Start-Process PowerShell -Verb Runas -Wait "choco install chocolatey-core.extension; choco install pandoc; Read-Host -Prompt 'Press any key to close'"
    }
}

<#
    TODO
use runspaces, one runespace per blogpost
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
    
    # The entire blogpost content is in this
    $Content = $TheDiv.innerHTML

    Write-Host "Creating '$FilePath'"
    $Content | Out-File -FilePath $FilePath -Encoding utf8
}

$AdvBlock = @"

**Converted from html using [convert.ps1](https://github.com/spaelling/Blog/blob/master/convert.ps1)**

"@

$OutDirConverted = (Resolve-Path $OutDirConverted).Path
foreach ($Doc in (Get-ChildItem -Path $OutDir)) {
    Write-Host "Converting '$($Doc.FullName)' to markdown"
    $FilePath = Join-Path $OutDirConverted "$($Doc.BaseName).md"
    pandoc $Doc.FullName -f html -t markdown -s -o $FilePath
    
    <# POST CLEANUP
        TODO:    
    #>
    
    $Content = Get-Content -Path $FilePath
    $NewContent = @()
    # keep track of when we are in a codeblock
    $InCodeBlock = $false
    # we can skip some lines
    $SkipLine = $false
    # count blank consecutive lines
    $ConsecutiveBlankLinesCount = 0
    foreach ($Line in $Content) {
        # if ending with \
        if($Line -like "*\")
        {
            # remove last occurence of \
            $Line = $Line -replace "(.*)\\(.*)", '$1$2'
        }
        # skip if starting with :::
        if($Line -like ":::*")
        {
            continue;
        }
        # messed up image reference, ![alt text](https://something.com/icon48.png "optional text")
        # https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet#images
        # $Line = '[![](https://1.bp.blogspot.com/-k9eBbJixTgY/XO0DBXLxRyI/AAAAAAAAtW4/2MgIgbN1Tdg4NrICwYDfYmzYnD_TfY4MwCLcBGAs/s640/WAF01.png){width="640" height="176"}](https://1.bp.blogspot.com/-k9eBbJixTgY/XO0DBXLxRyI/AAAAAAAAtW4/2MgIgbN1Tdg4NrICwYDfYmzYnD_TfY4MwCLcBGAs/s1600/WAF01.png)'
        if($Line -match "^\[!*")
        {
            # remove first occurence of the [ and then everything following { (included)
            $Line = $Line -replace "\[(.*)", '$1' -replace "(.*)\{(.*)", '$1'
        }
        # the remaining is on the next line, height="176"}](https://....
        if($Line -match "^height=`"*`"}*")
        {
            continue;
        }
        if($InCodeBlock)
        {
            # trim line if in code block
            $Line = $line.Trim()
            # skip the line if blank in a code block
            if($Line.Length -eq 0)
            {
                continue;
            }
        }
        else
        {
            if($line.Trim().Length -eq 0)
            {
                $ConsecutiveBlankLinesCount += 1
                # skip the line if this was the second blank line
                if($ConsecutiveBlankLinesCount -gt 1)
                {      
                    # decrement now that we are skipping the line
                    $ConsecutiveBlankLinesCount -= 1
                    continue;
                }
            }
            
        }
        # we replace DIV tags with ``` - try to target just single lines with only a DIV tag (start/end tag)
        if($Line.Trim() -like "<*DIV>")
        {
            # if already in a code block we are no longer
            $InCodeBlock = -not $InCodeBlock
            # remove last occurence of \
            $Line = $Line -replace "<DIV>", '```' -replace "</DIV>", '```'
        }

        if(-not $SkipLine)
        {
            $NewContent += $Line
        }
        $SkipLine = $false
    }
    # the weird empty codeblock is always?? in the end of the doc (was an empty DIV block)
    if($NewContent[-1] -eq '```' -and $NewContent[-2] -eq '```')
    {
        $NewContent = $NewContent[0..($NewContent.Length-3)]
    }
    # add some advertising for this script
    $NewContent += $AdvBlock
    $NewContent | Out-File -FilePath $FilePath -Encoding utf8
}
A script is worth a thousand words, right?

```
<#
I use Out-GridView (alias: ogv) alot for interactively selecting objects. Also sometimes I need some extra information not
described in the object itself.
Let's say we need to enumerate files in c:\temp for a list of computers. After collecting all the files we wish to use ogv
for displaying some of the properties like the name of the file, the size in kb and the computer on which the file is found.
We will pretend (because this is an example anyone can run) that the file object is missing the last part, hence we add it
to the object using Add-Member
another usecase is simply that ogv will not show the properties we wish to see. Using Select-Object will create a new object
and if we use the -Passthru parameter to ogv it will not be the original object we get. In below example we convert the size
of each file to kb, which also uses Select-Object and a calculated property to do the conversion
#>
$ComputerNames = @($env:COMPUTERNAME)
$FilesInTemp = @()
foreach($ComputerName in $ComputerNames)
{
$FilesInTemp += Invoke-Command -ScriptBlock {
Get-ChildItem -Path c:\temp -File
} -ComputerName $ComputerName | `
Add-Member -Name MachineName -Value $ComputerName -MemberType NoteProperty -PassThru
}
# Now we have a list of files that we can select from, but below fails
$FilesInTemp |  Select-Object -Property Name, @{ Name = 'SizeInKb'; Expression = {  $_.Length/1KB }}, MachineName | `
Out-GridView -Title "Select files to delete (example 1)" -PassThru | `
Remove-Item -WhatIf
<#
the problem is that Select-Object creates a new object with just the selected properties. Why Select-Object? Try running
the line below
#>
Get-ChildItem -Path c:\temp -File | Out-GridView
<#
we did get some decent properties, but it is showing the same we would get from a Format-Table, ie. the default properties
if we want something different we use Select-Object, but as mentioned we get an entirely new object (with just the properties
selected) , which is why Remove-Item fails
A solution which can be applied in probably every case is found below
The only difference is that we add the object to itself as a member and then later "extract" it before the pipe to Remove-Item
#>
$FilesInTemp = @()
foreach($ComputerName in $ComputerNames)
{
$FilesInTemp += Invoke-Command -ScriptBlock {
Get-ChildItem -Path c:\temp -File
} -ComputerName $ComputerName | `
Add-Member -Name MachineName -Value $ComputerName -MemberType NoteProperty -PassThru | `
ForEach-Object {$_ | Add-Member -Name _self -Value $_ -MemberType NoteProperty -PassThru}
}
$FilesInTemp | Select-Object -Property Name, @{ Name = 'SizeInKb'; Expression = {  $_.Length/1KB }}, MachineName, _self | `
Out-GridView -Title "Select files to delete (example 2)" -PassThru | `
Select-Object -ExpandProperty _self | `
Remove-Item -WhatIf
<#
We can make this even easier with some helper functions. Below I have used _self as the property name. Some may recognize
the name as used in Python, and equivalent of "this" in C#
#>
Function Add-Self
{
process
{
ForEach-Object {$_ | Add-Member -Name '_self' -Value $_ -MemberType NoteProperty -PassThru}
}
}
Function Get-Self
{
process
{
$_ | Select-Object -ExpandProperty '_self'
}
}
$FilesInTemp = @()
foreach($ComputerName in $ComputerNames)
{
$FilesInTemp += Invoke-Command -ScriptBlock {
Get-ChildItem -Path c:\temp -File
} -ComputerName $ComputerName | `
Add-Member -Name MachineName -Value $ComputerName -MemberType NoteProperty -PassThru | `
Add-Self
}
$FilesInTemp | Select-Object -Property Name, @{ Name = 'SizeInKb'; Expression = {  $_.Length/1KB }}, MachineName, _self | `
Out-GridView -Title "Select files to delete (example 3)" -PassThru | `
Get-Self | `
Remove-Item -WhatIf
```
```
```

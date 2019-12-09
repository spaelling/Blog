I had some trouble with a custom script extension where the script
required a SAS token to download some software. The token was simply
truncated after the first \'&\'.

After some digging I thought I had to put the SAS token into quotes, and
when looking
into *C:\\Packages\\Plugins\\Microsoft.Compute.CustomScriptExtension\\1.8\\RuntimeSettings\\0.settings*
I found that it was a sensible solution. I could also copy the
\"*commandToExecute*\" and run it and get the expected result. In the
variables section I added a:
```
"variables": {
"singlequote": "'",
```
And then put single quotes around the *parameters(\'SASToken\')*. But no
dice. The token was still getting truncated, this time with a \'in
front\...
So I decided to get rid of the \'&\', at least temporarily. base64
encoding to the rescue. And Luckily there is an ARM template function
for [just
that](https://azure.microsoft.com/en-us/documentation/articles/resource-group-template-functions/#base64).
In the script I then added:
```
$SASToken = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($SASToken))
```
Problem solved!
Seems to me that there is something odd in how the custom script
extension calls PowerShell in this particular instance.

**Converted from html using [convert.ps1](https://github.com/spaelling/Blog/blob/master/convert.ps1)**


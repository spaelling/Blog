I needed a list of public IPs in Azure that was attached to a virtual
network interface. PowerShell to the rescue.

```
(Get-AzureRmPublicIpAddress | Where-Object {$_.PublicIpAllocationMethod -eq 'Static' -and $_.IpC
onfiguration.Id -like '*Microsoft.Network/networkinterfaces*'} | Select-Object -ExpandProperty IpAddress | ForEach-Objec
t {"$_,"}) -join '' | clip
```
```
```

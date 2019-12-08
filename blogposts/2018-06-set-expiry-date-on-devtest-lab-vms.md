A colleague of mine recently handed me the script
from <https://github.com/Azure-Samples/virtual-machines-powershell-auto-expired/>
and asked for my help with what he thought was a permission issue.\
The script is 2 years old, so things have changed quite a bit since, but
it is just not very clever as it fetches all resources in an entire
subscription (something this colleague did not have permission to do),
which by all means is a bad idea.\
\
I made some improvements and wanted to share. Below is simply run and
you are prompted to select a lab, then one or more VMs in that lab, and
finally in how many days the VMs should expire.\
\
Note that I will not be updating below with fixes so grab it from
Technet [here](http://noteuploadedyet/).\
\
\
\

<div>

    # you can remove the TenantId if you have just a single tenant
    $TenantId = ''
    Select-AzureRmSubscription -TenantId $TenantId -SubscriptionId '' | Out-Null
    Function Set-AzureVirtualMachineExpiredDate 
    { 
        [CmdletBinding()] 
        Param 
        ( 
            [Parameter(Mandatory=$true, ValueFromPipeline, Position=1)][ValidateNotNull()][String]$VMName, 
            [Parameter(Mandatory=$true)][ValidateNotNull()][String]$LabName, 
            [Parameter(Mandatory=$true)][ValidateNotNull()][String]$LabResourceGroupName,
            [Parameter(Mandatory=$true)][ValidateNotNull()][DateTime]$ExpiredUTCDate 
        ) 
     
        Begin{
            $Jobs = @()
        }

        Process
        {
            try {
                # get vm info 
                $targetVMInfo = Get-AzureRmResource -ResourceName "$LabName/$VMName" -ResourceGroupName $LabResourceGroupName `
                                                    -ResourceType 'Microsoft.DevTestLab/labs/virtualMachines' -ExpandProperties
            }
            catch {
                Throw "$VMName not found in $LabName, error was:`n$_" 
            }
         
            # get vm properties 
            $vmProperties = $targetVMInfo.Properties 
         
            # set expired date
            $vmProperties | Add-Member -MemberType NoteProperty -Name expirationDate -Value $ExpiredUTCDate -Force 
            
            Write-Host "Setting expiry date to $ExpiredUTCDate on $LabName/$VMName..."
            $Jobs += Set-AzureRmResource -ResourceId $targetVMInfo.ResourceId -Properties $vmProperties -Force `
                        -ErrorAction Stop -AsJob
        } # end of process

        End
        {
            Write-Host "Waiting for jobs to complete..."
            $Jobs | Wait-Job | Receive-Job | ForEach-Object {
                Write-Host "Expiry date on $($_.Name) set to $($_.Properties.expirationDate)"
            }
        }
    } 

    $Lab = Get-AzureRmResource -ResourceType 'Microsoft.DevTestLab/labs' | Out-GridView -Title "Select DevTest Lab" -PassThru
    $LabName = $Lab | Select-Object -ExpandProperty Name

    $VM = Get-AzureRmResource -ResourceName "$LabName/*" -ResourceType 'Microsoft.DevTestLab/labs/virtualMachines' | `
            Out-GridView -Title "Select VM" -PassThru

    $AddDays = 1..14 | Out-GridView -Title "Expire in days..." -PassThru

    $VM | ForEach-Object {("$($_.Name)".Split('/') | Select-Object -Last 1)} | Set-AzureVirtualMachineExpiredDate `
                                        -LabName $LabName `
                                        -LabResourceGroupName $Lab.ResourceGroupName `
                                        -ExpiredUTCDate (Get-Date).AddDays($AddDays)

</div>

<div>

</div>

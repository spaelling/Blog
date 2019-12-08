I recently had some storage issues in the company lab which meant that
after a lengthy CHKDSK that permission on all VHDX files was lost. The
solution was luckily simple: Reattach each drive and the permission on
the file was restored. Problem was then that there was more than 50
drives all in all. Solution then became, as it often is, do it with
Powershell.

The script as follows ([Download from
Technet](https://gallery.technet.microsoft.com/Reattaching-Drives-on-VMs-3b038909)),
formatted using <https://tohtml.com/powershell/>:
    $States = ( [Microsoft.HyperV.PowerShell.VMState]::Off, 
                [Microsoft.HyperV.PowerShell.VMState]::OffCritical
              )
    $VMs = Get-VM | ? {$_.State -in $States}
    $DriveCount = ($VMs | Get-VMHardDiskDrive).Count
    $Counter = 0
    foreach($VM in $VMs)
    {
        $Drives = $VM | Get-VMHardDiskDrive
        foreach($Drive in $Drives)
        {
            $Counter += 1
            # Some of these values (Path at least) disappear from the $Drive object when we remove it from the machine
            $ControllerNumber = $Drive.ControllerNumber
            $ControllerLocation = $Drive.ControllerLocation
            $Path = $Drive.Path
            $SupportPersistentReservations = $Drive.SupportPersistentReservations
            $ControllerType = $Drive.ControllerType
            Write-Progress  -Activity "Reattaching drives" `
                            -Status "Removing $Path from $($VM.Name)" `
                            -PercentComplete (100*$Counter/$DriveCount) 
            Remove-VMHardDiskDrive -VMHardDiskDrive $Drive
            if($SupportPersistentReservations)
            {
                # Shared vhdx
                Add-VMHardDiskDrive -VM $VM `
                                    -ControllerNumber $ControllerNumber `
                                    -ControllerLocation $ControllerLocation `
                                    -Path $Path `
                                    -ControllerType $ControllerType `
                                    -SupportPersistentReservations
            }
            else
            {
                            Add-VMHardDiskDrive -VM $VM `
                                    -ControllerNumber $ControllerNumber `
                                    -ControllerLocation $ControllerLocation `
                                    -Path $Path `
                                    -ControllerType $ControllerType
            }
            Write-Progress  -Activity "Reattaching drives" `
                            -Status "Reattached $Path to $($VM.Name)" `
                            -PercentComplete (100*$Counter/$DriveCount)
        }
    }
```
```

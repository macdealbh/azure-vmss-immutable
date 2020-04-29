Param (
    $clusterName,
    $clusterResourceGroupName
)

$upgradeCluster = Get-AzVmss -VMScaleSetName $clusterName -ResourceGroupName $clusterResourceGroupName
$initialInstanceCount = $upgradeCluster.sku.capacity
$existingInstances = Get-AzVmssVM -VMScaleSetName $upgradeCluster.Name -ResourceGroupName $upgradeCluster.ResourceGroupName


function Update-ScaleSetScale {
    Param (
        $vmssInstanceCount,
        $vmssName,
        $vmssResourceGroup
    )
    
    Write-Host "Scaling VMSS $vmssName to $vmssInstanceCount instances..."

    Update-AzVmss `
        -VMScaleSetName $vmssName `
        -ResourceGroupName $vmssResourceGroup `
        -SkuCapacity $vmssInstanceCount
}

function Set-ScaleSetInstanceProtection {
    Param (
        $existingInstances,
        $upgradeCluster,
        $protectInstances
    )
    
    

    foreach ($instance in $existingInstances) {
        if ($protectInstances -eq $false -and $null -ne $instance.ProtectionPolicy) {
            $protectionList.add($instance)
        }
        elseif ($protectInstances -eq $true -and $instance.LatestModelApplied -eq $true) {
            $protectionList.add($instance)
        }
        else {
            continue
        }

        
        Update-AzVmssVM `
            -VMScaleSetName $upgradeCluster.name `
            -ResourceGroupName $upgradeCluster.ResourceGroupName `
            -InstanceId $instance.InstanceId `
            -ProtectFromScaleIn $protectInstances
    }
}

Update-ScaleSetScale -vmssInstanceCount ($initialInstanceCont * 2) -vmssName $upgradeCluster.Name -vmssResourceGroup $upgradeCluster.ResourceGroupName
Set-ScaleSetInstanceProtection -existingInstances $existingInstances -upgradeCluster $upgradeCluster -protectInstances $true
Update-ScaleSetScale -vmssInstanceCount $initialInstanceCount -vmssName $upgradeCluster.Name -vmssResourceGroup $upgradeCluster.ResrouceGroupName
Set-ScaleSetInstanceProtection -existingInstances $existingInstances -protectInstances $false -upgradeCluster $upgradeCluster
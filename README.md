# Description

This repo provides a draft PowerShell script that is used to perform an immutable upgrade to an existing Azure Virtual Machine Scale Set (VMSS). The specific use case is if you are running an Azure VMSS and wish to perform an update in an immutable, no changes to existing nodes only updating with new compute resources, manner.


The basic functioning process is when started the script will
1. retrieve the existing VMSS and its instances
2. Update VMSS scale to be double the instances (If 5 exist, 5 more will be created for a total of 10)
3. Once new instances are created the new instanes that are up to date with current VMSS settings with have protection enabled to prevent their removal during scale in
4. Update VMSS setting to scale down to half the number of existing instances (The goal being to return to the original number of instances). This will cause the original nodes that are not up to date and do not have protection enabled to be deleted leaving a VMSS of the original scale size but with instances that are using current desired configuration
5. Remove instance protection from the remaining up-to-date instances.
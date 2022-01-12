#!/bin/bash

#https://www.tecmint.com/manage-and-create-lvm-parition-using-vgcreate-lvcreate-and-lvextend/
#This may not however be the case for you, to avoid reboot you may need to rescan your devices, you can try this with the below command. Note that you may need to change host0 depending on your setup.
echo "- - -" > /sys/class/scsi_host/host0/scan
#If you have issues detecting the new disk, just perform a reboot and it should then display correctly.


# How to increase disk size of root partation.
#Step 1: Add new partition
fdisk -l
# fdisk /dev/sda
In the fdisk command prompt,

#Step 2: Reboot the Virtual Machine and Initialize LVM
Enter n to create a new partition.
Enter p to create primary partition.
Press ENTER to accept default for first sector.
Press ENTER to accept default for Last sector. This will create a partition with all the remaining available space on the disk. Alternatively you could specify the size, for example +2G will add a partition of size 2GB.
Enter t to set the type of the new partition to Linux LVM.
Select partition number 3.
Enter 8e as the Hex code.
Finally enter the command w to save the changes to disk and exit fdisk.

pvcreate /dev/sda3

#Step 3: Add partition to volume group
vgextend centos /dev/sda3

#Step 4: Extend the root logical volume

#Extend the logical volume and resize to filesystem.
lvextend --size +2G --resizefs /dev/centos/root

#Step 5: Verify disk size.
#To verify the size of root volume, run
df -h 

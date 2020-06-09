#!/bin/bash

vgs

read -p "Choose a VG to create on: " BASEVG
read -p "Enter mount point: " MNTPNT
read -p "Enter size: " LVSIZE
read -p "Add to fstab (y\\n)? " FSTAB
# Checking OS Version to determine what FS type to use
if [ `lsb_release -d | grep 7 | wc -l` -eq 1 ] ; then	
	FSTYPE=xfs
elif [ `lsb_release -d | grep 6 | wc -l` -eq 1 ] ; then
	FSTYPE=ext4
else
	echo "Error: Could not determine OS version!"
	exit 1
fi
# Attempting to create mount point
if [ -d $MNTPNT ] ; then
	echo "Error: Path already exists!"
	exit 1
else 
	mkdir -p $MNTPNT
	echo "Path $MNTPNT created..."
# Creating LV
	lvcreate -L $LVSIZE $BASEVG > /dev/null
	if [ $? -eq 0 ] ; then
		echo "Logical volume created on $BASEVG..."
	else 
		echo "Error: Could not create Logical Volume!"
		exit 1
	fi
	NEWLV=`lvs | tail -n 1 | awk '{print $1}'`
# Creating FS
	if [ $FSTYPE == "xfs" ] ; then
		mkfs.xfs /dev/$BASEVG/$NEWLV > /dev/null
	else
		mkfs.ext4 /dev/$BASEVG/$NEWLV > /dev/null
	fi
	
	if [ $? -eq 0 ] ; then
		echo "$FSTYPE File system created on $NEWLV..."
	else
		echo "Error: Could not create file system!"
		exit 1
	fi
# Mounting the logical volume
	mount /dev/$BASEVG/$NEWLV $MNTPNT > /dev/null
	if [ $? -eq 0 ] ; then 
		echo "$MNTPNT mounted on $NEWLV..."
	else
		echo "Error: Could not mount $MNTPNT on $NEWLV!"
	fi
# Changing fstab if required
	if [ $FSTAB == "y" ] ; then
		echo -e "/dev/$BASEVG/$NEWLV\t$MNTPNT\t$FSTYPE\tdefaults\t0 0" >> /etc/fstab
		mount -a > /dev/null
		if [ $? -eq 0 ] ; then
			echo "Added mount point to fstab..."
		else
			echo "Error: fstab file not valid!"
			exit 1
		fi
	fi
	
	echo "Done!"
fi




























#!/bin/bash
#@author Ben Cardoen
#Remote mounts Cedar home drive

# Uncomment if you need to jump between systems
#JUMP="-o ssh_command='ssh -J <you>@<intermediate_host>'"
REMOTE="solar.cs.sfu.ca"
#Change if your user id is different
REMOTEUSER=$USER
#Change to a different mount point
MOUNTPOINT="/home/bcardoen/solar"
OPTIONS="-C -o follow_symlinks -o cache=yes -o reconnect -o cache_timeout=300 -o kernel_cache"
# If you need to jump
# OPTIONS='-C -o ssh_command='''ssh -J <you>@<intermediate>''

#Unmount Linux
UMOUNTCMD="fusermount3 -u $MOUNTPOINT"
#Unmount OSX
#UMOUNTCMD="umount $MOUNTPOINT"

echo "Mounting remote file systems @ $REMOTE to $MOUNTPOINT ... with options $OPTIONS"
sshfs $REMOTE:/home/$REMOTEUSER $MOUNTPOINT $OPTIONS
if [ $? -eq 0 ]; then
	echo "Mount succesfull"
else
	echo "Mount failed"
	echo "Trying umount to resolve old mounts ..."
	$UMOUNTCMD
	if [ $? -eq 0 ]; then
		echo "Force unmount successful, trying to mount again ..."
		sshfs $REMOTE:/home/$REMOTEUSER $MOUNTPOINT $OPTIONS
		if [ $? -eq 0 ]; then
			echo "... Mount successful"
		else
			echo "... Failed, giving up...."
		fi
	else
		echo "... Force unmount failed, giving up"
	fi
fi
echo "Done"

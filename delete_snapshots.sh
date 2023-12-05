#!/bin/bash

PROFILE="prod2"
AMI_IDS=$(aws ec2 describe-images --owners self --filters "Name=description,Values=*CHN*,*Patchin*" --query 'Images[*].[ImageId]' --profile $PROFILE --output text)

for AMI_ID in $AMI_IDS; do
	echo $AMI_ID
	SNAPSHOT_IDS=$(aws ec2 describe-images --image-ids $AMI_ID --query 'Images[].BlockDeviceMappings[].Ebs.SnapshotId' --profile $PROFILE --output text | tr "\t" "\n")
	for SNAPSHOT_ID in $SNAPSHOT_IDS; do
		read -p "Do you want to deregister AMI $AMI_ID? (y/n): " CONFIRM_DEREGISTER
		if [ "$CONFIRM_DEREGISTER" == "y" ]; then
			echo "Deregistering AMI: $AMI_ID"
			aws ec2 deregister-image --image-id $AMI_ID --profile $PROFILE
		else
			echo "Skipping deregistration of AMI: $AMI_ID"
		fi
		#Ask for confirmation before deleting each snapshot
		read -p "Do you want to delete snapshot $SNAPSHOT_ID? (y/n): " CONFIRM
		if [ "$CONFIRM" == "y" ]; then
			echo "Deleting Snapshot: $SNAPSHOT_ID"
			aws ec2 delete-snapshot --snapshot-id $SNAPSHOT_ID --profile $PROFILE
		else
			echo "Skipping deletion of Snapshot: $SNAPSHOT_ID"
		fi
	done
done

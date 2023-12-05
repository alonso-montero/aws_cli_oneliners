#!/bin/bash

PROFILE="prod1"
AMI_IDS=$(aws ec2 describe-images --owners self --filters "Name=description,Values=*CHN*,*Patchin*" --query 'Images[*].[ImageId]' --profile $PROFILE --output text)

for AMI_ID in $AMI_IDS; do
	echo $AMI_ID
	SNAPSHOT_IDS=$(aws ec2 describe-images --image-ids $AMI_ID --query 'Images[].BlockDeviceMappings[].Ebs.SnapshotId' --profile $PROFILE --output text | tr "\t" "\n")
	echo $SNAPSHOT_IDS
done

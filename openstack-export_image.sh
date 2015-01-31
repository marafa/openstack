#!/bin/sh
#requires 2 variables
#1. user name
#2. instance name
echo -n "Q: Provide a user name with access to the instance: "
read user

if [ -f ~/keystonerc/keystonerc_$user ] 
then 
	source ~/keystonerc/keystonerc_$user
else
	echo "FAIL: ~/keystonerc_$user not found!"
	exit 2
fi

echo -n "Q: Instance name: "
read instance

instance_id=`nova list |grep $instance |awk '{print $2}'`
if [ "$instance_id" == "" ]
then
	echo "FAIL: $instance not found!"
	exit 1
fi

echo " INFO: Stopping instance $instance_id"
nova stop $instance_id

nova list #verify instance is in SHUTOFF state

echo " INFO: Snapshoting instance $instance_id"
nova image-create --poll $instance $instance.snapshot
if [ $? -eq 0 ]
then
  snapshot_id=`nova image-list |grep $instance.snapshot |awk '{print $2}'`
  echo " INFO: Exporting $instance" 
  glance image-download --file $instance.raw $snapshot_id
else
  echo "FAIL: something went wrong!"
fi

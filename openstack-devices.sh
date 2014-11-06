#!/bin/sh

# 
debug(){

echo -----debug	-----
echo files $files 
echo file $file 
echo nics $nics
echo nic $nic
echo device $device
echo DEVICE=$DEVICE
echo IPADDR=$IPADDR
echo HWADDR=$HWADDR
echo GATEWAY=$GATEWAY
echo DNS1=$DNS1
echo DNS2=$DNS2
echo result=$result
echo -----debug	-----
}

if [ -f /etc/sysconfig/network-scripts/ifcfg-br-ex ]
then
	echo /etc/sysconfig/network-scripts/ifcfg-br-ex exists. Quitting!
	exit 0
fi

	nics=`ls /etc/sysconfig/network-scripts/ifcfg-* |grep -v lo |wc -l`
	if [ $nics -gt 1 ]
	then
		files=`ls /etc/sysconfig/network-scripts/ifcfg-* |grep -v lo`
		PS3="Select primary network interface: "
		select nic in $files quit
		do
		case nic in 
		quit)
			echo quitting
			exit 1
		;;
		*)
			nic=`basename $nic`
			file=/etc/sysconfig/network-scripts/$nic
#debug
		;;
		esac
		break
		done
	else
		file=`ls /etc/sysconfig/network-scripts/ifcfg-* |grep -v lo`
	fi
	mkdir -p ~/backups
	cp -n $file ~/backups/.
	cp -n ~/backups/$nic /etc/sysconfig/network-scripts/ifcfg-br-ex
	device=`basename $file`
	IPADDR=`grep IPADDR ~/backups/$nic|cut -d= -f2`	
	GATEWAY=`grep GATEWAY ~/backups/$nic|cut -d= -f2`
	DNS1=`grep DNS1 ~/backups/$nic|cut -d= -f2`
	DNS2=`grep DNS2 ~/backups/$nic|cut -d= -f2`

##configuration of $device
DEVICE=`echo $nic|cut -d- -f2`
HWADDR=`cat ~/backups/$nic|grep HWADDR|cut -d= -f2`
rm -rf $file
cat >> $file << EOF
DEVICE=$DEVICE
HWADDR=$HWADDR
TYPE=Ethernet
ONBOOT=yes
EOF

##configuration of br-ex
file=/etc/sysconfig/network-scripts/ifcfg-br-ex
rm -rf $file
cat >> $file <<EOF
DEVICE=br-ex
IPADDR=$IPADDR
NETMASK=255.255.255.0
GATEWAY=$GATEWAY
DNS1=$DNS1
DNS2=$DNS2
HOSTNAME=`hostname`
ONBOOT=yes
EOF

##configuration of ovs
ovs-vsctl show |grep $device > /dev/null
result=$?
if ! [ $result -eq 0 ]
then
	ovs-vsctl add-port br-ex $device
	service network restart
fi

#debug

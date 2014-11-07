#!/bin/sh

# 
debug(){

echo -----debug	-----
echo files $files 
echo file $file 
echo num_nics $num_nics
echo nic $nic
echo device=$device
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

#number of nics on the server
num_nics=`ls /etc/sysconfig/network-scripts/ifcfg-* |grep -v lo |wc -l`
if [ $num_nics -gt 1 ] 
then
	files=`ls /etc/sysconfig/network-scripts/ifcfg-* |grep -v lo`
	PS3="Select primary network interface: "
	select file in $files quit
	do
	case file in 
	quit)
		echo Quitting
		exit 1
	;;
	*)
		nic=`basename $file|cut -d- -f2`
		file=/etc/sysconfig/network-scripts/ifcfg-$nic
	;;
	esac
	break
	done
else
	file=`ls /etc/sysconfig/network-scripts/ifcfg-* |grep -v lo`
fi

primary(){
mkdir -p ~/backups
cp -n $file ~/backups/.
device=`basename $file`
nic=`basename $device|cut -d- -f2`
IPADDR=`grep IPADDR ~/backups/$device|cut -d= -f2`	
GATEWAY=`grep GATEWAY ~/backups/$device|cut -d= -f2`
DNS1=`grep DNS1 ~/backups/$device|cut -d= -f2`
DNS2=`grep DNS2 ~/backups/$device|cut -d= -f2`

##configuration of $device
DEVICE=`echo $nic|cut -d- -f2`
HWADDR=`cat ~/backups/$device|grep HWADDR|cut -d= -f2`
rm -rf $file
cat >> $file << EOF
DEVICE=$DEVICE
HWADDR=$HWADDR
TYPE=Ethernet
ONBOOT=yes
EOF
}

br_ext(){
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
}

ovs(){
##configuration of ovs
ovs-vsctl show |grep $nic > /dev/null
result=$?
if ! [ $result -eq 0 ]
then
	ovs-vsctl add-port br-ex $nic
	service network restart
fi
}

primary #primary nic aka eth0
br_ext  #bridge for external connectivity
ovs	#ovs configuration

#debug


#!/bin/sh

source /root/keystonerc_admin

now=`date +%Y%m%d%H%M`
device=eth0
vlan=192.168.0
start=$vlan.150
end=$vlan.200
gw=$vlan.1
dns1=4.2.2.2
dns2=
dns3=
hwaddr=`cat /etc/udev/rules.d/70-persistent-net.rules | grep $device | cut -d, -f4 | sed 's/ ATTR{address}=="//g' | sed 's/"//g'`
IP=`ifconfig $device|grep -w inet|awk '{print $2}'|cut -d: -f2`
domain=marafa.vm

public_network(){
neutron router-create PublicRouter
neutron net-create --tenant-id services PublicLAN --router:external=True
neutron subnet-create --tenant-id services --allocation-pool start=$start,end=$end --gateway=$gw --disable-dhcp --name PublicSubnet PublicLAN $vlan.0/24
neutron router-gateway-set PublicRouter PublicLAN
}

##determine one physical nic or more
##if one nic move ip from nic to br-ex in /etc/sysconfig/network-scripts
device_exist(){
ifconfig $device > /dev/null  2>&1
if ! [ $? -eq 0 ]
then
	echo " ERROR: $device not found"
	exit 1
fi
if [ -f /etc/sysconfig/network-scripts/ifcfg-br-ex ]
then
	echo " ERROR: br-ex already configured! Rerunning?"
	exit 1
fi
}

device_primary(){
cat >> /etc/sysconfig/network-scripts/ifcfg-$device << EOF
DEVICE=$device
HWADDR=$hwaddr
ONBOOT=yes
#TYPE=OVSPort
#DEVICETYPE=ovs
#OVS_BRIDGE=br-ex
EOF
}

device_bridge(){
cat >> /etc/sysconfig/network-scripts/ifcfg-br-ex << EOF
DEVICE=br-ex
IPADDR=$IP
PREFIX=24
GATEWAY=$gw 
DNS1=$dns1
DNS2=$dns2
DNS3=$dns3
SEARCH=$domain
ONBOOT=yes
#DEVICETYPE=ovs
#TYPE=OVSBridge
#BOOTPROTO=static
#NETMASK=255.255.255.0 
EOF
}

backup(){
mv /etc/sysconfig/network-scripts/ifcfg-$device /root/ifcfg-$device.$now
}

ovs(){ #open vswitch
ovs-vsctl add-port br-ex $device; service network restart
}

check(){
if [ -f /etc/sysconfig/network-scripts/ifcfg-br-ex ]
then
	echo " WARN: /etc/sysconfig/network-scripts/ifcfg-br-ex exist. Was `basename $0` previously run?"
	exit 1
fi
}

###MAIN
check
device_exist
backup
device_primary
device_bridge
ovs
#public_network

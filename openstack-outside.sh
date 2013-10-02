#!/bin/sh

device=eth0
vlan=192.168.0
start=$vlan.129
end=$vlan.163
gw=$vlan.1
dns1=4.2.2.2
dns2=
hwaddr=`cat /etc/udev/rules.d/70-persistent-net.rules | grep $device | cut -d, -f4 | sed 's/ ATTR{address}=="0//g' | sed 's/"//g'`

###before
ifconfig > /tmp/before.log
ip netns >> /tmp/before.log

neutron router-create PublicRouter
neutron net-create PublicLAN --router:external=True
neutron subnet-create PublicLAN $vlan/24 --name PublicLAN --enable_dhcp=False --allocation-pool start=$start,end=$start --gateway=$gw --dns_nameservers list=true $dns1 $dns2
neutron router-gateway-set PublicRouter PublicLAN

##determine one physical nic or more

##if one nic move ip from nic to br-ex in /etc/sysconfig/network-scripts

ifconfig $device > /dev/null  2>&1
if ! [ $? -eq 0 ]
then
	echo " ERROR: $device not found"
	exit 1
fi

cp /etc/sysconfig/network-scripts/ifcfg-$device /root/ifcfg-$device
cat >> /etc/sysconfig/network-scripts/ifcfg-$device << EOF
DEVICE=$device
HWADDR=$hwaddr
TYPE=OVSPort
DEVICETYPE=ovs
OVS_BRIDGE=br-ex
ONBOOT=yes
EOF

###after
cat >> /etc/sysconfig/network-scripts/ifcfg-br-ex << EOF
DEVICE=br-ex
DEVICETYPE=ovs
TYPE=OVSBridge
BOOTPROTO=static
IPADDR=$IP
NETMASK=255.255.255.0 
GATEWAY=$gw 
DNS1=$dns1
DNS2=$dns2
DNS3=$dns3
ONBOOT=yes
EOF

ifconfig > /tmp/after.log
ip netns >> /tmp/after.log

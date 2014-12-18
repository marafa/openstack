#!/bin/sh
#creates a public network and subnet for our internal vlan

neutron net-list |grep public > /dev/null
if [ $? -eq 0 ]
then
	echo " ERROR: Public network found. Quitting"
	exit 1
fi

##allocation pool
start=192.168.0.101
end=192.168.0.200
###
GATEWAY=`grep GATEWAY /etc/sysconfig/network-scripts/ifcfg-br-ex|cut -d= -f2`
network=`echo $GATEWAY | cut -d. -f1,2,3`
network=`echo $network.0/24`

neutron net-create --tenant-id demo public --router:external=True
neutron subnet-create --tenant-id demo --allocation-pool start=$start,end=$end --gateway=$GATEWAY --disable-dhcp --name external public $network

##switch to demo user
demo(){ 
source /root/keystonerc_demo
private_subnet=`neutron subnet-list | grep -i private|awk '{print $2}'`
neutron router-show router1 > /dev/null 2>&1 #assuming our router isnt there
if ! [ $? -eq 0 ]
then
        neutron router-create router1
        neutron router-gateway-set router1 public
else
	echo " ERROR: Router router1 found!"
	exit 2
fi

neutron net-create private 
neutron subnet-create private 10.0.0.0/24 --name internal --dns_nameservers list=true 8.8.8.8 8.8.8.7 --gateway 10.0.0.1

neutron router-interface-add router1 internal
}

if ! [ -z /root/keystonerc_demo ] 
then
	demo
else
	echo " ERROR: demo user not found!"
	exit 3
fi
#end demo user

source /root/keystonerc_admin

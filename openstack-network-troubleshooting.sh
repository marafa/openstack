#!/bin/sh

#this is a script that collects information to aid in troubleshooting efforts

source /root/keystonerc_admin

echo ---Redhat Release---
cat /etc/redhat-release

echo ---Repositories---
yum repolist

if [ -f /usr/bin/quantum ]
then
	alias neutron=quantum
fi

echo "---Packages Installed---"
rpm -qa | grep -iE "neutron|nova-network|openstack*" | sort
echo 

for device in `ls /etc/sysconfig/network-scripts/ifcfg-*`
do
	echo "---Device config for $device---"
	cat $device
	echo 
done
echo "---Ifconfig---"
ifconfig
echo 

echo "-- Devices --"
ip addr
echo

echo "---Routes----"
route -n
echo 
echo ---Open vSwitch---
ovs-vsctl show
echo 
echo ---Flows ---
for bridge in `ovs-dpctl show | grep '\:\s.*\(internal\)' | awk '{print $3}'`; do  echo "-- $bridge Flows --"; ovs-ofctl dump-flows $bridge; done
echo

echo ---Network Namespaces---
ip netns
echo 

echo ---Neutron devices---
neutron router-list
for router in `neutron router-list|grep -v "id"|awk '{print $2}'`; do neutron router-show $router; done
echo 
neutron net-list
for net in `neutron net-list|grep -v "id"| awk '{print $2}'`; do neutron net-show $net; done
echo 
neutron subnet-list
for subnet in `neutron subnet-list|grep -v "id"|awk '{print $2}'`; do neutron subnet-show $subnet; done
echo 

echo ---Name resolution---
cat /etc/resolv.conf
cat /etc/hosts

echo ---OpenStack status---
/usr/bin/openstack-status

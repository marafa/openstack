#!/bin/sh

#this is a script that collects information to aid in troubleshooting efforts

source /root/keystonerc_admin
if [ -f /usr/bin/quantum ]
then
	alias neutron=quantum
fi

echo "---Packages Installed---"
rpm -qa | grep -iE "neutron|nova-network|openstack*" | sort
echo 

for i in `ls /etc/sysconfig/network-scripts/ifcfg-*`
do
	echo "---Device config for $i---"
	cat $i
	echo 
done
echo "---Ifconfig---"
ifconfig
echo 
echo "---Routes----"
route -n
echo 
echo ---Open vSwitch---
ovs-vsctl show
echo 
echo ---Network Namespaces---
ip netns
echo 

echo ---Neutron devices---
neutron router-list
for i in `neutron router-list|grep -v "id"|awk '{print $2}'`; do neutron router-show $i; done
echo 
neutron net-list
for i in `neutron net-list|grep -v "id"| awk '{print $2}'`; do neutron net-show $i; done
echo 
neutron subnet-list
for i in `neutron subnet-list|grep -v "id"|awk '{print $2}'`; do neutron subnet-show $i; done
echo 

echo ---Name resolution---
cat /etc/resolv.conf
cat /etc/hosts

echo ---OpenStack status---
/usr/bin/openstack-status

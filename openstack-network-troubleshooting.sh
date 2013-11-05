#!/bin/sh

#this is a script that collects information to aid in troubleshooting efforts

source /root/keystonerc_admin
alias quantum=neutron

echo "---Packages Installed---"
rpm -qa | grep -iE "neutron|nova-network|openstack*" | sort

for i in `ls /etc/sysconfig/network-scripts/ifcfg-*`
do
	echo "---Device config for $i---"
	cat $i
done
echo "---Ifconfig---"
ifconfig
echo "---Routes----"
route -n
echo ---Open vSwitch---
ovs-vsctl show
echo ---Network Namespaces---
ip netns

echo ---Neutron devices---
neutron router-list
neutron net-list
neutron subnet-list

echo ---Name resolution---
cat /etc/resolv.conf
cat /etc/hosts

echo ---OpenStack status---
/usr/bin/openstack-status

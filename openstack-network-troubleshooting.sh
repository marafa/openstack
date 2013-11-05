#!/bin/sh

source /root/keystonerc_admin
alias quantum=neutron

rpm -qa | grep -iE "neutron|nova-network|openstack*" | sort

ifconfig
route -n
ls -ltr /etc/sysconfig/network-scripts/ifcfg-*

ip netns

neutron router-list
neutron net-list
neutron subnet-list

cat /etc/resolv.conf
cat /etc/hosts

#!/bin/sh

version=0.3

help(){
	echo " Usage: `basename $0` component"
	echo "	Where component is one of nova, keystone, neutron, openvswitch, horizon, ceilometer, cinder, glance, foreman, puppet, system, httpd"
}

if ! [ -f /usr/bin/multitail ]
then
	echo  ERROR: multitail not found!
	yum install multitail
else
	if [ $# -eq 0 ]
	then
		help
		exit 2
	fi
fi

case $1 in
	nova)
		multitail /var/log/nova/*log
	;;
	keystone)
		multitail /var/log/keystone/*log
	;;
	neutron)
		multitail /var/log/neutron/*log
	;;
	openvswitch)
		multitail /var/log/openvswitch/*log
	;;
	horizon)
		multitail /var/log/horizon/*log
	;;
	ceilometer)
		multitail /var/log/ceilometer/*log
	;;
	cinder)
		multitail /var/log/cinder/*log
	;;
	glance)
		multitail /var/log/glance/*log
	;;
	foreman)
                multitail /var/log/foreman/*log
	;;
	puppet)
                multitail /var/log/puppet/*log
	;;
	system)
		multitail /var/log/{messages,secure}
	;;
	httpd)
		multitail /var/log/httpd/{access,error}_log
	;;
	*)
		help
	;;
esac

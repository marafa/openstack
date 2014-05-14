#!/bin/sh

if [ $# -eq 0 ]
then
	echo " Usage: $0 {warn|error|both}"
	exit 1
fi

case $1 in
	warn|Warn|WARN)
		param=warn
	;;
	err|error|Error|ERROR|ERR)
		param=error
	;;
	both)
		param="warn|error"
	;;
esac

follow(){
multitail -E "$param" --mergeall /var/log/{nova,keystone,neutron,openvswitch,horizon,ceilometer,cinder,glance}/*
}

collect(){
grep -Eri --colour=auto $param /var/log/{nova,keystone,neutron,openvswitch,horizon,ceilometer,cinder,glance}
}

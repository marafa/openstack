#!/bin/sh

if [ $# -eq 0 ]
then
	echo " Usage: $0 {warn|error|both}"
	exit 1
elif [ $# -eq 1 ]
then
	export task="c"
else
	task=$2
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
multitail -E "$param" -Evi "info" --mergeall /var/log/{nova,keystone,neutron,openvswitch,horizon,ceilometer,cinder,glance}/*
}

collect(){
grep -Eri --colour=auto $param /var/log/{nova,keystone,neutron,openvswitch,horizon,ceilometer,cinder,glance}
}

case $task in 
	f)
		follow
	;;
	c)
		collect
	;;
esac


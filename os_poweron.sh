#!/bin/sh

#script to power on instances after a reboot

function="#poweron powreoff"


##names##
mantis="instance-00000008"
spacewalk="instance-0000000a"
zenoss="instance-0000000e"
ipa="instance-00000010"

allvm="mantis spacewalk zenoss ipa"

help(){
echo " Usage: `basename $0` poweron|poweroff instance|all"
echo " 	where \"instance\" is one of $allvm"
}


all(){
for instance in $allvm
do
	virsh $function $instance
done
}

[ $# -eq 0 ] && help

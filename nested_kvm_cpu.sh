#!/bin/sh
#does the cpu support virtualisation?
grep -E "(vmx|svm)" --color=always /proc/cpuinfo > /dev/null
if ! [ $? -eq 0 ]
then
	echo " WARN: Your cpu does not support Virtualisation"
else
	echo " INFO: Your cpu supports Virtualisation"
	#is virtualisation enabled in the bios
	lsmod | grep kvm_intel > /dev/null
	if ! [ $? -eq 0 ]
	then
		echo " WARN: Enable virtualisation in your BIOS"
	else
		#is nested kvm supported?
		modinfo kvm_intel | grep -i nested > /dev/null
		if ! [ $? -eq 0 ]
		then
			echo " WARN: Your cpu does not support nested kvm"
		else
			echo " INFO: Your cpu supports nested kvm"
				enabled=`cat /sys/module/kvm_intel/parameters/nested `
				if [ "$enabled" == "Y" ]
				then
					echo " INFO: Nothing to do. Nested KVM is enabled"
					exit 0
				else
					echo " INFO: Nested KVM is not enabled. Enabling"
					if [ $UID -eq 0 ] 
					then 
						if ! [ -f /etc/modprobe.d/nested_kvm.conf ]
						then
							echo "options kvm-intel nested=y" > /etc/modprobe.d/nested_kvm.conf
						fi
						echo " INFO: Please reboot to enable nested kvm"
					else
						echo " WARN: You need to be root to enable nested kvm"
					fi
				fi
		fi
	fi
fi

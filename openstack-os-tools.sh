#!/bin/sh

config_vnstat(){
if [ -f /usr/bin/vnstat ] 
then
        for int in `vnstat --iflist| sed 's/Available interfaces://'` 
        do 
                echo " INFO: Initialising vnstat db for $int"
                vnstat -u -i $int
        done

        chown vnstat.vnstat  `cat /etc/vnstat.conf | grep DatabaseDir |sed 's/"//g' |awk '{print $2 "/*"}'`

	chkconfig vnstat on
        service vnstat restart
fi
}

install_tools(){
echo if [ -f /etc/yum.repos.d/epel*repo ]
echo then
echo pkg="htop byobu alpine vnstat libpwquality multitail"
echo fi
echo pkg=$pkg
yum install $pkg iotop screen vim-enhanced yum-presto wget vim virt-what
}

install_tools
config_vnstat

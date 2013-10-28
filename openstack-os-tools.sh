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
yum install htop iotop byobu screen alpine vnstat vim-enhanced yum-presto libpwquality wget vim
}

install_tools
config_vnstat

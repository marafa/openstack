#!/bin/sh

today=`date --date "today" +%Y%m%d`

packstack  --gen-answer-file=~/packstack.answer.$today

sed -i 's,CONFIG_SSH_KEY=,CONFIG_SSH_KEY=/root/.ssh/id_rsa.pub,g' ~/packstack.answer.$today
sed -i 's/CONFIG_NTP_SERVERS=/CONFIG_NTP_SERVERS=0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org/g' ~/packstack.answer.$today
sed -i 's/PW=.*/PW=password/g' ~/packstack.answer.$today
sed -i 's/PASSWORD=.*/PASSWORD=password/g' ~/packstack.answer.$today


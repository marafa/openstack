
0.    do a minimal centos install

ssh-keygen -t rsa -N "" -f my.keyssh-keygen -t rsa -N "" -f my.key

yum install -y http://rdo.fedorapeople.org/rdo-release.rpm; yum install -y openstack-packstack yum-presto; yum -y update; reboot

kvm=`virt-what`
if [ "$kvm" == "kvm" ]
then
   yum install -y mongodb-server mongodb
   sed -i '/--smallfiles/!s/OPTIONS=\"/OPTIONS=\"--smallfiles /' /etc/sysconfig/mongod
fi
4.    packstack --allinone --nagios-install=n --mysql-pw=password --ntp-servers=0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org --os-swift-install=y --provision-demo-floatrange=192.168.0.128/25 --keystone-demo-passwd=password

vm 
allinone also installs a demo user 
before setting up a vm set up a network, firewall rules, ssh keys 

- network as DEMO user:

i like to delete the networks made available with the allinone as they are not compatbile with my home network. so go to network topology tab on the left of the demo user''s project panel and delete the public and private networks as well as the router to start fresh.

in the project tab on the left pane, select networks, press the create network button, enter the private network name (eg. demo_net) click on the subnet tab, enter demo_subnet for name and 10.20.30.0/24 . leave the gateway blank. create again, press the create network buton, enter the PUBLIC network name (eg. PublicNet) then public_subnet for the subnet name and YOUR network address eg. if the modem is 192.168.0.1 then put in 192.168.0.0/24. leave DHCP disabled. for the allocation pool pick a range that is sure to be free eg. 192.168.0.100, 192.168.0.200 .. dont leave out the comma. press create 
finally, create the router. call it router1 and set the gateway

now. log out of demo user 
log in as admin user 
go to networks 
click on edit network next to the PublicNet. enable "external network". save 
now log out of admin user

-router 
log in as demo user 
in the project column, click on router and select router1. edit it. 
click external gateway and choose PublicNet. 
click set gateway 
click on router1. 
click add interface. in the subnet menu, select demo_net 10.20.30.0/24 . save.

check your network topology. all 3 should be connected.

-access and security 
- click floating ips. allocate ip 
- click security group tab. create security group. call it demosecgrp or something. make sure you enable port 22 for ssh. save - click keypairs. call it demokey. save to your local box. you might want to transfer it to your host. this demokey.pem is reusable for the project

next , modify variables then run https://raw.github.com/marafa/openstack/master/openstack-outside.sh . also remove /etc/sysconfig/network-scripts/ifcfg-br-ex before running that script.

you are now ready to instantiate your instance

if you need to rerun the installation follwing this syntax
packstack --answer-file=packstack-answers

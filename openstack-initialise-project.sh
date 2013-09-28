#!/bin/sh

if [ $# -eq 0 ]
then
	echo " Usage: `basename $0` Project#"
	exit 2
fi

#variables
	
id=$1
tenant=Tenant #Client
project=Customer
zone=zone #dmz or trust

###begin
create_project(){
keystone tenant-create --name=$project$id --description $tenant$id
}

create_admin_user(){
if ! [ -f /usr/bin/pwmake ]
then 
	echo " WARN: /usr/bin/pwmake requires libpwquality to be installed"
	exit 1
fi
password=`pwmake 4`
keystone user-create --name=c$id --pass=$password --email=admin@localhost --tenant $project$id
echo " INFO: admin user (c$id) for $project$id has password $password"
echo " ToDo: should be emailed instead"
}

assign_role_to_user(){
keystone user-role-add --user c$id --role admin$id --tenant $project$id
}

create_admin_role(){
keystone role-create --name admin$id
}

create_networks(){

neutron router-create router$id
neutron net-create int_lan_$id
cidr=`neutron subnet-list | awk '{print $6}'| grep ^10. | cut -d/ -f1`
neutron subnet-create int_lan_$id 10.0.1.0/24 --name subnet1_$id
neutron router-interface-add router$id subnet1_$id

###attaching a public subnet ###supposedly previously created
#neutron net-create PublicLAN --router:external=True
#neutron subnet-create PublicLAN 192.168.0.0/24 --name PublicLAN --enable_dhcp=False --allocation-pool start=192.168.0.129,end=192.168.0.163 --gateway=192.168.0.1
neutron router-gateway-set router$id PublicLAN
}


###main
create_project
create_admin_role
create_admin_user
assign_role_to_user

create_networks

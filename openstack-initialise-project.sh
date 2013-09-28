#!/bin/sh

if [ $# -eq 0 ]
then
	echo " Usage: `basename $0` Project#"
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
echo " To do: should be emailed instead"
}

assign_admin_to_user(){
keystone user-role-add --user c$id --role admin$id --tenant $project$id
}

create_admin_role(){
keystone role-create --name admin$id
}

###main
create_project
create_admin_role
create_admin_user
assign_admin_to_user

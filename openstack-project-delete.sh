#!/bin/sh

#!set -x
#!read trap debug

if [ $# -eq 0 ]
then
        echo " Usage: `basename $0` Project#"
        exit 2
fi

#variables

id=$1
tenant=Tenant
project=Project
user=user


network_router(){
#neutron floatingip-delete <floatingip-id>
ns=`neutron router-list| grep $id | awk '{print $2}'`
ns=qrouter-$ns
neutron router-gateway-clear router$id
neutron router-interface-delete router$id subnet$id
neutron router-delete router$id
ip netns delete $ns
}

network_net(){
neutron net-delete int_lan_$id
}

network_subnet(){
neutron subnet-delete subnet$id
}

user(){
keystone user-delete $user$id 
}

tenant(){
keystone tenant-delete $project$id
}

role(){
keystone role-delete admin$id
}


network_router
network_net
network_subnet
user
role
tenant

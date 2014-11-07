#!/bin/sh
#deletes the public network

neutron net-list |grep public > /dev/null
if ! [ $? -eq 0 ]
then
        echo "Private net not found. Quitting"
        exit 1
fi

public_id=`neutron net-list |grep public|awk '{print $2}'`
router=`neutron router-list|grep router1 |awk '{print $2}'`
subnet=`neutron router-port-list $router| grep ip_address|awk '{print $8}'| sed 's/"//g'| sed 's/,//'`

neutron router-gateway-clear $router
neutron router-interface-delete $router $public_id
neutron router-interface-delete $router $subnet
neutron router-delete $router
neutron net-delete $public_id

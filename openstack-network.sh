#!/bin/sh

! [ -z openstack-devices.sh ] && openstack-devices.sh
! [ -z openstack-public-delete.sh ] && openstack-public-delete.sh
! [ -z openstack-external-net.sh ] &&  openstack-external-net.sh

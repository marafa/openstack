#!/bin/sh
#downloads images, checks md5sum, adds the image to glance

dir=/root/images.tmp
md5file="`dirname $0`/glance-images.md5sum"

usage(){
	echo " Usage: `basename $0` all centos cirros fedora19"
	echo
	echo " Submit image locations at https://github.com/marafa/openstack"
	exit 1
}

cirros(){
	image=cirros-0.3.0-x86_64-disk.img
	location=https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img
	name="CirrOS 0.3.0"
	images
}

fedora19(){
	location=http://download.fedoraproject.org/pub/fedora/linux/releases/19/Images/x86_64/Fedora-x86_64-19-20130627-sda.qcow2
	image=Fedora-x86_64-19-20130627-sda.qcow2
	name="Fedora 19 x86_64"
	images
}

centos(){
	location=http://mirror.catn.com/pub/catn/images/qcow2/centos6.4-x86_64-gold-master.img
	image=centos6.4-x86_64-gold-master.img 
	name="CentOS 6.4 x86_64"
	images
}

images(){
#echo debug ------
#echo image=$image 
#echo location=$location 
#echo name=$name 
#echo md5sum=$md5file
#echo debug ------

if ! [ -f $md5file ]
then
	echo " ERROR: $md5file not found"
	exit 2
fi

if ! [ -f $dir/$image ]
then 
	wget $location
fi

echo " INFO: Checking md5sum of $image"
md5sum -c $md5file  > file.tmp
grep $image file.tmp | grep OK > /dev/null
rm -rf file.tmp
if [ $? -eq 0 ]
then
	. /root/keystonerc_admin
	glance image-create --name "$name" --disk-format qcow2 --container-format bare --is-public true < $dir/$image
else
	echo " ERROR: Image md5um indicates $image is corrupt"
fi
}

all(){
	cirros
	fedora19
	centos
}

####main

if [ $# -eq 0 ]
then
	usage
fi

if ! [ -d $dir ]
then
	mkdir -p /root/$dir
fi

cd $dir

if [ -f $dir/glance-images.md5sum ]
then
	wget https://raw.github.com/marafa/openstack/master/glance-images.md5sum
fi

case $1 in
	cirros)
		cirros
	;;
	centos)
		centos
	;;
	fedora)
		fedora
	;;
	all)
		all
	;;
	*)
		usage
	;;
esac

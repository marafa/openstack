#!/bin/sh
#downloads images, checks md5sum, adds the image to glance

dir=/root/images.tmp

if [ $# -eq 0 ]
then
	echo " Usage: `basename $0` all centos cirros fedora"
	exit 1
fi

cirros(){
	echo cirros
	image=cirros-0.3.0-x86_64-disk.img
	location=https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img
	name="CirrOS 0.3.0"
	images
}

fedora(){
	echo fedora
	location=http://download.fedoraproject.org/pub/fedora/linux/releases/19/Images/x86_64/Fedora-x86_64-19-20130627-sda.qcow2
	image=Fedora-x86_64-19-20130627-sda.qcow2
	name="Fedora 19 x86_64"
	images
}

centos(){
	echo centos
	location=http://mirror.catn.com/pub/catn/images/qcow2/centos6.4-x86_64-gold-master.img
	image=centos6.4-x86_64-gold-master.img 
	name="CentOS 6.4 x86_64"
	images
}

images(){
echo $image from $location with $name

wget $location
md5sum -c glance-images.md5sum  > file.tmp
grep $image file.tmp | grep OK > /dev/null
rm -rf file.tmp
if [ $? -eq 0 ]
then
	. /root/keystonerc_admin
	glance image-create --name '$name' --disk-format qcow2 --container-format bare --is-public true < $dir/$image
else
	echo " ERROR: Image md5um indicates $image is corrupt"
fi
}

all(){
	cirros
	fedora
	centos
}

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
esac

#cleanup
cd -

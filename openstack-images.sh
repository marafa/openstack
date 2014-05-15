#!/bin/sh
#downloads images, checks md5sum, adds the image to glance

echo "Todo: integrate http://dev.centos.org/centos/hvm/"

dir=/root/images.tmp
md5file="`dirname $0`/glance-images.md5sum"

usage(){
        echo " Usage: `basename $0` all centos cirros fedora19 centos65 rhel7"
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

centos65(){
	location=http://repos.fedorapeople.org/repos/openstack/guest-images/centos-6.5-20140117.0.x86_64.qcow2
	image=centos-6.5-20140117.0.x86_64.qcow2
	name="CentOS 6.5 x86_64"
	images
}

rhel7(){
	location=ftp://ftp.redhat.com/redhat/rhel/rc/7/GuestImage/rhel-guest-image-7.0-20140410.0.x86_64.qcow2
	image=rhel-guest-image-7.0-20140410.0.x86_64.qcow2
	name="RHEL 7.0 x86_64"
	images
}

download(){
if ! [ -a $dir/$image ]
then
	wget $location -O $dir/$image
fi
}

debug(){
echo debug ------
echo image=$image
echo location=$location
echo name=$name
echo md5sum=$md5file
echo debug ------
}

get_md5sum(){
#if [ -f $dir/glance-images.md5sum ]
if ! [ -f $md5file ]
then
	echo " INFO: Downloading md5sums to $md5file"
        wget https://raw.github.com/marafa/openstack/master/glance-images.md5sum -O $md5file
fi
}

images(){
#debug
get_md5sum
download
echo " INFO: Checking md5sum of $image"
md5sum -c $md5file  > file.tmp
grep $image file.tmp | grep OK > /dev/null
if [ $? -eq 0 ]
then
	echo " INFO: Importing $image into glance"
        . /root/keystonerc_admin
        glance image-create --name "$name" --disk-format qcow2 --container-format bare --is-public true < $dir/$image
else
        echo " ERROR: Image md5um indicates $image is corrupt"
fi
rm -rf file.tmp
}

all(){
        cirros
        fedora19
        centos
        centos65
	rhel7
}

####main

if [ $# -eq 0 ]
then
        usage
fi

if ! [ -d $dir ]
then
        mkdir -p $dir
fi

cd $dir

case $1 in
        cirros)
                cirros
        ;;
        centos)
                centos
        ;;
        fedora19)
                fedora19
        ;;
        all)
                all
        ;;
	centos65)
		centos65
	;;
	rhel7)
		rhel7
	;;	
        *)
                usage
        ;;
esac

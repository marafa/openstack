#!/bin/sh
#downloads images, checks md5sum, adds the image to glance

dir=/root/images.tmp
md5file="`dirname $0`/glance-images.md5sum"

usage(){
        echo " Usage: `basename $0` all cirros fedora19 fedora20 fedora21 fedora21a centos64 centos65 rhel7 centos6 centos7 centos7atomic"
        echo
        echo " Submit image locations at https://github.com/marafa/openstack"
        exit 1
}

cirros(){
        image=cirros-0.3.2-x86_64-disk.img
	location=http://download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img
        name="CirrOS 0.3.2"
	md5="64d7c1cd2b6f60c92c14662941cb7913"
        images
}

fedora19(){
        location=http://download.fedoraproject.org/pub/fedora/linux/releases/19/Images/x86_64/Fedora-x86_64-19-20130627-sda.qcow2
        image=Fedora-x86_64-19-20130627-sda.qcow2
        name="Fedora 19 x86_64"
        md5="9ff360edd3b3f1fc035205f63a58ec3e"
        images
}

fedora20(){
	location=http://download.fedoraproject.org/pub/fedora/linux/updates/20/Images/x86_64/Fedora-x86_64-20-20140407-sda.qcow2
	image=Fedora-x86_64-20-20140407-sda.qcow2
	name="Fedora 20 x86_64"
	md5="1ec332a350e0a839f03c967c1c568623"
	images
}

fedora21(){
	location=http://download.fedoraproject.org/pub/fedora/linux/releases/21/Cloud/Images/x86_64/Fedora-Cloud-Base-20141203-21.x86_64.qcow2
	image=Fedora-Cloud-Base-20141203-21.x86_64.qcow2
	name="Fedora 21 General Purpose"
	md5="d009530079fd6567a3f0579a09c03af0"
	images
}

fedora21a(){
	location=http://download.fedoraproject.org/pub/fedora/linux/releases/21/Cloud/Images/x86_64/Fedora-Cloud-Atomic-20141203-21.x86_64.qcow2
	image=Fedora-Cloud-Atomic-20141203-21.x86_64.qcow2
	name="Fedora 21 Atomic"
	md5="7aa95d1513c957ac5028c3f7e6900e16"
	images
}

centos64(){
        location=http://mirror.catn.com/pub/catn/images/qcow2/centos6.4-x86_64-gold-master.img
        image=centos6.4-x86_64-gold-master.img
        name="CentOS 6.4 x86_64"
        md5="6cbd6c52a836e7dec8716b8ef5a37c4a"
        images
}

centos65(){
	location=http://mirror.catn.com/pub/catn/images/qcow2/centos6.5-gold-master.qcow2
	image=centos6.5-gold-master.qcow2
	name="CentOS 6.5 x86_64"
	md5="2041756979e68a1cd40e5ffa3114cdd4"
	images
}

centos6(){
	location=http://cloud.centos.org/centos/6/images/CentOS-6-x86_64-GenericCloud-20141129_01.qcow2
	image=CentOS-6-x86_64-GenericCloud-20141129_01.qcow2
	name="CentOS 6 20141129"
	md5="62ac2565e3527377860361f57639f334"
	images
}

rhel7(){
	location=ftp://ftp.redhat.com/redhat/rhel/rc/7/GuestImage/rhel-guest-image-7.0-20140410.0.x86_64.qcow2
	image=rhel-guest-image-7.0-20140410.0.x86_64.qcow2
	name="RHEL 7.0 x86_64"
	md5=""
	images
}

centos7(){
	location=http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-20141129_01.qcow2
	image=CentOS-7-x86_64-GenericCloud-20141129_01.qcow2
	name="CentOS 7 20141129"
	md5="ffaf7aabd6330927cabd9ab996e070d2"
	images
}

centos7atomic(){
	location=http://buildlogs.centos.org/rolling/7/isos/x86_64/CentOS-7-x86_64-AtomicHost.qcow2
	image=CentOS-7-x86_64-AtomicHost.qcow2
	name="CentOS 7 AtomicHost"
	md5=""
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

images(){
#debug
download
echo " INFO: Checking md5sum of $image"
md5sum $image > $image.md5sum
grep $md5 $image.md5sum  > /dev/null
if [ $? -eq 0 ]
then
	echo " INFO: Importing $image into glance"
        . /root/keystonerc_admin
        glance image-create --name "$name" --disk-format qcow2 --container-format bare --is-public true < $dir/$image
else
        echo " ERROR: Image md5um indicates $image is corrupt"
fi
rm -rf file.tmp $md5file
}

all(){
        cirros
        fedora19
	fedora20
	fedora21
        centos64
        centos65
	centos6
	centos7
	rhel7
	centos7atomic
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
        fedora19)
                fedora19
        ;;
        fedora20)
                fedora20
        ;;
        fedora21)
                fedora21
        ;;
        fedora21a)
                fedora21a
        ;;
        all)
                all
        ;;
        centos64)
                centos64
        ;;
	centos65)
		centos65
	;;
	centos6)
		centos6
	;;
	centos7)
		centos7
	;;	
	rhel7)
		rhel7
	;;	
	rhel7)
		rhel7
	;;	
	centos7atomic)
		centos7atomic
	;;
        *)
                usage
        ;;
esac

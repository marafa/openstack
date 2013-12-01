yum install -y http://rdo.fedorapeople.org/openstack-havana/rdo-release-havana.rpm virt-what wget git screen vim yum-presto iotop vim-enhanced; yum -y update; reboot

yum -y install openstack-packstack; packstack  --gen-answer-file=~/packstack.answer.orig ; cp ~/packstack.answer.orig ~/packstack.answer

cat >> /root/.bashrc << EOF
alias vi=vim
alias grep='grep -E --colour=auto'
alias view='vim -R'
alias df='df -h'
export PATH=$PATH:/root/bin/openstack/
if [ -f /root/keystonerc_admin ]
then
	source /root/keystonerc_admin
fi
EOF
source /root/.bashrc

#### git clone
mkdir ~/bin
cd ~/bin
git clone https://github.com/marafa/openstack.git
cd ~/bin/openstack
./openstack-os-tools.sh
cd

#### alias nic
cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0:1
sed -i 's/eth0"/eth0:1"/g' /etc/sysconfig/network-scripts/ifcfg-eth0:1

#####modify ~/packstack.answer
sed -i 's/CONFIG_NTP_SERVERS=/CONFIG_NTP_SERVERS=0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org/g' ~/packstack.answer
sed -i 's/CONFIG_HORIZON_SSL=n/CONFIG_HORIZON_SSL=y/g' ~/packstack.answer 
sed -i 's/PW=.*/PW=password/g' ~/packstack.answer 
sed -i 's/CONFIG_SWIFT_INSTALL=n/CONFIG_SWIFT_INSTALL=y/g' ~/packstack.answer
sed -i 's/CONFIG_CINDER_VOLUMES_SIZE=20G/CONFIG_CINDER_VOLUMES_SIZE=5G/g' ~/packstack.answer
sed -i 's,CONFIG_NOVA_NETWORK_FLOATRANGE=10.3.4.0/22,CONFIG_NOVA_NETWORK_FLOATRANGE=192.168.0.0/24,g' ~/packstack.answer
sed -i 's/CONFIG_PROVISION_DEMO=n/CONFIG_PROVISION_DEMO=y/g' ~/packstack.answer
sed -i 's,CONFIG_PROVISION_DEMO_FLOATRANGE=172.24.4.224/28,CONFIG_PROVISION_DEMO_FLOATRANGE=192.168.0.0/24,g' ~/packstack.answer

####vlan support
sed -i 's/CONFIG_NEUTRON_OVS_TENANT_NETWORK_TYPE=local/CONFIG_NEUTRON_OVS_TENANT_NETWORK_TYPE=vlan/g' ~/packstack.answer
sed -i 's/CONFIG_NEUTRON_OVS_VLAN_RANGES=/CONFIG_NEUTRON_OVS_VLAN_RANGES=physnet1:1000:2999/g' ~/packstack.answer
sed -i 's/CONFIG_NEUTRON_OVS_BRIDGE_MAPPINGS=/CONFIG_NEUTRON_OVS_BRIDGE_MAPPINGS=physnet1:br-eth0:1/g' ~/packstack.answer

###################RUN IT ##################
#$#$     time packstack --answer-file=~/packstack.answer
#OR
#   packstack --allinone --nagios-install=n --mysql-pw=password --ntp-servers=0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org --os-swift-install=y --provision-demo-floatrange=192.168.0.128/25 --keystone-demo-passwd=password


echo "export PS1='[\u@\h \W(\033[1;31mkeystone_admin\033[0m)]\\$ '" >> ~/keystonerc_admin 
source ~/keystonerc_admin

kvm=`virt-what`
if [ "$kvm" == "kvm" ]
then
        openstack-config --set /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini AGENT polling_interval 20
        service neutron-openvswitch-agent restart
fi

chkconfig ntpdate on

#ovs-vsctl add-port br-ex eth0; service network restart #this line is now in openstack-outside.sh

sed -i 's/DEBUG = False/DEBUG = True/g' /etc/openstack-dashboard/local_settings
for service in `ls /etc/init.d/openstack-nova*`
do
        $service restart
done
sed -i 's/debug=True/debug=false/g' /etc/nova/nova.conf
service httpd restart

sh /root/bin/openstack/openstack-outside.sh ### looks like we dont have to create a public network if demo account is used

###create a flavour for centos
nova flavor-create --ephemeral 0 --rxtx-factor 1.0 --is-public True m2.small 6 1024 10 1

### add rules to sec group demo_secgroup
source /root/keystonerc_demo
#ping
nova --no-cache secgroup-add-rule demo_secgroup icmp -1 -1 0.0.0.0/0
#ssh
nova --no-cache secgroup-add-rule demo_secgroup tcp 22 22 0.0.0.0/0
#list them
nova secgroup-list-rules demo_secgroup

#set demo password to password
keystone user-password-update --pass password demo
echo "export OS_PASSWORD=password" >> ~/keystonerc_demo

###in case a re run of the install is needed
packstack --answer-file=packstack-answers

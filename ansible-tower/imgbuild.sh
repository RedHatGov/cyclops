#!/bin/bash
export factory_image=rhel-server-7.5-update-4-x86_64-kvm.qcow2
export image=rhel7.qcow2
export destination_folder=ansible-tower
export destination_image=tower.qcow2
export tower_url=https://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-latest.el7.tar.gz

export name=
export password=
export pool_id=

mkdir -p $destination_folder

echo "######################"
echo "# Make working image #"
rm $image
echo "# Copy Factory image #"
echo "######################"
cp $factory_image $image

sync
echo "######################"
echo "# Subscribing system #"
echo "######################"
virt-customize -a $image --run-command "subscription-manager register --username=$name --password=$password" --run-command "subscription-manager attach --pool $pool_id" --run-command 'subscription-manager repos --disable "*"' --run-command 'subscription-manager repos --enable rhel-7-server-rpms --enable rhel-7-server-extras-rpms --enable rhel-7-server-ansible-2.5-rpms --enable rhel-7-server-openstack-13-optools-rpms --enable rhel-7-server-openstack-13-tools-rpms --enable rhel-7-server-openstack-13-devtools-rpms --enable rhel-7-server-openstack-13-rpms'
echo "# Pulling packages #"
echo "####################"
virt-customize -a $image --run-command 'yum -y install ansible python2-shade' --run-command "curl -o /opt/ansible-tower-setup-bundle-latest.el7.tar.gz $tower_url"
virt-customize -a $image --upload "$destination_folder/inventory:/opt" --upload "$destination_folder/install.sh:/root" --run-command "chmod +x /root/install.sh"
echo "######################"
echo "# Setting root pass #"
echo "#####################"
virt-customize -a $image --root-password password:redhat --uninstall cloud-init
#echo "########################"
#echo "# Unsubscribing system #" The Tower install requires a sub, this is just here for example on building other appliances
#echo "########################"
#virt-customize -a $image --run-command 'subscription-manager remove --all' --run-command 'subscription-manager unregister'
echo "#######################"
echo "# Copy to destination #"
echo "#######################"
cp $image $destination_folder/$destination_image ; sync
chmod -R 777 ansible-tower/

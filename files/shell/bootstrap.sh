#!/bin/bash

FQDN=`hostname --fqdn`

# Vagrant fact for Puppet if needed
if [ $VAGRANT == '1' ]; then
    mkdir -p /etc/facter/facts.d
    echo -e '---\nvagrant:  1' > /etc/facter/facts.d/vagrant.yaml
fi

# Setup OpenVPN keys
mkdir -p /etc/openvpn/keys
cp /root/files/openvpn/key-store/ca.crt /etc/openvpn/keys/
cp /root/files/openvpn/key-store/$FQDN.crt /etc/openvpn/keys/
cp /root/files/openvpn/key-store/$FQDN.key /etc/openvpn/keys/

# Only include-diffie hellman on VPN server
if [ $(hostname --fqdn | cut -f1 -d.) == 'vpn' ]; then
    cp /root/files/openvpn/key-store/dh2048.pem /etc/openvpn/keys/
fi

# Apply puppet
cp -R /root/files/puppet/* /etc/puppet/
puppet apply /etc/puppet/environments/production/manifests/site.pp --confdir=/etc/puppet/ --environment=production --environmentpath=/etc/puppet/environments/

Vagrant.configure(2) do |config|
  config.vm.box = "debian/jessie64"

  config.vm.synced_folder "files/puppet", "/root/files/puppet"

  config.vm.synced_folder "files/openvpn", "/root/files/openvpn"

  config.vm.provision "shell",
    inline: "
        mkdir -p /etc/facter/facts.d;
        echo -e '---\nvagrant:  1' > /etc/facter/facts.d/vagrant.yaml;
        FQDN=`hostname --fqdn`;
        mkdir -p /etc/openvpn/keys;
        cp /root/files/openvpn/key-store/ca.crt /etc/openvpn/keys/;
        cp /root/files/openvpn/key-store/$FQDN.crt /etc/openvpn/keys/;
        cp /root/files/openvpn/key-store/$FQDN.key /etc/openvpn/keys/;
        if [ $(hostname --fqdn | cut -f1 -d.) == 'vpn' ]; then cp /root/files/openvpn/key-store/dh2048.pem /etc/openvpn/keys/; fi;
        cp -R /root/files/puppet/* /etc/puppet/;
        puppet apply /etc/puppet/environments/production/manifests/site.pp --confdir=/etc/puppet/ --environment=production --environmentpath=/etc/puppet/environments/
    "

  config.vm.define "vpn" do |vpn|
    vpn.vm.hostname = "vpn.techpunch.com"
    vpn.vm.network :private_network, ip: "192.168.5.10"
    vpn.vm.network "forwarded_port", guest: 1194, host: 1194
    vpn.vm.provision :hosts
  end

  config.vm.define "dummy" do |dummy|
    dummy.vm.hostname = "dummy.techpunch.com"
    dummy.vm.network :private_network, ip: "192.168.5.20"
    dummy.vm.provision :hosts
  end
end

Vagrant.configure(2) do |config|
  config.vm.box = "debian/jessie64"

  #config.vm.synced_folder "files", "/root/files", type: "rsync", rsync__args: ["--verbose", "--archive", "--delete", "-z"]

  config.vm.synced_folder "files", "/root/files", owner: "root", group: "root", mount_options: ["dmode=775,fmode=664"]

  config.vm.provider "virtualbox" do |v|
      v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
  end

  config.vm.provision "shell",
    inline: "
        export FACTER_vagrant=1;
        FQDN=`hostname --fqdn`;
        mkdir -p /etc/openvpn/keys;
        cp /root/files/openvpn/key-store/ca.crt /etc/openvpn/keys/;
        cp /root/files/openvpn/key-store/$FQDN.crt /etc/openvpn/keys/;
        cp /root/files/openvpn/key-store/$FQDN.key /etc/openvpn/keys/;
        cp /root/files/openvpn/key-store/dh2048.pem /etc/openvpn/keys/;
        cp /root/files/puppet/* /etc/puppet/;
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

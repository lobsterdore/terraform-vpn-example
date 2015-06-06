Vagrant.configure(2) do |config|
  config.vm.box = "debian/jessie64"

  # Seems that symlinked folders have to be shared individually
  config.vm.synced_folder "files/puppet", "/root/files/puppet"
  config.vm.synced_folder "files/openvpn", "/root/files/openvpn"
  config.vm.synced_folder "files/shell", "/root/files/shell"

  config.vm.provision "shell",
    inline: "
      export VAGRANT=1;
      /bin/bash /root/files/shell/bootstrap.sh
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

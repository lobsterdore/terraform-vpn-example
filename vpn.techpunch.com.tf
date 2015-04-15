resource "digitalocean_droplet" "vpn.techpunch.com" {
  image = "ubuntu-14-04-x64"
  name = "vpn.techpunch.com"
  region = "ams3"
  size = "512mb"
  private_networking = false
  ipv6 = false
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]

  connection {
      user = "root"
      type = "ssh"
      key_file = "${var.pvt_key}"
      timeout = "2m"
  }

  # Copy openvpn config (need to create symlink in files)
  provisioner "file" {
    source = "files/openvpn"
    destination = "/root"
  }

  # Bootstrap openvpn
  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "sudo apt-get update",
      "sudo apt-get -y upgrade",
      "sudo apt-get -y install openvpn",
      "cp -R /root/openvpn/* /etc/openvpn/",
      "rm -rf /root/openvpn",
      "cp /etc/openvpn/techpunch.com-vpn/config-store/vpn.techpunch.com.conf /etc/openvpn/",
      "mkdir /etc/openvpn/techpunch.com-vpn/keys",
      "cp /etc/openvpn/techpunch.com-vpn/key-store/ca.crt /etc/openvpn/techpunch.com-vpn/keys/ca.crt",
      "cp /etc/openvpn/techpunch.com-vpn/key-store/vpn.techpunch.com.crt /etc/openvpn/techpunch.com-vpn/keys/vpn.techpunch.com.crt",
      "cp /etc/openvpn/techpunch.com-vpn/key-store/vpn.techpunch.com.key /etc/openvpn/techpunch.com-vpn/keys/vpn.techpunch.com.key",
      "cp /etc/openvpn/techpunch.com-vpn/key-store/dh2048.pem /etc/openvpn/techpunch.com-vpn/keys/dh2048.pem",
      "sh /etc/openvpn/firewall.sh",
      "sh -c 'iptables-save > /etc/iptables.conf'",
      "echo 'post-up iptables-restore < /etc/iptables.conf' >> /etc/network/interfaces",
      "rm -rf /etc/openvpn/techpunch.com-vpn/config-store /etc/openvpn/techpunch.com-vpn/key-store /etc/openvpn/techpunch.com-vpn/easy-rsa /etc/openvpn/firewall.sh",
      "chmod 400 /etc/openvpn/techpunch.com-vpn/keys/*.key",
      "chmod 400 /etc/openvpn/techpunch.com-vpn/keys/*.crt",
      "chmod 400 /etc/openvpn/techpunch.com-vpn/keys/*.pem",
      "service openvpn start"
    ]
  }
}

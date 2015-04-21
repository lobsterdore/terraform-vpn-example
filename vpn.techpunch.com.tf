resource "digitalocean_droplet" "vpn-techpunch-com" {
  image = "debian-7-0-x64"
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
    source = "files"
    destination = "/root"
  }

  # Bootstrap openvpn
  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "sudo apt-get update",
      "sudo apt-get -y upgrade",
      "sudo apt-get -y install openvpn",
      "mkdir -p /etc/openvpn/keys",
      "cp /root/files/openvpn/config-store/vpn.techpunch.com.conf /etc/openvpn/",
      "cp /root/files/openvpn/key-store/ca.crt /etc/openvpn/keys/",
      "cp /root/files/openvpn/key-store/vpn.techpunch.com.crt /etc/openvpn/keys/",
      "cp /root/files/openvpn/key-store/vpn.techpunch.com.key /etc/openvpn/keys/",
      "cp /root/files/openvpn/key-store/dh2048.pem /etc/openvpn/keys/",
      "cp -R /root/files/openvpn/client-configs/ /etc/openvpn/",
      "sh /root/files/openvpn/firewall-server.sh",
      "sh -c 'iptables-save > /etc/iptables.conf'",
      "echo 'post-up iptables-restore < /etc/iptables.conf' >> /etc/network/interfaces",
      "rm -rf /root/files",
      "chmod -R 400 /etc/openvpn/keys",
      "service openvpn start"
    ]
  }
}

resource "digitalocean_domain" "default" {
   name = "vpn.techpunch.com"
   ip_address = "${digitalocean_droplet.vpn-techpunch-com.ipv4_address}"
}

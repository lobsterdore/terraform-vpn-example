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
      "mkdir -p /etc/openvpn/keys",
      "cp /root/openvpn/config-store/vpn.techpunch.com.conf /etc/openvpn/",
      "cp /root/openvpn/key-store/ca.crt /etc/openvpn/keys/",
      "cp /root/openvpn/key-store/vpn.techpunch.com.crt /etc/openvpn/keys/",
      "cp /root/openvpn/key-store/vpn.techpunch.com.key /etc/openvpn/keys/",
      "cp /root/openvpn/key-store/dh2048.pem /etc/openvpn/keys/",
      "cp -R /root/openvpn/client-configs/ /etc/openvpn/",
      "sh /root/openvpn/firewall.sh",
      "sh -c 'iptables-save > /etc/iptables.conf'",
      "echo 'post-up iptables-restore < /etc/iptables.conf' >> /etc/network/interfaces",
      "rm -rf /root/openvpn",
      "chmod -R 400 /etc/openvpn/keys",
      "service openvpn start"
    ]
  }
}

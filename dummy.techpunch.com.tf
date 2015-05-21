resource "digitalocean_droplet" "dummy-techpunch-com" {
  depends_on = ["digitalocean_droplet.vpn-techpunch-com"]
  image = "debian-8-x64"
  name = "dummy.techpunch.com"
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
      "apt-get update",
      "apt-get -y upgrade",
      "apt-get --force-yes -y install openvpn dnsmasq",
      "cp /root/files/dns/dnsmasq.conf /etc/",
      "service dnsmasq restart",
      "mkdir -p /etc/openvpn/keys",
      "cp /root/files/openvpn/config-store/dummy.techpunch.com.conf /etc/openvpn/",
      "cp /root/files/openvpn/key-store/ca.crt /etc/openvpn/keys/",
      "cp /root/files/openvpn/key-store/dummy.techpunch.com.crt /etc/openvpn/keys/",
      "cp /root/files/openvpn/key-store/dummy.techpunch.com.key /etc/openvpn/keys/",
      "cp -R /root/files/openvpn/client-configs/ /etc/openvpn/",
      "sh /root/files/firewall-client.sh",
      "sh -c 'iptables-save > /etc/iptables.conf'",
      "echo 'post-up iptables-restore < /etc/iptables.conf' >> /etc/network/interfaces",
      "rm -rf /root/files",
      "chmod -R 400 /etc/openvpn/keys",
      "service openvpn@dummy.techpunch.com start"
    ]
  }
}

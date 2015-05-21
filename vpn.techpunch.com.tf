resource "digitalocean_droplet" "vpn-techpunch-com" {
  image = "debian-8-x64"
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

  # Copy openvpn config (need to create symlink in files for puppet and openvpn)
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
      "mkdir -p /etc/openvpn/keys",
      "cp /root/files/openvpn/key-store/ca.crt /etc/openvpn/keys/",
      "cp /root/files/openvpn/key-store/vpn.techpunch.com.crt /etc/openvpn/keys/",
      "cp /root/files/openvpn/key-store/vpn.techpunch.com.key /etc/openvpn/keys/",
      "cp /root/files/openvpn/key-store/dh2048.pem /etc/openvpn/keys/",
      "apt-get --force-yes -y install puppet",
      "cp -R /root/files/puppet/* /etc/puppet/",
      "puppet apply /etc/puppet/environments/production/manifests/site.pp --confdir=/etc/puppet/ --environment=production --environmentpath=/etc/puppet/environments/",
      "rm -rf /root/files"
    ]
  }
}

resource "digitalocean_domain" "default" {
   name = "vpn.techpunch.com"
   ip_address = "${digitalocean_droplet.vpn-techpunch-com.ipv4_address}"
}

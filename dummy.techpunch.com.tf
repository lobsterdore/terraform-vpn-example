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
      "mkdir -p /etc/openvpn/keys",
      "cp /root/files/openvpn/key-store/ca.crt /etc/openvpn/keys/",
      "cp /root/files/openvpn/key-store/dummy.techpunch.com.crt /etc/openvpn/keys/",
      "cp /root/files/openvpn/key-store/dummy.techpunch.com.key /etc/openvpn/keys/",
      "apt-get --force-yes -y install puppet",
      "cp -R /root/files/puppet/* /etc/puppet/",
      "puppet apply /etc/puppet/environments/production/manifests/site.pp --confdir=/etc/puppet/ --environment=production --environmentpath=/etc/puppet/environments/",
      "rm -rf /root/files"
    ]
  }
}

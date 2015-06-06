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

  provisioner "file" {
    source = "files"
    destination = "/root"
  }

  # Bootstrap
  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "/bin/bash /root/files/shell/bootstrap.sh",
      "rm -rf /root/files"
    ]
  }
}

resource "digitalocean_domain" "default" {
   name = "vpn.techpunch.com"
   ip_address = "${digitalocean_droplet.vpn-techpunch-com.ipv4_address}"
}

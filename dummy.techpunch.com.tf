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
      "/bin/bash /root/files/shell/bootstrap.sh"
    ]
  }
}

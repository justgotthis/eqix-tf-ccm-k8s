provider "packet" {
  auth_token = var.auth_token
}

resource "tls_private_key" "ssh_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "packet_ssh_key" "ssh_pub_key" {
  name       = var.project_id
  public_key = chomp(tls_private_key.ssh_key_pair.public_key_openssh)
}

// General template used to install docker on Ubuntu 20.04
data "template_file" "install_docker" {
  template = file("${path.module}/templates/install-docker.sh.tpl")

  vars = {
    docker_version = var.docker_version
  }
}

data "template_file" "install_kubernetes" {
  template = file("${path.module}/templates/setup-kube.sh.tpl")

  vars = {
    kubernetes_version = var.kubernetes_version
  }
}

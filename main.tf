provider "packet" {
  auth_token = var.auth_token
}

resource "packet_ssh_key" "ssh_pub_key" {
  name       = var.project_id
  public_key = chomp(tls_private_key.k8s_cluster_access_key.public_key_openssh)
}

// General template used to install docker on Ubuntu 18.04
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

// Setup the kubernetes controller node
resource "packet_device" "k8s_controller" {
  count            = var.master_count
  project_id       = var.project_id
  facilities       = [var.facility]
  plan             = var.plan_master
  operating_system = "ubuntu_18_04"
  hostname         = format("%s-master%02d", var.cluster_name, count.index + 1)
  billing_cycle    = "hourly"
  tags             = ["kubernetes", "k8s", "controller"]
}
  
# Using a null_resource so the packet_device doesn't have to wait to be initially provisioned
resource "null_resource" "setup_master" {
  count = var.master_count

  connection {
    type = "ssh"
    user = "root"
    host = element(packet_device.k8s_controller.*.access_public_ipv4, count.index)
    private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
    agent = false
  }

  provisioner "file" {
    content     = data.template_file.ccm_secret.rendered
    destination = "/tmp/secret.yaml"
  }

  provisioner "file" {
    content     = data.template_file.ccm_deploy.rendered
    destination = "/tmp/deployment.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/setup-ccm.sh"
    destination = "/tmp/setup-ccm.sh"
  }

  provisioner "file" {
    content     = data.template_file.weave_cni.rendered
    destination = "/tmp/weave.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/setup-base.sh"
    destination = "/tmp/setup-base.sh"
  }

  provisioner "file" {
    content     = data.template_file.install_docker.rendered
    destination = "/tmp/install-docker.sh"
  }

  provisioner "file" {
    content     = data.template_file.install_kubernetes.rendered
    destination = "/tmp/setup-kube.sh"
  }

  provisioner "file" {
    content     = data.template_file.setup_kubeadm.rendered
    destination = "/tmp/setup-kubeadm.sh"
  }

  provisioner "file" {
    content     = data.template_file.kubeconfig_me.rendered
    destination = "/tmp/transform_kubeconfig.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/*.sh",
      "/tmp/setup-base.sh",
      "/tmp/install-docker.sh",
      "/tmp/setup-kube.sh",
      "/tmp/setup-kubeadm.sh",
      "/tmp/setup-ccm.sh",
      "/tmp/weave.sh",
      "/tmp/transform_kubeconfig.sh",
    ]
  }
}

data "external" "kubeadm_join" {
  program = ["${path.module}/scripts/kubeadm-token.sh"]
  count = var.master_count

  query = {
    host = element(packet_device.k8s_controller.*.access_public_ipv4, count.index)
  }

  # Make sure to only run this after the controller is up and setup
  depends_on = [null_resource.setup_master]
}

data "external" "kubeconfig_xfer" {
  program = ["${path.module}/scripts/scp_kubeconfig.sh"]

  query = {
    mypub = packet_device.k8s_controller[0].access_public_ipv4
  }

  # Make sure to only run this after the controller is up and setup
  depends_on = [null_resource.setup_master]
}

data "template_file" "weave_cni" {
  // populate weave cni file to copy to master and apply as needed
  template = file("${path.module}/templates/cni-plugins/weave.sh.tpl")

  vars = {
    pod_cidr = var.kubernetes_cluster_cidr
  }

}

data "template_file" "ccm_deploy" {
  // populate ccm deploy file to copy to master and apply as needed
  template = file("${path.module}/templates/ccm/deployment.yaml.tpl")

  vars = {
    ccm_version = var.ccm_version
  }

}

data "template_file" "ccm_secret" {
  // populate ccm secret file to copy to master and apply as needed
  template = file("${path.module}/templates/ccm/secret.yaml.tpl")

  vars = {
    auth_token = var.auth_token
    project_id = var.project_id
  }

}

data "template_file" "setup_kubeadm" {
  template = file("${path.module}/templates/setup-kubeadm.sh.tpl")

  vars = {
    kubernetes_version      = var.kubernetes_version
    kubernetes_port         = var.kubernetes_port
    kubernetes_dns_ip       = var.kubernetes_dns_ip
    kubernetes_dns_domain   = var.kubernetes_dns_domain
    kubernetes_cluster_cidr = var.kubernetes_cluster_cidr
    kubernetes_service_cidr = var.kubernetes_service_cidr
  }
}

data "template_file" "kubeconfig_me" {
  template = file("${path.module}/templates/transform-kubeconfig.sh.tpl")

  vars = {
    pub_ip = packet_device.k8s_controller[0].access_public_ipv4
  }
}

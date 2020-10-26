resource "packet_device" "k8s_workers" {
  project_id       = var.project_id
  facilities       = [var.facility]
  count            = var.worker_count
  plan             = var.plan_node
  operating_system = "ubuntu_18_04"
  hostname         = format("%s-worker%02d", var.cluster_name, count.index + 1)
  billing_cycle    = "hourly"
  tags             = ["kubernetes", "k8s", "worker"]
}

# Using a null_resource so the packet_device doesn't not have to wait to be initially provisioned
resource "null_resource" "setup_worker" {
  count = var.worker_count

  connection {
    type = "ssh"
    user = "root"
    host = element(packet_device.k8s_workers.*.access_public_ipv4, count.index)
    private_key = tls_private_key.ssh_key_pair.private_key_pem
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

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/*.sh",
      "/tmp/setup-base.sh",
      "/tmp/install-docker.sh",
      "/tmp/setup-kube.sh",
      "${data.external.kubeadm_join.result.command}",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl get nodes -o wide",
    ]

    on_failure = continue

    connection {
      type = "ssh"
      user = "root"
      host = packet_device.k8s_controller.access_public_ipv4
      private_key = tls_private_key.ssh_key_pair.private_key_pem
    }
  }
}

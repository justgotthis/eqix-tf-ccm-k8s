resource "packet_device" "k8s_workers" {
  count            = var.worker_count
  project_id       = var.project_id
  facilities       = [var.facility]
  plan             = var.plan_worker
  operating_system = "ubuntu_18_04"
  hostname         = format("%s-worker%02d", var.cluster_name, count.index + 1)
  billing_cycle    = "hourly"
  tags             = ["kubernetes", "k8s", "worker"]
}

# Using a null_resource so the packet_device doesn't have to wait to be initially provisioned
resource "null_resource" "setup_worker" {
  count = var.worker_count

  connection {
    type = "ssh"
    user = "root"
    host = element(packet_device.k8s_workers.*.access_public_ipv4, count.index)
    private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
    agent = false
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
    //just need join command from one of the masters, so 0 is ok for now
    inline = [
      "chmod +x /tmp/*.sh",
      "/tmp/setup-base.sh",
      "/tmp/install-docker.sh",
      "/tmp/setup-kube.sh",
      "${data.external.kubeadm_join[0].result.command}",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl get nodes -o wide",
    ]

    on_failure = continue

    connection {
      //need to output a get nodes so 0 index for masters is ok for now
      type = "ssh"
      user = "root"
      host = packet_device.k8s_controller[0].access_public_ipv4
      private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
    }
  }
}

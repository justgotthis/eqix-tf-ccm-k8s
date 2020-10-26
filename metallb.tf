# Enable BGP on each worker node
resource "packet_bgp_session" "kube_bgp" {
  count          = var.node_count
  device_id      = packet_device.k8s_workers.*.id[count.index]
  address_family = "ipv4"
}

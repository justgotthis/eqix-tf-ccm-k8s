Simple Kubernetes Cluster on Equinix Metal
===========================

This guide can be used as a reference to deploy Kubernetes on Equinix Metal bare-metal servers in a single facility.  This repository is [Experimental](https://github.com/packethost/standards/blob/master/experimental-statement.md) meaning that it's based on untested ideas or techniques and not yet established or finalized or involves a radically new and innovative style! This means that support is best effort (at best!) and we strongly encourage you to NOT use this in production.

| Component  | Version |
| ---------- | ------- |
| Kubernetes | v1.18.3 |

Kubernetes Network:

| Network                  | Subnet           |
| ------------------------ | ---------------- |
| Pod subnet               | 172.16.0.0/12    |
| Service subnet           | 192.168.0.0/16   |

Operating System: Ubuntu 18.0.4

This terraform script has been verified to work with ubuntu 18.04 (default) and 16.04. Ubuntu 20.04 works for most Equinix Metal instance types but the c2.medium.x86 seems to have pod network issues (unable to reach TCP port 80 between pods) with ubuntu 20.04 (possibly due to iptables bug).

TL;DR
----

This will deploy a cluster of 2, 1 master and 1 worker node. It will allow you to use the service type `LoadBalancer`.

Make a copy of `terraform.tfvars.sample` as `terraform.tfvars`  and set the `auth_token` as well as `organization_id`. You can also configure other options like the server type, amount of worker nodes, kubernetes version etc.

```sh
auth_token = "PACKET_AUTH_TOKEN"
organization_id = "PACKET_ORG_ID"
project_name = "k8s-bgp"
facilities = ["ewr1"]
controller_plan = "t1.small.x86"
worker_plan = "t1.small.x86"
worker_count = 2
docker_version = "19.03.10"
kubernetes_version = "1.18.3"
kubernetes_port = "6443"
kubernetes_dns_ip = "192.168.0.10"
kubernetes_cluster_cidr = "172.16.0.0/12"
kubernetes_service_cidr = "192.168.0.0/16"
kubernetes_dns_domain = "cluster.local"
```

```sh
terraform apply
```

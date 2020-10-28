Bare Bones Kubernetes Cluster on Bare Metal
===========================

TL;DR
----

1. Clone this repository
2. Open the "terraform.tfvars" file and add your API Key and Project ID (additional options can be changed in this file as needed)
```sh
auth_token = "API_KEY"
project_id = "PROJECT_ID"
```
3. Create your cluster
```sh
terraform apply
```
4. Once Terraform completes, log into the Kubernetes master of your cluster and run the following:
```sh
. /tmp/weave.sh
```

Introduction
----
This guide can be used as a reference to deploy Kubernetes on Equinix Metal bare metal servers in a single facility in 5 minutes using kubeadm. This repository is [experimental](https://github.com/packethost/standards/blob/master/experimental-statement.md) meaning that it's based on untested ideas or techniques and not yet established or finalized or involves a radically new and innovative style! This means that support is best effort (at best!) and we strongly encourage you to NOT use this in production.

Versions
----
The Kubernetes cluster will be deployed using the following version:

| Component  | Version  |
| ---------- | -------  |
| Kubernetes | 1.18.3   |
| Docker     | 19.03.10 |

Kubernetes Network Subnets

| Network                  | Subnet           |
| ------------------------ | ---------------- |
| Pod subnet               | 172.16.0.0/16    |
| Service subnet           | 192.168.0.0/16   |

Operating System

| OS     | Version |
| ------ | ------- |
| Ubuntu | 18.0.4  |

This terraform script has been verified to work with Ubuntu 18.04 (default) and Ubuntu 16.04. Ubuntu 20.04 works for most Equinix Metal instance types but the c2.medium.x86 seems to have pod network issues (unable to reach TCP port 80 between pods) with Ubuntu 20.04 (possibly due to a known iptables bug).

What is included in the cluster?
----
This terraform script will deploy a cluster of 2, 1 master and 1 worker node by default. Although you can change the number of worker nodes, master scaling is still a WIP so currently this terraform script only creates single master clusters. It is a bare bones cluster in that, it automates the creation of the hardware and Kubernetes installation. The reason for this is that it leaves the end user the option to install whatever they would want on the cluster without starting with a bloated initial setup. One added bonus to this particular terraform script is that even though the cluster is bare bones, it also includes building blocks to deploy add-ons.

Cluster Add-ons
----
Along with the ever so critical CNI add-on, you can also deploy Cloud Controller Manager which includes MetalLB. This particular MetalLB deployment has some automated features:
- Automatically deploy MetalLB components
- Automatically fill in peers of all the nodes in the cluster
- Automatically provision EIP in Equinix Metal as you deploy LoadBalancer Services
- Automatically manage the MetalLB configuration as services get added or deleted

The current CNI available in this Terraform script is Weave but you can opt to install whatever CNI you need to test instead.

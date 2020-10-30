Simple Kubernetes Cluster on Equinix Metal
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

4. Copy kubeconfig file from the master using the command output from the Terraform script above.

What is included in the cluster?
----
- Single master cluster (master scaling WIP)
- Deploy Services with Type=LoadBalancer
- Weave CNI

Introduction
----
This guide can be used as a reference to deploy Kubernetes on Equinix Metal bare metal servers in a single facility in 5 minutes using kubeadm. This repository is [experimental](https://github.com/packethost/standards/blob/master/experimental-statement.md) meaning that it's based on untested ideas or techniques and not yet established or finalized or involves a radically new and innovative style! This means that support is best effort (at best!) and we strongly encourage you to NOT use this in production.

Versions
----
The Kubernetes cluster will be deployed using the following version:

| Component  | Version  |
| ---------- | -------  |
| Kubernetes | 1.18.3   |
| Docker     | 19.03.13 |

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

Managed MetalLB
----
Along with automatically deploying MetalLB components, this particular Terraform script has some automated MetalLB features:
- Automatically fills in peers of all the nodes in the cluster (Legacy Metal Facilities only, IBX WIP)
- Automatically provision EIP in Equinix Metal as you deploy LoadBalancer Services
- Automatically deletes EIP's in Equinix Metal as you delete LoadBalancer Services (need to explicitly delete services, if cluster is removed and services of LB type still exist, EIP's will not get removed from the Metal Portal)
- Automatically update the MetalLB configuration as services get added or deleted 

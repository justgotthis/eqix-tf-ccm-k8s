variable "auth_token" {
  description = "Your Packet API key"
}

variable "project_id" {
  description = "Your Packet Project ID"
}

variable "facility" {
  description = "Your Packet Facility Code (e.g. dfw2)"
}

variable "plan_primary" {
  description = "Plan for Controller (e.g. c3.small.x86)"
}

variable "plan_node" {
  description = "Plan for Workers (e.g. c3.small.x86)"
}

variable "node_count" {
  default     = "1"
  description = "Number of Worker nodes."
}

variable "cluster_name" {
  default = "simple-k8s"
  description = "The cluster project name, will prepend hostnames"
}

variable "docker_version" {
  default = "19.03.10"
}

variable "kubernetes_version" {
  description = "Kubernetes Version"
  default     = "1.18.3"
}

variable "kubernetes_port" {
  description = "Kubernetes API Port"
  default     = "6443"
}

variable "kubernetes_dns_ip" {
  description = "Kubernetes DNS IP"
  default     = "192.168.0.10"
}

variable "kubernetes_cluster_cidr" {
  description = "Kubernetes Pod Subnet"
  default     = "172.16.0.0/12"
}

variable "kubernetes_service_cidr" {
  description = "Kubernetes Service Subnet"
  default     = "192.168.0.0/16"
}

variable "kubernetes_dns_domain" {
  description = "Kubernetes Internal DNS Domain"
  default     = "cluster.local"
}

variable "name" {}
variable "namespace" {}
variable "count" {}

module "nfs-server" {
  source    = "../../../modules/nfs-server-empty-dir"
  name      = "${var.name}-nfs-server"
  namespace = "${var.namespace}"
  medium    = "Memory"
}

module "storage" {
  source    = "../../../modules/kubernetes/storage-nfs"
  name      = "${var.name}"
  namespace = "${var.namespace}"
  count     = "${var.count}"
  storage   = "1Gi"

  annotations {
    "nfs-server-uid" = "${module.nfs-server.deployment_uid}"
  }

  nfs_server    = "${module.nfs-server.cluster_ip}"
  mount_options = "${module.nfs-server.mount_options}"
}

output "count" {
  value = "${var.count}"
}

output "storage_class_name" {
  value = "${module.storage.storage_class_name}"
}

output "storage" {
  value = "${module.storage.storage}"
}

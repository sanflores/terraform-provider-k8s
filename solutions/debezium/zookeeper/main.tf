module "zookeeper" {
  source             = "git::https://github.com/mingfang/terraform-provider-k8s.git//modules/zookeeper"
  name               = "debezium-zookeeper"
  storage_class_name = "${element(k8s_core_v1_persistent_volume_claim.debezium-zookeeper.*.spec.0.storage_class_name, 0)}"
  storage            = "${element(k8s_core_v1_persistent_volume_claim.debezium-zookeeper.*.spec.0.resources.0.requests.storage, 0)}"
  replicas           = "${k8s_core_v1_persistent_volume_claim.debezium-zookeeper.count}"
}

resource "k8s_core_v1_persistent_volume_claim" "debezium-zookeeper" {
  count = "${k8s_core_v1_persistent_volume.debezium-zookeeper.count}"

  metadata {
    name = "${element(k8s_core_v1_persistent_volume.debezium-zookeeper.*.metadata.0.name, count.index)}"
  }

  spec {
    storage_class_name = "${element(k8s_core_v1_persistent_volume.debezium-zookeeper.*.spec.0.storage_class_name, count.index)}"
    volume_name        = "${element(k8s_core_v1_persistent_volume.debezium-zookeeper.*.metadata.0.name, count.index)}"
    access_modes       = ["ReadWriteOnce"]

    resources {
      requests {
        storage = "${element(k8s_core_v1_persistent_volume.debezium-zookeeper.*.spec.0.capacity.storage, count.index)}"
      }
    }
  }
}

resource "k8s_core_v1_persistent_volume" "debezium-zookeeper" {
  count = 3

  metadata {
    name = "pvc-debezium-zookeeper-${count.index}"
  }

  spec {
    storage_class_name               = "debezium-zookeeper"
    persistent_volume_reclaim_policy = "Retain"
    access_modes                     = ["ReadWriteOnce"]

    capacity {
      storage = "100Gi"
    }

    cephfs {
      user = "admin"

      monitors = [
        "192.168.2.89",
        "192.168.2.39",
      ]

      secret_ref {
        name      = "ceph-secret"
        namespace = "default"
      }
    }
  }
}

output "name" {
  value = "${module.zookeeper.name}"
}
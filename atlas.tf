resource "mongodbatlas_advanced_cluster" "cluster" {
  project_id   = var.atlas_project_id
  name         = var.cluster_name
  cluster_type = "SHARDED"

  dynamic "replication_specs" {
    for_each = var.regions

    content {
      region_configs {
        provider_name = "AZURE"
        region_name   = replication_specs.value.atlas_region
        priority      = replication_specs.value.priority

        electable_specs {
          instance_size = replication_specs.value.instance_size
          node_count    = replication_specs.value.node_count
        }
      }
    }
  }
}
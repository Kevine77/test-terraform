resource "mongodbatlas_advanced_cluster" "cluster" {
  project_id   = var.atlas_project_id
  name         = var.cluster_name
  
  cluster_type = "GEOSHARDED"

  replication_specs {
    num_shards = 2

    dynamic "region_configs" {
      for_each = var.regions

      content {
        provider_name = "AZURE"
        region_name   = region_configs.value.atlas_region
        priority      = region_configs.value.priority

        electable_specs {
          instance_size = region_configs.value.instance_size
          node_count    = region_configs.value.node_count
        }
      }
    }
  }
}

resource "mongodbatlas_advanced_cluster" "cluster" {
  project_id   = var.atlas_project_id
  name         = var.cluster_name
  cluster_type = "REPLICASET"

  # Multi-region replica set - primary and secondary regions
  replication_specs {
    # Primary region (first region in map)
    region_configs {
      provider_name = "AZURE"
      region_name   = var.regions[keys(var.regions)[0]].atlas_region
      priority      = 7
      electable_specs {
        instance_size = var.regions[keys(var.regions)[0]].instance_size
        node_count    = var.regions[keys(var.regions)[0]].node_count
      }
    }

    # Secondary regions (remaining regions in map)
    dynamic "region_configs" {
      for_each = slice(keys(var.regions), 1, length(var.regions))
      content {
        provider_name = "AZURE"
        region_name   = var.regions[region_configs.value].atlas_region
        priority      = var.regions[region_configs.value].priority
        read_only_specs {
          instance_size = var.regions[region_configs.value].instance_size
          node_count    = var.regions[region_configs.value].node_count
        }
      }
    }
  }
}


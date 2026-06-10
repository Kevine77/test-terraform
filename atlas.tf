locals {
  region_list = [for k, v in var.regions : merge(v, { key = k })]

  primary_region    = local.region_list[0]
  secondary_regions = slice(local.region_list, 1, length(local.region_list))
}

resource "mongodbatlas_advanced_cluster" "cluster" {
  project_id   = var.atlas_project_id
  name         = var.cluster_name
  cluster_type = "REPLICASET"

  replication_specs {
    region_configs {
      provider_name = "AZURE"
      region_name   = local.primary_region.atlas_region
      priority      = local.primary_region.priority

      electable_specs {
        instance_size = local.primary_region.instance_size
        node_count    = local.primary_region.node_count
      }
    }

    dynamic "region_configs" {
      for_each = local.secondary_regions

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
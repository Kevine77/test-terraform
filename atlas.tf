resource "mongodbatlas_advanced_cluster" "cluster" {
  project_id   = var.atlas_project_id
  name         = var.cluster_name
  cluster_type = "SHARDED"

  # Shard 1
  replication_specs {
    region_configs {
      provider_name = "AZURE"
      region_name   = "EUROPE_NORTH"
      priority      = 7

      electable_specs {
        instance_size = "M30"
        node_count    = 3
      }
    }

    region_configs {
      provider_name = "AZURE"
      region_name   = "EUROPE_WEST"
      priority      = 6

      electable_specs {
        instance_size = "M30"
        node_count    = 3
      }
    }
  }

  # Shard 2
  replication_specs {
    region_configs {
      provider_name = "AZURE"
      region_name   = "EUROPE_NORTH"
      priority      = 7

      electable_specs {
        instance_size = "M30"
        node_count    = 3
      }
    }

    region_configs {
      provider_name = "AZURE"
      region_name   = "EUROPE_WEST"
      priority      = 6

      electable_specs {
        instance_size = "M30"
        node_count    = 3
      }
    }
  }
}
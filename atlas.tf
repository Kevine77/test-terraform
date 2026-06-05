
resource "mongodbatlas_advanced_cluster" "cluster" {
  project_id   = var.atlas_project_id
  name         = "prod-m10"
  cluster_type = "REPLICASET"

  replication_specs {
    region_configs {
      provider_name = "AZURE"
      region_name   = "EUROPE_NORTH"
      priority      = 7

      electable_specs {
        instance_size = "M10"
        node_count    = 3
      }
    }
  }
}

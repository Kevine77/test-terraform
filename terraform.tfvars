cluster_name = "prod-multi-region"
num_shards   = 2

regions = {
  north_europe = {
    atlas_region   = "EUROPE_NORTH"
    azure_region   = "northeurope"
    resource_group = "achu-new"
    vnet_tag_key   = "EA_APPID"
    vnet_tag_value = "SS12"
    subnet_name    = "default"
    instance_size  = "M10"
    node_count     = 3
    priority       = 7
  }
}

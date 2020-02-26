locals {
  name = "example"
  resource_group_name = "example-resource"
  pods_cidr = "10.1.0.0/21"
}

data "azurerm_resource_group" "resource_group" {
  name = local.resource_group_name
}

resource "azurerm_container_registry" "acr" {
  name                     = "${local.name}-acr"
  resource_group_name      = data.azurerm_resource_group.resource_group.name
  location                 = data.azurerm_resource_group.resource_group.location
  sku                      = "Premium"
  admin_enabled            = false
  georeplication_locations = ["East US", "West Europe"]
}

module "aks" {
  source = "../"

  resource_group = {
    name = data.azurerm_resource_group.resource_group.name
    location = data.azurerm_resource_group.resource_group.location
  }
  resource_prefix_name = local.name


  client_id = "00000000-0000-0000-0000-000000000000"
  client_secret = "00000000-0000-0000-0000-000000000000"
  rbac_enabled = true

  default_node_pool = {
    name = "default"
    vm_size = "Standard_A2_v2"
    type = "VirtualMachineScaleSets"
    availability_zones = "1,2,3"
    enable_auto_scaling = true
    enable_node_public_ip = false
    max_count = 61 # max node count
    min_count = 1 # min node count
    node_count = null # initial node count, not necessarie if autocaling is enabled
    max_pods = 30 # by default is 30
  }

  network_profile = {
    network_plugin = "kubenet"
    load_balancer_sku: "standard"
    pod_cidr: local.pods_cidr
  }

  tags = {
    Environment = "development"
  }
}
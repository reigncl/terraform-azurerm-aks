provider "azurerm" {
  version = "=1.44.0"
}

module "ssh-key" {
  source         = "./modules/ssh-key"
  public_ssh_key = var.public_ssh_key == "" ? "" : var.public_ssh_key
}

data "azurerm_kubernetes_service_versions" "current" {
  location = var.resource_group["location"]
}

locals {
  kubernetes_version = coalesce(var.kubernetes_version, data.azurerm_kubernetes_service_versions.current.latest_version)
}

resource "azurerm_kubernetes_cluster" "primary" {
  name                = "${var.resource_prefix_name}-aks"
  location            = var.resource_group["location"]
  resource_group_name = var.resource_group["name"]

  default_node_pool {
    name                  = lookup(var.default_node_pool, "name", "default")
    vm_size               = lookup(var.default_node_pool, "vm_size", "Standard_DS2_v2")
    availability_zones    = split(",", lookup(var.default_node_pool, "availability_zones", ""))
    enable_auto_scaling   = lookup(var.default_node_pool, "enable_auto_scaling", false)
    enable_node_public_ip = lookup(var.default_node_pool, "enable_node_public_ip", false)
    node_taints           = split(",", lookup(var.default_node_pool, "node_taints", ""))
    os_disk_size_gb       = lookup(var.default_node_pool, "os_disk_size_gb", null)
    type                  = lookup(var.default_node_pool, "type", null)
    vnet_subnet_id        = lookup(var.default_node_pool, "vnet_subnet_id", null)
    max_pods              = lookup(var.default_node_pool, "max_pods", null)
    min_count             = lookup(var.default_node_pool, "min_count", null)
    max_count             = lookup(var.default_node_pool, "max_count", null)
    node_count            = lookup(var.default_node_pool, "node_count", null)
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  dns_prefix          = var.resource_prefix_name
  kubernetes_version  = local.kubernetes_version

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      # remove any new lines using the replace interpolation function
      key_data = replace(var.public_ssh_key == "" ? module.ssh-key.public_ssh_key : var.public_ssh_key, "\n", "")
    }
  }

  addon_profile {
    aci_connector_linux {
      enabled = var.addon_profile.aci_connector_linux.enabled
      subnet_name = var.addon_profile.aci_connector_linux.subnet_name
    }

    azure_policy {
      enabled = var.addon_profile.azure_policy.enabled
    }

    http_application_routing {
      enabled = var.addon_profile.http_application_routing.enabled
    }

    kube_dashboard {
      enabled = var.addon_profile.kube_dashboard.enabled
    }

    oms_agent {
      enabled                    = var.addon_profile.oms_agent.enabled
      log_analytics_workspace_id = lookup(var.addon_profile.oms_agent, "log_analytics_workspace_id", azurerm_log_analytics_workspace.main.id)
    }
  }

  role_based_access_control {
    enabled = var.rbac_enabled
  }

  network_profile {
    network_plugin = lookup(var.network_profile, "network_plugin", null)
    network_policy = lookup(var.network_profile, "network_policy", null)
    dns_service_ip = lookup(var.network_profile, "network_policy", null)
    pod_cidr = lookup(var.network_profile, "pod_cidr", null)
    service_cidr = lookup(var.network_profile, "service_cidr", null)
    load_balancer_sku = lookup(var.network_profile, "load_balancer_sku", "basic")
  }

  tags = var.tags
}

resource "random_id" "workspace" {
  keepers = {
    # Generate a new id each time we switch to a new resource group
    group_name = var.resource_group.name
  }

  byte_length = 8
}


resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.resource_prefix_name}-${random_id.workspace.hex}-workspace"
  location            = var.resource_group["location"]
  resource_group_name = var.resource_group["name"]
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_retention_in_days
  tags                = var.tags
}

resource "azurerm_log_analytics_solution" "main" {
  solution_name         = "ContainerInsights"
  location              = var.resource_group["location"]
  resource_group_name   = var.resource_group["name"]
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

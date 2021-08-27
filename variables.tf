variable "resource_group" {
  description = "Resource group name that the AKS will be created in"
  type = object({
    name     = string
    location = string
  })
}

variable "k8s_version_include_preview" {
  type    = bool
  default = false
}

variable "resource_prefix_name" {
  description = "The prefix for the resources created in the specified Azure Resource Group"
}

variable "log_analytics_workspace_sku" {
  description = "The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018"
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "The retention period for the logs in days"
  default     = 30
}

variable "kubernetes_version" {
  description = "(Optional) The kubernetes version, by default the latest version"
  default     = ""
}

# Parameters
# name: by default 'default'
# vm_size
# availability_zones
# enable_auto_scaling: (Optional) Should the Kubernetes Auto Scaler be enabled for this Node Pool? Defaults to false.
# enable_node_public_ip: (Optional) Should nodes in this Node Pool have a Public IP Address? Defaults to false.
# node_taints
# os_disk_size_gb
# type
# vnet_subnet_id
# min_count: minimun node count
# max_count: maximum node count, by default 30
# node_count: initial node count
# max_pods: max count of node
# More information about node count and cidr ranges, visit https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni
variable "default_node_pool" {
  type = map(string)
  default = {
    name : "default"
    vm_size : "Standard_DS2_v2"
    availability_zones : ""
    enable_auto_scaling : false
    enable_node_public_ip : false
    max_pods : null
    node_taints : ""
    os_disk_size_gb : ""
    type : ""
    vnet_subnet_id : ""
    min_count : null
    max_count : null
    node_count : null
  }
}

### Service Principal ###
# for more information: https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal
variable "client_id" {
  type        = string
  description = "The Client ID (appId) for the Service Principal used for the AKS deployment"
}

variable "client_secret" {
  type        = string
  description = "The Client Secret (password) for the Service Principal used for the AKS deployment"
}
### End Service Principal ###

variable "admin_username" {
  default     = "azureuser"
  description = "The username of the local administrator to be created on the Kubernetes cluster"
}

variable "public_ssh_key" {
  description = "A custom ssh key to control access to the AKS cluster, if not provided going to generate a new one"
  default     = ""
}

variable "rbac_enabled" {
  default     = true
  description = "(Required) Is Role Based Access Control Enabled? Changing this forces a new resource to be created."
}

variable "addon_profile" {
  type        = map(map(string))
  description = "(Optional) addons profile for the kubernetes cluster"
  default = {
    azure_policy = {
      enabled = false
    }
    aci_connector_linux = {
      enabled     = false
      subnet_name = "default"
    }
    http_application_routing = {
      enabled = false
    }
    kube_dashboard = {
      enabled = false
    }
    oms_agent = {
      enabled = true
    }
    ingress_application_gateway = {
      enabled = false
    }
  }
}

# Parameters:
# network_plugin: azure or kubenet, by default azure
# network_policy: set this, only if network_plugin is set to azure
# dns_service_ip: service address, set this if network_plugin is set to azure
# pod_cidr: The CIDR to use for pod IP Addresses, this cield can only be set when network_plugin is set to kubenet
# service_cidr: The CIDR to use for service IP Addresses, this cield can only be set when network_plugin is set to kubenet
# load_balancer_sku: Specifies the SKU of the Load Balancer, by default basic
variable "network_profile" {
  type        = map(string)
  description = "Network profile block, more information https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html#network_profile"
}

variable "automatic_channel_upgrade" {
  type        = string
  default     = "none"
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable, Default at None"
}


variable "api_server_authorized_ip_ranges" {
  type        = list(string)
  description = "(Optional) The IP ranges to allow for incoming traffic to the server nodes."
  default     = []
}

variable "tags" {
  default     = {}
  description = "Any tags that should be present on the Virtual Network resources"
  type        = map(string)
}

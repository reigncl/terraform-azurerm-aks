resource "azurerm_network_ddos_protection_plan" "ddos" {
  name                = "${local.name}-ddos"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
}

resource "azurerm_network_security_group" "security_group" {
  name                = "${local.name}-security-group"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
}

resource "azurerm_virtual_network" "network" {
  name                = "${local.name}-virtual-network"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  address_space       = ["10.1.0.0/16"]

  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.ddos[0].id
    enable = length(azurerm_network_ddos_protection_plan.ddos) > 0 ? true : false
  }

  dynamic "subnet" {
    for_each = [
      {
        name = "kubernetes_pods_ipv4_cidr"
        address_prefix = local.pods_cidr
        security_group = ""
      },
    ]
    content {
      name           = "${local.name}-${subnet.value["name"]}"
      address_prefix = subnet.value["address_prefix"]
      security_group = azurerm_network_security_group.security_group.id
    }
  }
}

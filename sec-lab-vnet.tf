provider "azurerm" {
  version = "=1.24.0"
}

resource "azurerm_resource_group" "seclab" {
  name     = "${var.rg_name}"
  location = "${var.location}"
}

###################################################
# Public VNET
##################################################
resource "azurerm_virtual_network" "public_vnet" {
  name                = "public-vnet"
  resource_group_name = "${azurerm_resource_group.seclab.name}"
  location            = "${azurerm_resource_group.seclab.location}"
  address_space       = ["192.168.0.0/29"]
}

resource "azurerm_subnet" "public_vnet_jumpbox" {
  name                 = "jumpbox"
  resource_group_name  = "${azurerm_resource_group.seclab.name}"
  virtual_network_name = "${azurerm_virtual_network.public_vnet.name}"
  address_prefix       = "192.168.0.0/29"
}

resource "azurerm_network_security_group" "public_vnet_jumpbox_nsg" {
  name                = "public-nsg"
  location            = "${azurerm_resource_group.seclab.location}"
  resource_group_name = "${azurerm_resource_group.seclab.name}"

  security_rule {
    name                       = "ALLOW_SSH"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "public_vnet_jumpbox_nsg_assc" {
  subnet_id                 = "${azurerm_subnet.public_vnet_jumpbox.id}"
  network_security_group_id = "${azurerm_network_security_group.public_vnet_jumpbox_nsg.id}"
}

resource "azurerm_virtual_network_peering" "public_vnet_peer_to_tools" {
  name                         = "fromPublicToTools"
  resource_group_name          = "${azurerm_resource_group.seclab.name}"
  virtual_network_name         = "${azurerm_virtual_network.public_vnet.name}"
  remote_virtual_network_id    = "${azurerm_virtual_network.tools_vnet.id}"
  allow_virtual_network_access = true
  depends_on                   = ["azurerm_virtual_network.tools_vnet", "azurerm_virtual_network.public_vnet", "azurerm_virtual_network.vuln_vnet", "azurerm_subnet.public_vnet_jumpbox", "azurerm_subnet.tools_vnet_default", "azurerm_subnet.vuln_vnet_public", "azurerm_subnet.vuln_vnet_private"]
}

##################################################
# Tools VNET
##################################################
resource "azurerm_virtual_network" "tools_vnet" {
  name                = "tools-vnet"
  resource_group_name = "${azurerm_resource_group.seclab.name}"
  location            = "${azurerm_resource_group.seclab.location}"
  address_space       = ["172.16.0.0/27"]
}

resource "azurerm_subnet" "tools_vnet_default" {
  name                 = "default"
  resource_group_name  = "${azurerm_resource_group.seclab.name}"
  virtual_network_name = "${azurerm_virtual_network.tools_vnet.name}"
  address_prefix       = "172.16.0.0/27"
}

resource "azurerm_network_security_group" "tools_vnet_default_nsg" {
  name                = "tools-nsg"
  location            = "${azurerm_resource_group.seclab.location}"
  resource_group_name = "${azurerm_resource_group.seclab.name}"

  security_rule {
    name                       = "ALLOW_SSH_FROM_PUBLIC"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "192.168.0.0/29"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "tools_vnet_default_nsg_assc" {
  subnet_id                 = "${azurerm_subnet.tools_vnet_default.id}"
  network_security_group_id = "${azurerm_network_security_group.tools_vnet_default_nsg.id}"
}

resource "azurerm_virtual_network_peering" "tools_vnet_peer_to_public" {
  name                      = "fromToolsToPublic"
  resource_group_name       = "${azurerm_resource_group.seclab.name}"
  virtual_network_name      = "${azurerm_virtual_network.tools_vnet.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.public_vnet.id}"
  depends_on                = ["azurerm_virtual_network.tools_vnet", "azurerm_virtual_network.public_vnet", "azurerm_virtual_network.vuln_vnet", "azurerm_subnet.public_vnet_jumpbox", "azurerm_subnet.tools_vnet_default", "azurerm_subnet.vuln_vnet_public", "azurerm_subnet.vuln_vnet_private"]
}

resource "azurerm_virtual_network_peering" "tools_vnet_peer_to_vuln" {
  name                         = "fromToolsToVuln"
  resource_group_name          = "${azurerm_resource_group.seclab.name}"
  virtual_network_name         = "${azurerm_virtual_network.tools_vnet.name}"
  remote_virtual_network_id    = "${azurerm_virtual_network.vuln_vnet.id}"
  allow_virtual_network_access = true
  depends_on                   = ["azurerm_virtual_network.tools_vnet", "azurerm_virtual_network.public_vnet", "azurerm_virtual_network.vuln_vnet", "azurerm_subnet.public_vnet_jumpbox", "azurerm_subnet.tools_vnet_default", "azurerm_subnet.vuln_vnet_public", "azurerm_subnet.vuln_vnet_private"]
}

##################################################
# Vuln VNET
##################################################
resource "azurerm_virtual_network" "vuln_vnet" {
  name                = "vuln-vnet"
  resource_group_name = "${azurerm_resource_group.seclab.name}"
  location            = "${azurerm_resource_group.seclab.location}"
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "vuln_vnet_private" {
  name                 = "private"
  resource_group_name  = "${azurerm_resource_group.seclab.name}"
  virtual_network_name = "${azurerm_virtual_network.vuln_vnet.name}"
  address_prefix       = "10.0.0.0/28"
}

resource "azurerm_network_security_group" "vuln_vnet_private_nsg" {
  name                = "vuln-private-nsg"
  location            = "${azurerm_resource_group.seclab.location}"
  resource_group_name = "${azurerm_resource_group.seclab.name}"

  security_rule {
    name                       = "DENY_INTERNET_OUTBOUND"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

resource "azurerm_subnet_network_security_group_association" "vuln_vnet_private_nsg_assc" {
  subnet_id                 = "${azurerm_subnet.vuln_vnet_private.id}"
  network_security_group_id = "${azurerm_network_security_group.vuln_vnet_private_nsg.id}"

  # The NSG blocks outbound internet but the VM needs
  # internet access during config
  depends_on = ["azurerm_virtual_machine_extension.vuln_private_vm_ext"]
}

resource "azurerm_subnet" "vuln_vnet_public" {
  name                 = "public"
  resource_group_name  = "${azurerm_resource_group.seclab.name}"
  virtual_network_name = "${azurerm_virtual_network.vuln_vnet.name}"
  address_prefix       = "10.0.0.16/28"
}

resource "azurerm_network_security_group" "vuln_vnet_public_nsg" {
  name                = "vuln-public-nsg"
  location            = "${azurerm_resource_group.seclab.location}"
  resource_group_name = "${azurerm_resource_group.seclab.name}"

  security_rule {
    name                       = "ALLOW_ALL_FROM_TOOLS"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "172.16.0.0/27"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "vuln_vnet_public_nsg_assc" {
  subnet_id                 = "${azurerm_subnet.vuln_vnet_public.id}"
  network_security_group_id = "${azurerm_network_security_group.vuln_vnet_public_nsg.id}"
}

resource "azurerm_virtual_network_peering" "vuln_vnet_peer_to_tools" {
  name                      = "fromVulnToTools"
  resource_group_name       = "${azurerm_resource_group.seclab.name}"
  virtual_network_name      = "${azurerm_virtual_network.vuln_vnet.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.tools_vnet.id}"
  depends_on                = ["azurerm_virtual_network.tools_vnet", "azurerm_virtual_network.public_vnet", "azurerm_virtual_network.vuln_vnet", "azurerm_subnet.public_vnet_jumpbox", "azurerm_subnet.tools_vnet_default", "azurerm_subnet.vuln_vnet_public", "azurerm_subnet.vuln_vnet_private"]
}

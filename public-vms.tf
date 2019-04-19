resource "azurerm_public_ip" "public_vm_public_ip" {
  name                = "${var.public_vm_name}-ip"
  location            = "${var.location}"
  resource_group_name = "${var.rg_name}"
  allocation_method   = "Static"
  depends_on          = ["azurerm_resource_group.seclab"]
}

resource "azurerm_network_interface" "public_vm_nic" {
  name                = "${var.public_vm_name}-nic"
  location            = "${var.location}"
  resource_group_name = "${var.rg_name}"

  ip_configuration {
    name                          = "ipconf1"
    subnet_id                     = "${azurerm_subnet.public_vnet_jumpbox.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.public_vm_public_ip.id}"
  }

  depends_on = ["azurerm_virtual_network.public_vnet"]
}

resource "azurerm_virtual_machine" "public_vm" {
  name                          = "${var.public_vm_name}-vm"
  location                      = "${var.location}"
  resource_group_name           = "${var.rg_name}"
  network_interface_ids         = ["${azurerm_network_interface.public_vm_nic.id}"]
  vm_size                       = "${var.public_vm_sku}"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.public_vm_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "public"
    admin_username = "${var.public_vm_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = "${file("${var.public_vm_ssh_key}")}"
      path     = "/home/${var.public_vm_username}/.ssh/authorized_keys"
    }
  }
}

resource "azurerm_network_interface" "tools_vm_nic" {
  name                = "${var.tools_vm_name}-nic"
  location            = "${var.location}"
  resource_group_name = "${var.rg_name}"

  ip_configuration {
    name                          = "ipconf1"
    subnet_id                     = "${azurerm_subnet.tools_vnet_default.id}"
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = ["azurerm_virtual_network.tools_vnet"]
}

resource "azurerm_virtual_machine" "tools_vm" {
  name                          = "${var.tools_vm_name}-vm"
  location                      = "${var.location}"
  resource_group_name           = "${var.rg_name}"
  network_interface_ids         = ["${azurerm_network_interface.tools_vm_nic.id}"]
  vm_size                       = "${var.tools_vm_sku}"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "kali-linux"
    offer     = "kali-linux"
    sku       = "kali"
    version   = "latest"
  }

  plan {
    name      = "kali"
    product   = "kali-linux"
    publisher = "kali-linux"
  }

  storage_os_disk {
    name              = "${var.tools_vm_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "tools"
    admin_username = "${var.tools_vm_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = "${file("${var.tools_vm_ssh_key}")}"
      path     = "/home/${var.tools_vm_username}/.ssh/authorized_keys"
    }
  }
}

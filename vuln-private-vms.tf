resource "azurerm_network_interface" "vuln_private_vm_nic" {
  name                = "${var.vuln_private_vm_name}-nic"
  location            = "${var.location}"
  resource_group_name = "${var.rg_name}"

  ip_configuration {
    name                          = "ipconf1"
    subnet_id                     = "${azurerm_subnet.vuln_vnet_private.id}"
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = ["azurerm_virtual_network.vuln_vnet"]
}

resource "azurerm_virtual_machine" "vuln_private_vm" {
  name                          = "${var.vuln_private_vm_name}-vm"
  location                      = "${var.location}"
  resource_group_name           = "${var.rg_name}"
  network_interface_ids         = ["${azurerm_network_interface.vuln_private_vm_nic.id}"]
  vm_size                       = "${var.vuln_private_vm_sku}"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vuln_private_vm_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "${var.vuln_private_vm_name}-datadisk"
    caching           = "ReadWrite"
    create_option     = "Empty"
    disk_size_gb      = "20"
    lun               = "0"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name  = "public"
    admin_username = "${var.vuln_private_vm_username}"
    admin_password = "${var.vuln_private_vm_password}"
  }

  os_profile_windows_config {
    provision_vm_agent = "true"
  }
}

resource "azurerm_virtual_machine_extension" "vuln_private_vm_ext" {
  name                 = "CreateADForest"
  location             = "${var.location}"
  resource_group_name  = "${var.rg_name}"
  virtual_machine_name = "${azurerm_virtual_machine.vuln_private_vm.name}"
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.19"

  settings = <<SETTINGS
    {
      "ModulesUrl": "https://raw.github.com/Azure/azure-quickstart-templates/master/active-directory-new-domain/DSC/CreateADPDC.zip",
      "ConfigurationFunction": "CreateADPDC.ps1\\CreateADPDC",
      "Properties": {
        "DomainName": "${var.vuln_private_vm_ad_domain}",
        "AdminCreds": {
          "UserName": "${var.vuln_private_vm_username}",
          "Password": "PrivateSettingsRef:AdminPassword"
        }
      }
    }
SETTINGS

  protected_settings = <<SETTINGS
  {
    "Items": {
      "AdminPassword": "${var.vuln_private_vm_password}"
    }
  }
SETTINGS
}

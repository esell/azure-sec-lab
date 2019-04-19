variable "location" {
  type        = "string"
  description = "Location for Resources"
  default     = "West US"
}

variable "rg_name" {
  type        = "string"
  description = "Resource Group Name"
  default     = "sec-lab-v3"
}

variable "public_vm_name" {
  type        = "string"
  description = "Name for public VM"
  default     = "public"
}

variable "public_vm_sku" {
  type        = "string"
  description = "SKU (size) for public VM"
  default     = "Standard_DS1_v2"
}

variable "public_vm_username" {
  type        = "string"
  description = "Username for public VM"
  default     = "pubuser"
}

variable "public_vm_ssh_key" {
  type        = "string"
  description = "Path to local _public_ SSH key for public VM"
  default     = "~/.ssh/id_rsa.pub"
}

variable "tools_vm_name" {
  type        = "string"
  description = "Name for tools VM"
  default     = "kali"
}

variable "tools_vm_sku" {
  type        = "string"
  description = "SKU (size) for tools VM"
  default     = "Standard_DS1_v2"
}

variable "tools_vm_username" {
  type        = "string"
  description = "Username for tools VM"
  default     = "toolsuser"
}

variable "tools_vm_ssh_key" {
  type        = "string"
  description = "Path to local _public_ SSH key for tools VM"
  default     = "~/.ssh/id_rsa.pub"
}

variable "vuln_private_vm_name" {
  type        = "string"
  description = "Name for vuln private VM"
  default     = "corp-dc"
}

variable "vuln_private_vm_sku" {
  type        = "string"
  description = "SKU (size) for vuln private VM"
  default     = "Standard_D2s_v3"
}

variable "vuln_private_vm_username" {
  type        = "string"
  description = "Username for vuln private VM"
  default     = "dc-admin"
}

variable "vuln_private_vm_password" {
  type        = "string"
  description = "Password for vuln private VM"
  default     = "PleaseChangeMe1234"
}

variable "vuln_private_vm_ad_domain" {
  type        = "string"
  description = "Domain to use for vuln private VM"
  default     = "corp.seclab.com"
}

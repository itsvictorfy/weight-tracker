variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "rg-victor-weightTracker"
}

variable "vnet_name" {
  description = "Name of the Azure virtual network"
  type        = string
  default     = "Vnet-victor-weightTracker"
}

variable "subnet1_name" {
  description = "Name of the Web subnet"
  type        = string
  default     = "web-Subnet"
}

variable "subnet2_name" {
  description = "Name of the db subnet"
  type        = string
  default     = "subndb-subnet"
}

variable "subnet1_prefix" {
  description = "Address prefix for the web subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "subnet2_prefix" {
  description = "Address prefix for the db subnet"
  type        = string
  default     = "10.0.1.0/24"
}

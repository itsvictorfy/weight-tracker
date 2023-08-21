provider "azurerm" {
  features {
    key_vault {
      purge_soft_deleted_secrets_on_destroy = true
      recover_soft_deleted_secrets          = true
    }
  }
}
# service princepel for Vaults
# data "azurerm_client_config" "current" {}

# data "azurerm_key_vault" "keyvault" {
#   name = "Victor-fp-vault"
#   resource_group_name = "rg-finalproj"
#   access_policy {
#     tenant_id = data.azurerm_client_config.current.tenant_id
#     object_id = data.azurerm_client_config.current.object_id

#     key_permissions = [
#       "Create",
#       "Get",
#     ]

#     secret_permissions = [
#       "Set",
#       "Get",
#       "Delete",
#       "Purge",
#       "Recover"
#     ]
#   }
# }

# data "azurerm_key_vault_secret" "sshPass" {
#   name = "sshpass"
#   key_vault_id = data.azurerm_key_vault.keyvault.id
#   timeouts {
#     read = "1m"
#   }
# }

# data "azurerm_key_vault_secret" "sshUser" {
#   name = "sshuser"
#   key_vault_id = data.azurerm_key_vault.keyvault.id
#   timeouts {
#     read = "1m"
#   }
# }

resource "azurerm_resource_group" "weightTracker-rg" {
  name     = var.resource_group_name
  location = "West Europe"
}

resource "azurerm_network_security_group" "web-nsg" {
  name                = "web-nsg"
  location            = azurerm_resource_group.weightTracker-rg.location
  resource_group_name = azurerm_resource_group.weightTracker-rg.name

security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-8080"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "db-nsg" {
  name                = "db-nsg"
  location            = azurerm_resource_group.weightTracker-rg.location
  resource_group_name = azurerm_resource_group.weightTracker-rg.name

security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.1.0/24"
  }

  security_rule {
    name                       = "Allow-psql"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.1.0/24"
  }
}
  
resource "azurerm_virtual_network" "weighttracker-Vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.weightTracker-rg.location
  resource_group_name = azurerm_resource_group.weightTracker-rg.name
}

resource "azurerm_subnet" "web-subnet" {
  name                 = var.subnet1_name
  resource_group_name  = azurerm_resource_group.weightTracker-rg.name
  virtual_network_name = azurerm_virtual_network.weighttracker-Vnet.name
  address_prefixes     = [var.subnet1_prefix]
}

resource "azurerm_subnet" "db-subnet" {
  name                 = var.subnet2_name
  resource_group_name  = azurerm_resource_group.weightTracker-rg.name
  virtual_network_name = azurerm_virtual_network.weighttracker-Vnet.name
  address_prefixes     = [var.subnet2_prefix]
}

resource "azurerm_subnet_network_security_group_association" "db-nsg-assosiaction" {
  subnet_id = azurerm_subnet.db-subnet.id
  network_security_group_id = azurerm_network_security_group.db-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "web-nsg-assosiaction" {
  subnet_id = azurerm_subnet.web-subnet.id
  network_security_group_id = azurerm_network_security_group.web-nsg.id
}

# resource "azurerm_public_ip" "web_pub_ip" {
#   name = "web-public-ip"
#   resource_group_name = azurerm_resource_group.weightTracker_rg.name
#   location = azurerm_resource_group.weightTracker_rg.location
#   allocation_method = "Static"
# }

resource "azurerm_network_interface" "web-nic" {
  name = "web-nic"
  location = azurerm_resource_group.weightTracker-rg.location
  resource_group_name = azurerm_resource_group.weightTracker-rg.name
  ip_configuration {
    name = "web-nic-test"
    subnet_id = azurerm_subnet.web-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "db-nic" {
  name = "db-nic"
  location = azurerm_resource_group.weightTracker-rg.location
  resource_group_name = azurerm_resource_group.weightTracker-rg.name
  ip_configuration {
    name = "db-nic-test"
    subnet_id = azurerm_subnet.db-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "test_web_nic" {
  name = "web2-nic"
  location = azurerm_resource_group.weightTracker_rg.location
  resource_group_name = azurerm_resource_group.weightTracker_rg.name
  ip_configuration {
    name = "web-nic-test"
    subnet_id = azurerm_subnet.web_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "test_web_vm" {
  name = "vm-weighttracker-web2"
  location = azurerm_resource_group.weightTracker_rg.location
  resource_group_name = azurerm_resource_group.weightTracker_rg.name
  network_interface_ids = [ azurerm_network_interface.test_web_nic.id ]
  vm_size = "Standard_DS1_v2"
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "webdisktest"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "vm-weighttracker-web"
    admin_username = "sshuser"
    admin_password = "sshPassword123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  connection {
    type     = "ssh"
    user     = "sshuser"
    password = "sshPassword123"
    # host     = azurerm_public_ip.web_pub_ip.ip_address
    timeout = "40s"
  }
}

resource "azurerm_virtual_machine" "web_vm" {
  name = "vm-weighttracker-web"
  location = azurerm_resource_group.weightTracker_rg.location
  resource_group_name = azurerm_resource_group.weightTracker_rg.name
  network_interface_ids = [ azurerm_network_interface.web_nic.id ]
  vm_size = "Standard_DS1_v2"
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "webdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "vm-weighttracker-web"
    admin_username = "sshuser"
    admin_password = "sshPassword123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  connection {
    type     = "ssh"
    user     = "sshuser"
    password = "sshPassword123"
    # host     = azurerm_public_ip.web_pub_ip.ip_address
    timeout = "40s"
  }
}

resource "azurerm_storage_account" "sa-weighttracket-db" {
  name = "testweighttracker"
  location = azurerm_resource_group.weightTracker-rg.location
  resource_group_name = azurerm_resource_group.weightTracker-rg.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_managed_disk" "db-volume" {
  name= "db-volume"
  location = azurerm_resource_group.weightTracker-rg.location
  resource_group_name = azurerm_resource_group.weightTracker-rg.name
  storage_account_type = "Standard_LRS"
  create_option = "Empty"
  disk_size_gb = 4
  storage_account_id = azurerm_storage_account.sa-weighttracket-db.id
}

resource "azurerm_virtual_machine" "db-vm" {
  name = "vm-weighttracker-db"
  location = azurerm_resource_group.weightTracker-rg.location
  resource_group_name = azurerm_resource_group.weightTracker-rg.name
  network_interface_ids = [azurerm_network_interface.db-nic.id]
  vm_size = "Standard_DS1_v2"
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "dbdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "vm-weighttracker-db"
    admin_username = "sshuser"
    admin_password = "sshPassword123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  connection {
    type     = "ssh"
    user     = "sshuser"
    password = "sshPassword123"
    host = azurerm_network_interface.db-nic.private_ip_address
    timeout = "40s"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "db-to-Volume" {
    managed_disk_id = azurerm_managed_disk.db-volume.id
    virtual_machine_id = azurerm_virtual_machine.db-vm.id
    lun = 0
    caching = "None"
}

resource "azurerm_virtual_machine_extension" "web-init" {
  name = "wb-init-script"
  virtual_machine_id = azurerm_virtual_machine.web-vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
  {
    "commandToExecute": "git clone https://gitlab.com/sela-1090/students/itsvictorfy/terraform.git && bash terraform/webSerInstall.sh"
  }
  SETTINGS
}

resource "azurerm_virtual_machine_extension" "web2_init" {
  name = "web2-init-script"
  virtual_machine_id = azurerm_virtual_machine.test_web_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
  {
    "commandToExecute": "git clone https://gitlab.com/sela-1090/students/itsvictorfy/terraform.git && bash terraform/webSerInstall.sh"
  }
  SETTINGS
}

resource "azurerm_virtual_machine_extension" "db_init" {
  name = "db-init-script"
  virtual_machine_id = azurerm_virtual_machine.db-vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  
  settings = <<SETTINGS
  {
    "commandToExecute": "git clone https://gitlab.com/sela-1090/students/itsvictorfy/terraform.git && bash terraform/psqlSerInstall.sh"
  }
  SETTINGS
  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.db-to-Volume,
    azurerm_virtual_machine.db-vm,
  ]

}

resource "azurerm_public_ip" "lb_pub_ip" {
  name                = "load-ip"
  location            = azurerm_resource_group.weightTracker_rg.location
  resource_group_name = azurerm_resource_group.weightTracker_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb_web" {
  name                = "app-balancer"
  location            = azurerm_resource_group.weightTracker_rg.location
  resource_group_name = azurerm_resource_group.weightTracker_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.lb_pub_ip.id
  }
  depends_on = [ 
    azurerm_public_ip.lb_pub_ip
    ]
}
resource "azurerm_lb_backend_address_pool" "PoolA" {
  loadbalancer_id = azurerm_lb.lb_web.id
  name            = "PoolA"
  depends_on = [ 
    azurerm_lb.lb_web
   ]
}

resource "azurerm_lb_backend_address_pool_address" "web_vm1" {
  name                                = "web-vm1"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.PoolA.id
  virtual_network_id                  = azurerm_virtual_network.weighttracker_Vnet.id
  ip_address                          = azurerm_network_interface.test_web_nic.private_ip_address
}

resource "azurerm_lb_backend_address_pool_address" "web_vm2" {
  name                                = "web-vm2"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.PoolA.id
  virtual_network_id                  = azurerm_virtual_network.weighttracker_Vnet.id
  ip_address                          = azurerm_network_interface.web_nic.private_ip_address
}

resource "azurerm_lb_probe" "ProbeA" {
  loadbalancer_id      = azurerm_lb.lb_web.id
  name                 = "ProbeA"
  port                 = 8080
}

resource "azurerm_lb_rule" "RuleA" {
  loadbalancer_id                = azurerm_lb.lb_web.id
  name                           = "RulaA"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8080
  frontend_ip_configuration_name = "frontend-ip"
  probe_id                       = azurerm_lb_probe.ProbeA.id
  backend_address_pool_ids       = ["${ azurerm_lb_backend_address_pool.PoolA.id}"]
}

resource "azurerm_lb_probe" "ProbeB" {
  loadbalancer_id      = azurerm_lb.lb_web.id
  name                 = "ProbeB"
  port                 = 22
}

resource "azurerm_lb_rule" "RuleB" {
  loadbalancer_id                = azurerm_lb.lb_web.id
  name                           = "RulaB"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "frontend-ip"
  probe_id                       = azurerm_lb_probe.ProbeA.id
  backend_address_pool_ids       = ["${ azurerm_lb_backend_address_pool.PoolA.id}"]
}

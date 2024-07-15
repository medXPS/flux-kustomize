# Define the virtual network
resource "azurerm_virtual_network" "default" {
  name                = "adria-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rc-gp.location
  resource_group_name = data.azurerm_resource_group.rc-gp.name
  

  tags = data.azurerm_resource_group.rc-gp.tags
}

# Define the network security group
resource "azurerm_network_security_group" "ci_cd_nsg" {
  name                = "adria-nsg"
  location            = data.azurerm_resource_group.rc-gp.location
  resource_group_name = data.azurerm_resource_group.rc-gp.name
  tags                = data.azurerm_resource_group.rc-gp.tags
}

# Define the subnet
resource "azurerm_subnet" "default" {
  name                 = "adria-subnet"
  resource_group_name  = data.azurerm_resource_group.rc-gp.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Define the network interface
resource "azurerm_network_interface" "ci_cd_nic" {
  name                = "adria-nic"
  location            = data.azurerm_resource_group.rc-gp.location
  resource_group_name = data.azurerm_resource_group.rc-gp.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Define the public IP address
resource "azurerm_public_ip" "ci_cd_public_ip" {
  name                = "adria-public-ip"
  location            = data.azurerm_resource_group.rc-gp.location
  resource_group_name = data.azurerm_resource_group.rc-gp.name
  
  allocation_method   = "Dynamic"

  tags                = data.azurerm_resource_group.rc-gp.tags
}

# Define the virtual machine
resource "azurerm_virtual_machine" "ci_cd_vm" {
  name                  = "adria-vm"
  location              = data.azurerm_resource_group.rc-gp.location
  resource_group_name   = data.azurerm_resource_group.rc-gp.name
  network_interface_ids = [azurerm_network_interface.ci_cd_nic.id]
  vm_size               = "Standard_D2_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "adria-vm-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "adria-vm"
    admin_username = "adria"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/adria/.ssh/authorized_keys"
      key_data = file("./id_rsa.pub")
    }
  }

  tags = data.azurerm_resource_group.rc-gp.tags
}

# Define network security rules
resource "azurerm_network_security_rule" "allow_8081" {
  name                        = "Allow_TCP_8081"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 8081
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rc-gp.name
  network_security_group_name = azurerm_network_security_group.ci_cd_nsg.name
}

resource "azurerm_network_security_rule" "allow_8080" {
  name                        = "Allow_TCP_8080"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 8080
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rc-gp.name
  network_security_group_name = azurerm_network_security_group.ci_cd_nsg.name
}

resource "azurerm_network_security_rule" "allow_22" {
  name                        = "Allow_TCP_22"
  priority                    = 1004
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rc-gp.name
  network_security_group_name = azurerm_network_security_group.ci_cd_nsg.name
}

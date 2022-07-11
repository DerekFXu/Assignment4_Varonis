#Setting up the network for VMs
resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "example" {
  name                = "${var.prefix}-network"
  resource_group_name = "${azurerm_resource_group.example.name}"
  location            = "${azurerm_resource_group.example.location}"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  virtual_network_name = "${azurerm_virtual_network.example.name}"
  resource_group_name  = "${azurerm_resource_group.example.name}"
  address_prefixes     = ["10.0.1.0/24"]
}


#Creating Load Balancer resources
locals {
  frontend_ip_configuration_name = "internal"
}

resource "azurerm_public_ip" "example" {
  name                = "${var.prefix}-publicip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.prefix}-public-ip"
}
resource "azurerm_lb" "example" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_lb_backend_address_pool" "example" {
  name                = "backend"
  loadbalancer_id     = azurerm_lb.example.id
}

resource "azurerm_lb_probe" "example" {
  name                = "probe"
  loadbalancer_id     = azurerm_lb.example.id
  protocol            = "Tcp"
  port                = 80
}

resource "azurerm_lb_rule" "example" {
  name                           = "http-lb-rule"
  loadbalancer_id                = azurerm_lb.example.id
  probe_id                       = azurerm_lb_probe.example.id
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.example.id]
  frontend_ip_configuration_name = local.frontend_ip_configuration_name
  protocol                       = "Tcp"
  frontend_port                  = "80"
  backend_port                   = "80"
}

#Creating the virtual machines with proper networking and load balancer
resource "azurerm_linux_virtual_machine_scale_set" "example" {
  name                = "${var.prefix}-vmss"
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"
  sku                 = "Standard_B1s"
  instances           = 2
  admin_username      = "adminuser"
  admin_password       = "123Pass!"
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.example.id
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.example.id}"]
    }
  }
}
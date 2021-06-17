terraform {
	backend "azurerm" {
		resource_group_name   = "investec-rg"
		storage_account_name  = "storageaccinvestec"
		container_name        = "infrastructure-state"
		key                   = "terraform.tfstate"
	}
}

terraform {
	required_providers {
		azurerm = {
			source = "hashicorp/azurerm"
			version = ">=2.61"
		}
	}
}

provider "azurerm" {
	skip_provider_registration = true
	subscription_id = "4c6f13d0-c28c-4ef4-bfad-fc01aa7a7479"

	features {}
}

variable "test_admin_pw" {
	type			= string
	description		= "The password for the test-admin user. Should be specified as an environment variable TF_VAR_test_admin_pw."
	
	validation {
		condition 		= length(var.test_admin_pw) > 8
		error_message 	= "A password for the test-admin is required to be set as an environment variable called TF_VAR_test_admin_pw with a minimum length of 8 characters."
	}
}

resource "azurerm_resource_group" "test_rg" {                                              
    location = "southafricanorth"                                                              
    name     = "test-rg" 
	tags = {
		environment = "mornemaritz-test"
	}
}                                                                                              


/*
====================================================================================================
	NETWORKING
====================================================================================================
*/

resource "azurerm_virtual_network" "test_vnet" {
    address_space       = [
        "10.0.1.0/24",
    ]
    name                = "test-vnet"
    resource_group_name = azurerm_resource_group.test_rg.name
	location           	= azurerm_resource_group.test_rg.location
}

resource "azurerm_subnet" "test_primary_subnet" {
	name                							= "test-primary-subnet"
	address_prefixes    							= ["10.0.1.0/26"]
	enforce_private_link_endpoint_network_policies 	= false
	enforce_private_link_service_network_policies  	= false
	resource_group_name   							= azurerm_resource_group.test_rg.name
	virtual_network_name  							= azurerm_virtual_network.test_vnet.name
}

resource "azurerm_subnet" "test_web_subnet" {
	name                							= "test-web-subnet"
	address_prefixes    							= ["10.0.1.64/26"]
	enforce_private_link_endpoint_network_policies 	= false
	enforce_private_link_service_network_policies  	= false
	resource_group_name   							= azurerm_resource_group.test_rg.name
	virtual_network_name  							= azurerm_virtual_network.test_vnet.name
}

resource "azurerm_private_dns_zone" "test_private_dns_zone" {
	name                = "mornemaritz.org"
	resource_group_name = azurerm_resource_group.test_rg.name

	tags = {
		environment = "mornemaritz-test"
	}
}

resource "azurerm_private_dns_zone_virtual_network_link" "test_dns_zone_network_link" {
	name                  	= "test-dns-zone-network-link"
	resource_group_name 	= azurerm_resource_group.test_rg.name
	private_dns_zone_name 	= azurerm_private_dns_zone.test_private_dns_zone.name
	virtual_network_id    	= azurerm_virtual_network.test_vnet.id
	registration_enabled	= true

	tags = {
		environment = "mornemaritz-test"
	}
}

/*
====================================================================================================
	WEB SERVER
====================================================================================================
*/

resource "azurerm_public_ip" "test_web_public_ip" {

	name               	= "test-web-public-ip"
	location           	= azurerm_resource_group.test_rg.location
	resource_group_name	= azurerm_resource_group.test_rg.name
	allocation_method  	= "Dynamic"
	domain_name_label  	= "test-web"

	tags = {
		environment = "mornemaritz-test"
	}
}

resource "azurerm_network_interface" "test_web_nic" {
	name                  			= "test-web-nic"
	location              			= azurerm_resource_group.test_rg.location
	resource_group_name   			= azurerm_resource_group.test_rg.name

	ip_configuration {
		name                        	= "test-web-nic-config"
		subnet_id                   	= azurerm_subnet.test_web_subnet.id
		private_ip_address_allocation 	= "Dynamic"
		public_ip_address_id        	= azurerm_public_ip.test_web_public_ip.id 
	}

	tags = {
		environment = "mornemaritz-test"
	}
}

resource "azurerm_network_security_group" "test_web_nsg" {
	name                = "test-web-nsg"
	resource_group_name = azurerm_resource_group.test_rg.name
	location            = azurerm_resource_group.test_rg.location
	security_rule       = [
        {
            access                                     = "Allow"
            destination_address_prefix                 = "*"
            destination_address_prefixes               = []
            destination_application_security_group_ids = []
            destination_port_range                     = "3389"
            destination_port_ranges                    = []
            direction                                  = "Inbound"
            name                                       = "RDP"
            priority                                   = 100
            protocol                                   = "*"
            source_address_prefix                      = ""
            description                                = "102.65.187.160=MM"
            source_address_prefixes                    = [
                "102.65.187.160"
			]
            source_application_security_group_ids      = []
            source_port_range                          = "*"
            source_port_ranges                         = []
        },
        {
            access                                     = "Allow"
            description                                = ""
            destination_address_prefix                 = "*"
            destination_address_prefixes               = []
            destination_application_security_group_ids = []
            destination_port_range                     = "443"
            destination_port_ranges                    = []
            direction                                  = "Inbound"
            name                                       = "https"
            priority                                   = 110
            protocol                                   = "*"
            source_address_prefix                      = "*"
            source_address_prefixes                    = []
            source_application_security_group_ids      = []
            source_port_range                          = "*"
            source_port_ranges                         = []
        },
        {
            access                                     = "Allow"
            description                                = ""
            destination_address_prefix                 = "*"
            destination_address_prefixes               = []
            destination_application_security_group_ids = []
            destination_port_range                     = "80"
            destination_port_ranges                    = []
            direction                                  = "Inbound"
            name                                       = "http"
            priority                                   = 120
            protocol                                   = "*"
            source_address_prefix                      = "*"
            source_address_prefixes                    = []
            source_application_security_group_ids      = []
            source_port_range                          = "*"
            source_port_ranges                         = []
        }
	]

	tags = {
		environment = "mornemaritz-test"
	}
}

resource "azurerm_network_interface_security_group_association" "test_web_nic_to_nsg" {
  network_interface_id      = azurerm_network_interface.test_web_nic.id
  network_security_group_id = azurerm_network_security_group.test_web_nsg.id
}

resource "azurerm_windows_virtual_machine" "test_web_vm" {
	name                	= "test-web-vm"
	resource_group_name 	= azurerm_resource_group.test_rg.name
	location            	= azurerm_resource_group.test_rg.location
	size                	= "Standard_B2s" # 2 vcpu 4GiB memory "Standard_B4ms" # 4 vcpu 16GiB memory "Standard_B1s" # 1 vcpu 1GiB ram
	computer_name			= "test-web"
	admin_username      	= "test-admin"
	admin_password      	= var.test_admin_pw 
	network_interface_ids 	= [
		azurerm_network_interface.test_web_nic.id,
	]

	os_disk {
		caching              	= "ReadWrite"
		storage_account_type 	= "Standard_LRS"
		name					= "test-web-os-disk"
	}

	source_image_reference {
		publisher = "MicrosoftWindowsServer"
		offer     = "WindowsServer"
		sku       = "2016-Datacenter"
		version   = "latest"
	}

	tags = {
		environment = "mornemaritz-test"
	}
}
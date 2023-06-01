
provider "azurerm" {
  features {}
}

module "configuration" {
  source = "./configuration"

  project = "nexidia"
  environment = "dev"
  location = "West US"
}

module "resource-group" {
  source = "./modules/resource-group"

  resource-group-name     = "rg-${module.configuration.project}-${module.configuration.environment}"
  resource-group-location = module.configuration.location
}

module "vnet-public"{
  source = "./modules/virtual-network"

  virtual-network-name    = "vnet-public-${module.configuration.project}-${module.configuration.environment}"
  resource-group-name     = module.resource-group.name
  resource-group-location = module.resource-group.location
  address-space           = "10.0.0.0/16"
}

module "subnet-public-jumpbox" {
  source = "./modules/subnet"

  resource-group-name = module.resource-group.name
  virtual-network-name= module.vnet-public.name
  subnet-name         = "snet-public-jumpbox-${module.configuration.project}-${module.configuration.environment}"
  address-prefixes    = "10.0.0.0/24"
}

module "nsg-vnet-public-jumpbox" {
  source = "./modules/network-security-group"

  nsg-name                   = "nsg-vnet-public-jumpbox-${module.configuration.project}-${module.configuration.environment}"
  resource-group-name        = module.resource-group.name
  resource-group-location    = module.resource-group.location
  
  security_rules = [
    {
      name                       = "allowpublicssh"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "49.0.0.0/8"
      destination_address_prefix = "*"
    },
    {
      name                       = "DenyAll"
      priority                   = 300
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

module "nsg-associate-public-jumpbox" {
  source = "./modules/nsg-associate"

  network-security-group-id = module.nsg-vnet-public-jumpbox.id
  subnet-id                 = module.subnet-public-jumpbox.id
}

module "vnet-private"{
  source = "./modules/virtual-network"

  virtual-network-name    = "vnet-private-${module.configuration.project}-${module.configuration.environment}"
  resource-group-name     = module.resource-group.name
  resource-group-location = module.resource-group.location
  address-space           = "10.1.0.0/16"
}

module "subnet-private-adsync" {
  source = "./modules/subnet"

  resource-group-name = module.resource-group.name
  virtual-network-name= module.vnet-private.name
  subnet-name         = "snet-private-adsync-${module.configuration.project}-${module.configuration.environment}"
  address-prefixes    = "10.1.0.0/24"
}

module "subnet-private-node" {
  source = "./modules/subnet"

  resource-group-name = module.resource-group.name
  virtual-network-name= module.vnet-private.name
  subnet-name         = "snet-private-node-${module.configuration.project}-${module.configuration.environment}"
  address-prefixes    = "10.1.1.0/24"
}

module "nsg-vnet-private-adsync" {
  source = "./modules/network-security-group"

  nsg-name                   = "nsg-vnet-private-adsync-${module.configuration.project}-${module.configuration.environment}"
  resource-group-name        = module.resource-group.name
  resource-group-location    = module.resource-group.location
  
  security_rules = [
    {
      name                       = "allowjumpboxssh"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "10.0.0.4/32"
      destination_address_prefix = "*"
    },
    {
      name                       = "DenyAll"
      priority                   = 300
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

module "nsg-associate-private-adsync" {
  source = "./modules/nsg-associate"

  network-security-group-id = module.nsg-vnet-private-adsync.id
  subnet-id                 = module.subnet-private-adsync.id
}

module "nsg-vnet-private-node" {
  source = "./modules/network-security-group"

  nsg-name                   = "nsg-vnet-private-node-${module.configuration.project}-${module.configuration.environment}"
  resource-group-name        = module.resource-group.name
  resource-group-location    = module.resource-group.location
  
  security_rules = [
    {
      name                       = "allowadsyncssh"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "10.1.0.0/24"
      destination_address_prefix = "*"
    },
    {
      name                       = "DenyAll"
      priority                   = 300
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

module "nsg-associate-private-node" {
  source = "./modules/nsg-associate"

  network-security-group-id = module.nsg-vnet-private-node.id
  subnet-id                 = module.subnet-private-node.id
}

module "vm-jumpbox" {
    source = "./modules/virtual-machine"
    name = "vm-jumpbox-${module.configuration.project}-${module.configuration.environment}"
    location = module.resource-group.location
    resource-group-name = module.resource-group.name
    nic-id = module.nic-public-jumpbox.nic_id
    admin-username = "bestengineer"
    admin-password = "Intern100%"
}

module "nic-public-jumpbox" {
    source = "./modules/network-interface"
    location            = module.resource-group.location
    resource_group_name = module.resource-group.name
    subnet_id           = module.subnet-public-jumpbox.id
    name                = "nic-public-jumpbox-${module.configuration.project}-${module.configuration.environment}"
}

module "vm-adsync" {
    source = "./modules/virtual-machine"
    name = "vm-adsync-${module.configuration.project}-${module.configuration.environment}"
    location = module.resource-group.location
    resource-group-name = module.resource-group.name
    nic-id = module.nic-private-adsync.nic_id
    admin-username = "bestengineer"
    admin-password = "Intern100%"
}

module "nic-private-adsync" {
    source = "./modules/network-interface"
    location            = module.resource-group.location
    resource_group_name = module.resource-group.name
    subnet_id           = module.subnet-private-adsync.id
    name                = "nic-private-adsync-${module.configuration.project}-${module.configuration.environment}"
}

module "vm-node" {
    source = "./modules/virtual-machine"
    name = "vm-node-${module.configuration.project}-${module.configuration.environment}"
    location = module.resource-group.location
    resource-group-name = module.resource-group.name
    nic-id = module.nic-private-node.nic_id
    admin-username = "bestengineer"
    admin-password = "Intern100%"
}

module "nic-private-node" {
    source = "./modules/network-interface"
    location            = module.resource-group.location
    resource_group_name = module.resource-group.name
    subnet_id           = module.subnet-private-node.id
    name                = "nic-private-node-${module.configuration.project}-${module.configuration.environment}"
}
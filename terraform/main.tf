
provider "azurerm" {
  features {}
}

variable "project" {}
variable "environment" {}
variable "location" {}
variable "location2" {}

module "resource-group" {
  source = "./modules/resource-group"

  resource-group-name     = "rg-${var.project}-${var.environment}"
  resource-group-location = var.location
}

module "vnet-public"{
  source = "./modules/virtual-network"

  virtual-network-name    = "vnet-public-${var.project}-${var.environment}"
  resource-group-name     = module.resource-group.name
  resource-group-location = var.location
  address-space           = "192.168.1.0/24"
}

module "subnet-public-jumpbox" {
  source = "./modules/subnet"

  resource-group-name = module.resource-group.name
  virtual-network-name= module.vnet-public.name
  subnet-name         = "snet-public-jumpbox-${var.project}-${var.environment}"
  address-prefixes    = "192.168.1.0/24"
}

module "nsg-vnet-public-jumpbox" {
  source = "./modules/network-security-group"

  nsg-name                   = "nsg-vnet-public-jumpbox-${var.project}-${var.environment}"
  resource-group-name        = module.resource-group.name
  resource-group-location    = module.vnet-public.location
  
  security_rules = [
    {
      name                       = "allowpublicssh"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "172.0.0.0/8"
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

  virtual-network-name    = "vnet-private-${var.project}-${var.environment}"
  resource-group-name     = module.resource-group.name
  resource-group-location = var.location2
  address-space           = "192.168.2.0/24"
}

module "subnet-private-adsync" {
  source = "./modules/subnet"

  resource-group-name = module.resource-group.name
  virtual-network-name= module.vnet-private.name
  subnet-name         = "snet-private-adsync-${var.project}-${var.environment}"
  address-prefixes    = "192.168.2.0/25"
}

module "subnet-private-node" {
  source = "./modules/subnet"

  resource-group-name = module.resource-group.name
  virtual-network-name= module.vnet-private.name
  subnet-name         = "snet-private-node-${var.project}-${var.environment}"
  address-prefixes    = "192.168.2.128/25"
}

module "nsg-vnet-private-adsync" {
  source = "./modules/network-security-group"

  nsg-name                   = "nsg-vnet-private-adsync-${var.project}-${var.environment}"
  resource-group-name        = module.resource-group.name
  resource-group-location    = module.vnet-private.location
  
  security_rules = [
    {
      name                       = "allowjumpboxssh"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "192.168.1.0/24"
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

  nsg-name                   = "nsg-vnet-private-node-${var.project}-${var.environment}"
  resource-group-name        = module.resource-group.name
  resource-group-location    = module.vnet-private.location
  
  security_rules = [
    {
      name                       = "allowadsyncssh"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "192.168.2.0/25"
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

module "vnet-peer-public" {
  source = "./modules/vnet-perring"

  name = "vnet-peering-public-private-${var.project}-${var.environment}"
  resource-group-name = module.resource-group.name
  vnet-name = module.vnet-public.name
  vnet-id = module.vnet-private.id
}

module "vnet-peer-private" {
  source = "./modules/vnet-perring"

  name = "vnet-peering-private-public-${var.project}-${var.environment}"
  resource-group-name = module.resource-group.name
  vnet-name = module.vnet-private.name
  vnet-id = module.vnet-public.id
}

module "pip-jumpbox" {
  source = "./modules/public-ip"

  pip-name                = "pip-jumpbox-${var.project}-${var.environment}"
  resource-group-name     = module.resource-group.name
  resource-group-location = module.vnet-public.location
  allocation-method       = "Static"
  sku-name                = "Standard"
}

module "vm-jumpbox" {
    source = "./modules/virtual-machine"
    name = "vm-jumpbox-${var.project}-${var.environment}"
    location = module.vnet-public.location
    resource-group-name = module.resource-group.name
    nic-id = module.nic-public-jumpbox.nic_id
    admin-username = "bestengineer"
    admin-password = "Intern100%"
}

module "nic-public-jumpbox" {
    source = "./modules/network-interface"
    location            = module.vnet-public.location
    resource_group_name = module.resource-group.name
    subnet_id           = module.subnet-public-jumpbox.id
    name                = "nic-public-jumpbox-${var.project}-${var.environment}"
    public-ip-id = module.pip-jumpbox.id
}

module "vm-adsync" {
    source = "./modules/virtual-machine"
    name = "vm-adsync-${var.project}-${var.environment}"
    location = module.vnet-private.location
    resource-group-name = module.resource-group.name
    nic-id = module.nic-private-adsync.nic_id
    admin-username = "bestengineer"
    admin-password = "Intern100%"
}

module "nic-private-adsync" {
    source = "./modules/network-interface"
    location            = module.vnet-private.location
    resource_group_name = module.resource-group.name
    subnet_id           = module.subnet-private-adsync.id
    name                = "nic-private-adsync-${var.project}-${var.environment}"
}

module "vm-node" {
    source = "./modules/virtual-machine"
    name = "vm-node-${var.project}-${var.environment}"
    location = module.vnet-private.location
    resource-group-name = module.resource-group.name
    nic-id = module.nic-private-node.nic_id
    admin-username = "bestengineer"
    admin-password = "Intern100%"
}

module "nic-private-node" {
    source = "./modules/network-interface"
    location            = module.vnet-private.location
    resource_group_name = module.resource-group.name
    subnet_id           = module.subnet-private-node.id
    name                = "nic-private-node-${var.project}-${var.environment}"
}
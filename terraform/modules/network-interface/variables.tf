# variables.tf file of network-interface module
variable "name" {
    type = string
}
variable "location" {
    type = string
    description = "Azure location"
}
variable "resource_group_name" {
    type = string
    description = "name of the resource group"
}
variable "subnet_id" {
    type = string
    description = "id of the subnet"
}
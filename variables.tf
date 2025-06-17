variable "rgname" {
    type = string
    description = "resource group name"
}

variable "location" {
    type = string
    default = "canadacentral"
}

variable "service_principle_name" {
  type = string
}

variable "keyvault_name" {
  type = string
}

variable "SUB_ID" {
  type = string
}
variable "image_name" {}
variable "image_folder" {}

variable "DC_name" {}

variable "SQL_1_name" {}
variable "SQL_2_name" {}

variable "domainAdminPass" {
    type = string
    default = "1 Horse Battery Staple"
}

# Domain Configuration
variable "domainName" {
    type = string
    default = "aurora.local"
}

variable "domainNetbiosName" {
    type = string
    default = "aurora"
}

variable "domainSafeModePass" {
    type = string
    default = "1 Horse Battery Staple"
}

variable "domainAccountUser" {
    type = string
    default = "adam"
}

variable "domainAccountPassword" {
    type = string
    default = "Pass@123"
}

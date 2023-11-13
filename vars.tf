variable "vpc" {}       # vpc from env-dev/main.tfvars
variable "env" {}       # env
variable "app" {}       # list of app servers
variable "bastion_cidr" {}
variable "default_vpc_id" {}
variable "default_vpc_route_id" {}
variable "default_vpc_cidr" {}
variable "docdb" {}
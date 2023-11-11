module "vpc" { # calling the vpc module from git
  source     = "git::https://github.com/bairupavan/tf-module-vpc.git"
  for_each   = var.vpc                  # repeating for vpc from env-dev/main.tfvars
  cidr_block = each.value["cidr_block"] # sending the cidr_block (from var vpc) as input to the git tf-module-vpc
  subnets    = each.value["subnets"]    # sending the each subnet (from var vpc) as input to the git tf-module-vpc
  env        = var.env                  # env
  tags       = local.tags               # tags from local
}
#
module "app" {
  source   = "git::https://github.com/bairupavan/tf-module-app.git"
  for_each = var.app

  # these variables are from env-dev/main.tfvars - app {}
  instance_type    = each.value["instance_type"]
  name             = each.value["name"]
  desired_capacity = each.value["desired_capacity"]
  max_size         = each.value["max_size"]
  min_size         = each.value["min_size"]

  # general variables
  env          = var.env
  bastion_cidr = var.bastion_cidr

  # sending these from the env-dev/main.tfvars vpc {}
  subnet_ids     = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  vpc_id         = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  allow_app_cidr = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_app_cidr"], null), "subnet_cidrs", null)
}

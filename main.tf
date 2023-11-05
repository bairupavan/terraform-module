module "vpc" { # calling the vpc module from git
  source     = "git::https://github.com/bairupavan/tf-module-vpc.git"
  for_each   = var.vpc                  # repeating for vpc from env-dev/main.tfvars
  cidr_block = each.value["cidr_block"] # sending the cidr_block (from var vpc) as input to the git tf-module-vpc
  subnets    = each.value["subnets"]    # sending the each subnet (from var vpc) as input to the git tf-module-vpc
  env        = var.env                  # env
  tags       = local.tags               # tags from local
}

module "web" {
  source = "git::https://github.com/bairupavan/tf-module-app.git"
  for_each = var.app
  instance_type = each.value["instance_type"]
  env = var.env
  subnet_id = element(lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null),each.value["subnet_name"], null), "subnet_ids", null), 0)
}
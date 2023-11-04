module "vpc" { # calling the vpc module from git
  source     = "git::https://github.com/bairupavan/tf-module-vpc.git"
  for_each   = var.vpc                  # repeating for vpc from env-dev/main.tfvars
  cidr_block = each.value["cidr_block"] # sending the cidr_block (from var vpc) as input to the git tf-module-vpc
  subnets    = each.value["subnets"]    # sending the each subnet (from var vpc) as input to the git tf-module-vpc
  env        = var.env                  # env
  tags       = local.tags               # tags from local
}
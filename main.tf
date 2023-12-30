module "vpc" { # calling the vpc module from git
  source               = "git::https://github.com/bairupavan/tf-module-vpc.git"
  for_each             = var.vpc                  # repeating for vpc from env-dev/main.tfvars
  cidr_block           = each.value["cidr_block"] # sending the cidr_block (from var vpc) as input to the git tf-module-vpc
  subnets              = each.value["subnets"]    # sending the each subnet (from var vpc) as input to the git tf-module-vpc
  default_vpc_id       = var.default_vpc_id
  default_vpc_route_id = var.default_vpc_route_id
  default_vpc_cidr     = var.default_vpc_cidr
  env                  = var.env    # env
  tags                 = local.tags # tags from local
}

# sending inputs to docdb
module "docdb" {
  source         = "git::https://github.com/bairupavan/tf-module-docdb.git"
  for_each       = var.docdb
  engine_version = each.value["engine_version"]
  instance_count = each.value["instance_count"]
  instance_class = each.value["instance_class"]

  env  = var.env
  tags = local.tags

  # sending these from the env-dev/main.tfvars vpc {}
  subnet_ids    = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  vpc_id        = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_db_cidr"], null), "subnet_cidrs", null)
}

# sending the inputs for rds
module "rds" {
  source         = "git::https://github.com/bairupavan/tf-module-rds.git"
  for_each       = var.rds
  engine_version = each.value["engine_version"]
  instance_count = each.value["instance_count"]
  instance_class = each.value["instance_class"]

  tags = local.tags
  env  = var.env

  # sending these from the env-dev/main.tfvars vpc {}
  subnet_ids    = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  vpc_id        = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_db_cidr"], null), "subnet_cidrs", null)
}

# sending the inputs for elasticache
module "elasticache" {
  source                  = "git::https://github.com/bairupavan/tf-module-elasticache.git"
  for_each                = var.elasticache
  engine_version          = each.value["engine_version"]
  num_node_groups         = each.value["num_node_groups"]
  replicas_per_node_group = each.value["replicas_per_node_group"]
  node_type               = each.value["node_type"]

  tags = local.tags
  env  = var.env

  # sending these from the env-dev/main.tfvars vpc {}
  subnet_ids    = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  vpc_id        = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_db_cidr"], null), "subnet_cidrs", null)
}

# sending the inputs for rabbitmq
module "rabbitmq" {
  source        = "git::https://github.com/bairupavan/tf-amazon-mq.git"
  for_each      = var.rabbitmq
  instance_type = each.value["instance_type"]

  tags         = local.tags
  env          = var.env
  bastion_cidr = var.bastion_cidr

  # sending these from the env-dev/main.tfvars vpc {}
  subnet_ids    = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  vpc_id        = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  allow_db_cidr = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_db_cidr"], null), "subnet_cidrs", null)
}

module "alb" {
  source   = "git::https://github.com/bairupavan/tf-module-alb.git"
  for_each = var.alb
  internal = each.value["internal"]
  name     = each.value["name"]

  tags = local.tags
  env  = var.env

  # sending these from the env-dev/main.tfvars vpc {}
  subnet_ids     = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  vpc_id         = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  allow_alb_cidr = each.value["name"] == "public" ? ["0.0.0.0/0"] : lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_alb_cidr"], null), "subnet_cidrs", null)
}

module "app" {
  depends_on = [module.vpc, module.docdb, module.rds, module.elasticache, module.rabbitmq, module.alb]
  source     = "git::https://github.com/bairupavan/tf-module-app.git"
  for_each   = var.app

  # these variables are from env-dev/main.tfvars - app {}
  instance_type     = each.value["instance_type"]
  name              = each.value["name"]
  desired_capacity  = each.value["desired_capacity"]
  max_size          = each.value["max_size"]
  min_size          = each.value["min_size"]
  app_port          = each.value["app_port"]
  listener_priority = each.value["listener_priority"]
  dns_name          = each.value["name"] == "frontend" ? each.value["dns_name"] : "${each.value["name"]}-${var.env}"

  # general variables
  env          = var.env
  bastion_cidr = var.bastion_cidr
  tags         = local.tags
  domain_name  = var.domain_name
  domain_id    = var.domain_id

  # sending these from the env-dev/main.tfvars vpc {}
  subnet_ids     = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_name"], null), "subnet_ids", null)
  vpc_id         = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  allow_app_cidr = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["allow_app_cidr"], null), "subnet_cidrs", null)
  listener_arn   = lookup(lookup(module.alb, each.value["lb_type"], null), "listener_arn", null)
  alb_dns_name   = lookup(lookup(module.alb, each.value["lb_type"], null), "dns_name", null)
}

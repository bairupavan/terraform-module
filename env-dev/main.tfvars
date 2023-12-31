env                  = "dev"
bastion_cidr         = ["172.31.28.131/32"]
default_vpc_id       = "vpc-0a1bf336cf22dd9ab"
default_vpc_route_id = "rtb-097d2c148c9b47828"
default_vpc_cidr     = "172.31.0.0/16"
domain_name          = "pavanbairu.tech"
domain_id            = "Z08846229MEF59DJAKAS"
vpc = {
  main = {
    cidr_block = "10.0.0.0/16"
    subnets = {
      public = {
        name       = "public"
        cidr_block = ["10.0.0.0/24", "10.0.1.0/24"]
        azs        = ["us-east-1a", "us-east-1b"]
      }
      web = {
        name       = "web"
        cidr_block = ["10.0.2.0/24", "10.0.3.0/24"]
        azs        = ["us-east-1a", "us-east-1b"]
      }
      app = {
        name       = "app"
        cidr_block = ["10.0.4.0/24", "10.0.5.0/24"]
        azs        = ["us-east-1a", "us-east-1b"]
      }
      db = {
        name       = "db"
        cidr_block = ["10.0.6.0/24", "10.0.7.0/24"]
        azs        = ["us-east-1a", "us-east-1b"]
      }
    }
  }
}

app = {
  frontend = {
    name              = "frontend"
    instance_type     = "t2.micro"
    subnet_name       = "web"
    allow_app_cidr    = "public"
    desired_capacity  = 1
    max_size          = 4
    min_size          = 1
    app_port          = 80
    listener_priority = 1
    lb_type           = "public"
    dns_name          = "dev"
  }
  catalogue = {
    name              = "catalogue"
    instance_type     = "t2.micro"
    subnet_name       = "app"
    allow_app_cidr    = "web"
    desired_capacity  = 1
    max_size          = 4
    min_size          = 1
    app_port          = 8080
    lb_type           = "private"
    listener_priority = 1
  }
}

docdb = {
  main = {
    subnet_name    = "db"
    engine_version = "4.0.0"
    allow_db_cidr  = "app"
    instance_count = 1
    instance_class = "db.t3.medium"
  }
}

rds = {
  main = {
    subnet_name    = "db"
    engine_version = "5.7.mysql_aurora.2.11.2"
    allow_db_cidr  = "app"
    instance_count = 1
    instance_class = "db.t3.small"
  }
}

elasticache = {
  main = {
    subnet_name             = "db"
    engine_version          = "6.x"
    allow_db_cidr           = "app"
    node_type               = "cache.t3.micro"
    num_node_groups         = 1
    replicas_per_node_group = 1
  }
}

rabbitmq = {
  main = {
    subnet_name   = "db"
    allow_db_cidr = "app"
    instance_type = "t3.small"
  }
}

alb = {
  public = {
    name           = "public"
    subnet_name    = "public"
    allow_alb_cidr = null
    internal       = false
  }
  private = {
    name           = "private"
    subnet_name    = "app"
    allow_alb_cidr = "web"
    internal       = true
  }
}


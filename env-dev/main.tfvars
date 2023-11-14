env                  = "dev"
bastion_cidr         = ["172.31.28.131/32"]
default_vpc_id       = "vpc-0a1bf336cf22dd9ab"
default_vpc_route_id = "rtb-097d2c148c9b47828"
default_vpc_cidr     = "172.31.0.0/16"
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
    name             = "frontend"
    instance_type    = "t2.micro"
    subnet_name      = "web"
    allow_app_cidr   = "public"
    desired_capacity = 2
    max_size         = 4
    min_size         = 1
  }
  catalogue = {
    name             = "catalogue"
    instance_type    = "t2.micro"
    subnet_name      = "app"
    allow_app_cidr   = "web"
    desired_capacity = 2
    max_size         = 4
    min_size         = 1
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

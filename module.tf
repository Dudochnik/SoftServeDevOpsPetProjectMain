provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = ".//vpc"
  name   = "Practice VPC"
  cidr   = "10.10.0.0/16"
}

module "public_subnet_a" {
  source            = ".//public_subnet"
  name              = "Public A"
  cidr              = "10.10.0.0/24"
  availability_zone = "us-west-2a"
  vpc_id            = module.vpc.id
  gateway_id        = module.vpc.gateway_id
}
module "public_subnet_b" {
  source            = ".//public_subnet"
  name              = "Public B"
  cidr              = "10.10.42.0/24"
  availability_zone = "us-west-2b"
  vpc_id            = module.vpc.id
  gateway_id        = module.vpc.gateway_id
}
module "public_subnet_c" {
  source            = ".//public_subnet"
  name              = "Public C"
  cidr              = "10.10.84.0/24"
  availability_zone = "us-west-2c"
  vpc_id            = module.vpc.id
  gateway_id        = module.vpc.gateway_id
}

module "private_route_table" {
  source = ".//route_table"
  vpc_id = module.vpc.id
}

module "private_subnet_a" {
  source            = ".//private_subnet"
  name              = "Private A"
  cidr              = "10.10.126.0/24"
  availability_zone = "us-west-2a"
  vpc_id            = module.vpc.id
  route_table_id    = module.private_route_table.id
}
module "private_subnet_b" {
  source            = ".//private_subnet"
  name              = "Private B"
  cidr              = "10.10.168.0/24"
  availability_zone = "us-west-2b"
  vpc_id            = module.vpc.id
  route_table_id    = module.private_route_table.id
}
module "private_subnet_c" {
  source            = ".//private_subnet"
  name              = "Private C"
  cidr              = "10.10.210.0/24"
  availability_zone = "us-west-2c"
  vpc_id            = module.vpc.id
  route_table_id    = module.private_route_table.id
}


module "bastion" {
  source              = ".//ec2"
  name                = "Bastion"
  ami_id              = module.ami.bastion
  key_name            = module.key_pair.key_name
  subnet_ids          = [module.public_subnet_a.id]
  security_group_ids  = [module.bastion_sg.id, module.internal_sg.id]
  associate_public_ip = true
}
module "grafana" {
  source             = ".//ec2"
  name               = "Grafana"
  ami_id             = module.ami.grafana
  key_name           = module.key_pair.key_name
  subnet_ids         = [module.private_subnet_a.id]
  security_group_ids = [module.internal_sg.id]
}
module "prometheus" {
  source             = ".//ec2"
  name               = "Prometheus"
  ami_id             = module.ami.prometheus
  key_name           = module.key_pair.key_name
  subnet_ids         = [module.private_subnet_b.id]
  security_group_ids = [module.internal_sg.id]
}
module "loki" {
  source             = ".//ec2"
  name               = "Loki"
  ami_id             = module.ami.loki
  key_name           = module.key_pair.key_name
  subnet_ids         = [module.private_subnet_c.id]
  security_group_ids = [module.internal_sg.id]
}

module "loki_hosted_zone" {
  source    = ".//hosted_zone"
  name      = "main"
  zone      = "loki.com."
  addresses = module.loki.private_ip
  vpc_id    = module.vpc.id
}

module "cockroachdb" {
  source             = ".//ec2"
  name               = "CockroachDB"
  ami_id             = module.ami.cockroachdb
  key_name           = module.key_pair.key_name
  subnet_ids         = [module.private_subnet_a.id, module.private_subnet_b.id, module.private_subnet_c.id]
  security_group_ids = [module.internal_sg.id]
  instances_count    = 3
  user_data          = file("scripts/cockroachdb_user_data.sh")
  #depends_on = [module.consul_asg]
}
module "cockroachdb_hosted_zone" {
  source    = ".//hosted_zone"
  name      = "main"
  zone      = "cockroachdb.com."
  addresses = module.cockroachdb.private_ip
  vpc_id    = module.vpc.id
}
module "consul_asg" {
  source               = ".//asg"
  ami_id               = module.ami.consul
  launch_template_name = "consul"
  domain_name          = "consul.com"
  security_group_ids   = [module.internal_sg.id]
  subnet_ids           = [module.private_subnet_a.id, module.private_subnet_b.id, module.private_subnet_c.id]
  key_name             = module.key_pair.key_name
  vpc_id               = module.vpc.id
  user_data            = file("scripts/consul_user_data.sh")
  asg_size = {
    min_size         = 0
    max_size         = 0
    desired_capacity = 0
  }
}
module "apache_asg" {
  source               = ".//asg"
  ami_id               = module.ami.apache
  launch_template_name = "apache"
  domain_name          = "apache.com"
  security_group_ids   = [module.internal_sg.id]
  subnet_ids           = [module.private_subnet_a.id, module.private_subnet_b.id, module.private_subnet_c.id]
  key_name             = module.key_pair.key_name
  vpc_id               = module.vpc.id
  user_data            = file("scripts/apache_user_data.sh")
  asg_size = {
    min_size         = 0
    max_size         = 0
    desired_capacity = 0
  }
  target_groups = [module.load_balancer.target_group]
  health_check_type = "ELB"
  #depends_on = [module.cockroachdb]
}

module "load_balancer" {
  source                 = ".//lb"
  autoscaling_group_name = module.apache_asg.asg_name
  is_internal            = false
  name                   = "LoadBalancer"
  security_group_ids     = [module.lb_sg.id]
  subnet_ids             = [module.public_subnet_a.id, module.public_subnet_b.id, module.public_subnet_c.id]
  vpc_id                 = module.vpc.id
}

module "bastion_sg" {
  source = ".//sg"
  name   = "bastion_sg"
  vpc_id = module.vpc.id
  ingress_rules = {
    "ssh" = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress_rules = {
    "all" = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
module "internal_sg" {
  source = ".//sg"
  name   = "internal_sg"
  vpc_id = module.vpc.id
  ingress_rules = {
    "internal" = {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["10.10.0.0/16"]
    }
  }
  egress_rules = {
    "internal" = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["10.10.0.0/16"]
    }
  }
}
module "lb_sg" {
  source = ".//sg"
  name   = "lb_sg"
  vpc_id = module.vpc.id
  ingress_rules = {
    "http" = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress_rules = {
    "all" = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}


module "key_pair" {
  source     = ".//key_pair"
  name       = "general_key"
  public_key = file(".//secrets/general_key.pub")
}

module "ami" {
  source = ".//ami"
}

module "lambda" {
  source             = ".//lambda"
  autoscaling_groups = [module.apache_asg.asg_name, module.consul_asg.asg_name]
  zone_arns          = [module.consul_asg.route53_zone_arn, module.apache_asg.route53_zone_arn]
}

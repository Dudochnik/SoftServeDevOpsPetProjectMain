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

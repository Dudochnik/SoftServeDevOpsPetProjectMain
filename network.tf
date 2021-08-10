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

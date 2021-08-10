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
  target_groups     = [module.load_balancer.target_group]
  health_check_type = "ELB"
}

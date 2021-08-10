module "load_balancer" {
  source                 = "github.com/Dudochnik/SoftServeDevOpsPetProjectModules//lb"
  autoscaling_group_name = module.apache_asg.asg_name
  is_internal            = false
  name                   = "LoadBalancer"
  security_group_ids     = [module.lb_sg.id]
  subnet_ids             = [module.public_subnet_a.id, module.public_subnet_b.id, module.public_subnet_c.id]
  vpc_id                 = module.vpc.id
}

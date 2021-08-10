module "lambda" {
  source             = "github.com/Dudochnik/SoftServeDevOpsPetProjectModules//lambda"
  autoscaling_groups = [module.apache_asg.asg_name, module.consul_asg.asg_name]
  zone_arns          = [module.consul_asg.route53_zone_arn, module.apache_asg.route53_zone_arn]
}

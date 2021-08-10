module "bastion" {
  source              = "github.com/Dudochnik/SoftServeDevOpsPetProjectModules//ec2"
  name                = "Bastion"
  ami_id              = module.ami.bastion
  key_name            = module.key_pair.key_name
  subnet_ids          = [module.public_subnet_a.id]
  security_group_ids  = [module.bastion_sg.id, module.internal_sg.id]
  associate_public_ip = true
}

module "grafana" {
  source             = "github.com/Dudochnik/SoftServeDevOpsPetProjectModules//ec2"
  name               = "Grafana"
  ami_id             = module.ami.grafana
  key_name           = module.key_pair.key_name
  subnet_ids         = [module.private_subnet_a.id]
  security_group_ids = [module.internal_sg.id]
}

module "prometheus" {
  source             = "github.com/Dudochnik/SoftServeDevOpsPetProjectModules//ec2"
  name               = "Prometheus"
  ami_id             = module.ami.prometheus
  key_name           = module.key_pair.key_name
  subnet_ids         = [module.private_subnet_b.id]
  security_group_ids = [module.internal_sg.id]
}

module "loki" {
  source             = "github.com/Dudochnik/SoftServeDevOpsPetProjectModules//ec2"
  name               = "Loki"
  ami_id             = module.ami.loki
  key_name           = module.key_pair.key_name
  subnet_ids         = [module.private_subnet_c.id]
  security_group_ids = [module.internal_sg.id]
}

module "cockroachdb" {
  source             = "github.com/Dudochnik/SoftServeDevOpsPetProjectModules//ec2"
  name               = "CockroachDB"
  ami_id             = module.ami.cockroachdb
  key_name           = module.key_pair.key_name
  subnet_ids         = [module.private_subnet_a.id, module.private_subnet_b.id, module.private_subnet_c.id]
  security_group_ids = [module.internal_sg.id]
  instances_count    = 3
  user_data          = file("scripts/cockroachdb_user_data.sh")
}

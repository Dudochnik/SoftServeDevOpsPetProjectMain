module "loki_hosted_zone" {
  source    = "github.com/Dudochnik/SoftServeDevOpsPetProjectModules//hosted_zone"
  name      = "main"
  zone      = "loki.com."
  addresses = module.loki.private_ip
  vpc_id    = module.vpc.id
}

module "cockroachdb_hosted_zone" {
  source    = "github.com/Dudochnik/SoftServeDevOpsPetProjectModules//hosted_zone"
  name      = "main"
  zone      = "cockroachdb.com."
  addresses = module.cockroachdb.private_ip
  vpc_id    = module.vpc.id
}

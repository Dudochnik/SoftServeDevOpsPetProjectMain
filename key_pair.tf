module "key_pair" {
  source     = "github.com/Dudochnik/SoftServeDevOpsPetProjectModules//key_pair"
  name       = "general_key"
  public_key = file(".//secrets/general_key.pub")
}

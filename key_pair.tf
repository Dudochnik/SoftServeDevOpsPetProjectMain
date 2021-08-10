module "key_pair" {
  source     = ".//key_pair"
  name       = "general_key"
  public_key = file(".//secrets/general_key.pub")
}

variable "region" {
  type = "string"
  description = "describe your variable"
  default = "eu-central-1"
}

variable "accesKey" {}

variable "secretKey" {}

variable "PATH_TO_PUBLIC_KEY" {
  type = "string"
  description = "describe your variable"
  default = "/home/ajgerena/Downloads/keys/corekey.pub"
}

variable "images" {
  type    = "map"
  default = {
    "eu-central-1" = "ami-c13952ae"
    "eu-west-3" = "ami-624bfd1f"
  }
}

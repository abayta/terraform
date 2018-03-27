variable "region" {
  type = "string"
  description = "describe your variable"
  default = "eu-west-3"
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

variable "aza" {
  type = "map"
  default = {
    "eu-central-1" = "eu-central-1a"
    "eu-west-3" = "eu-west-3a"
  }
}

variable "azb" {
  type = "map"
  default = {
    "eu-central-1" = "eu-central-1b"
    "eu-west-3" = "eu-west-3b"
  }
}

variable "azc" {
  type = "map"
  default = {
    "eu-central-1" = "eu-central-1c"
    "eu-west-3" = "eu-west-3c"
  }
}

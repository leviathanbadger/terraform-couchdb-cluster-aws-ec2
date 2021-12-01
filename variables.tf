

variable "access_key" {
  type = string
  sensitive = true
}

variable "secret_key" {
  type = string
  sensitive = true
}

variable "account_id" {
  type = string
  default = "060232771263"
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "default_tags" {
  type = map(string)
  default = {
    "ManagedBy" = "terraform"
    "Environment" = "dev"
    "Project" = "terraform-couchdb-cluster-aws-ec2"
    "HostedBy" = "AWS"
  }
}

variable "vpc_id" {
  type = string
  default = "vpc-01eff3f7286dc7a60"
}

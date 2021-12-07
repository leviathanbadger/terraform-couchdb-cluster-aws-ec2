

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

variable "environment" {
  type = string
  default = "dev"
}

variable "vpc_id" {
  type = string
  default = "vpc-79bd5a1e"
}

variable "couchdb_instance_type" {
  type = string
  default = "t2.micro"
}

variable "couchdb_node_count" {
  type = number
  default = 3
}

variable "default_tags" {
  type = map(string)
  default = {
    "ManagedBy" = "terraform"
    "Project" = "terraform-couchdb-cluster-aws-ec2"
    "HostedBy" = "AWS"
  }
}

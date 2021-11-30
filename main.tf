

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region

  default_tags {
    tags = merge(var.default_tags, {
      "HostedRegion" = var.region
    })
  }
}

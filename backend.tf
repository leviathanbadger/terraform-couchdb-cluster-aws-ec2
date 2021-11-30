

terraform {
  backend "remote" {
    organization = "miniwit-studios"

    workspaces {
      name = "terraform-couchdb-cluster-aws-ec2"
    }
  }
}

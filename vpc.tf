

data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnets" "main_public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_subnet" "main_public" {
  for_each = toset(data.aws_subnets.main_public.ids)
  id       = each.value
}

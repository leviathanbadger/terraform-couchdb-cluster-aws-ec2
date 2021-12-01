

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

resource "aws_security_group" "couchdb_efs_data" {
  name        = "couchdb-efs-data"
  description = "Allow NFS inbound traffic"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description      = "NFS"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    # TODO: limit cidrs
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "couchdb_service" {
  name        = "couchdb-service"
  description = "Allow couchdb inbound traffic; allow outbound DNS, HTTPS, and NFS traffic"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description      = "Couchdb port 4369"
    from_port        = 4369
    to_port          = 4369
    protocol         = "tcp"
    # TODO: limit cidrs
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Couchdb port 5984"
    from_port        = 5984
    to_port          = 5984
    protocol         = "tcp"
    # TODO: limit cidrs
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Couchdb port 9100"
    from_port        = 9100
    to_port          = 9100
    protocol         = "tcp"
    # TODO: limit cidrs
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "DNS - required to pull images"
    from_port        = 53
    to_port          = 53
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "HTTPS - required to pull images"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "NFS - required for persistent storage"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    # TODO: limit cidrs
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

data "aws_ami" "couchdb" {
  name_regex = "bitnami-couchdb-3.1.1-8-r70-linux-debian-10-x86_64-hvm-ebs-nami-73a0394f-331c-40ca-a96d-ef4f36fc46ec"
  owners     = ["679593333241"]
}

resource "aws_security_group" "couchdb" {
  description = "sg-couchdb-dev"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "CouchDB load balancer interface"
      from_port        = 5984
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 5984
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "CouchDB intra-cluster communication"
      from_port        = 4369
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 4369
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "SSH for Admin access"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
  ]
  name   = "sgcouchdb${var.environment}"
  vpc_id = var.vpc_id
}

locals {
  ordered_subnet_ids = [ for subnet in data.aws_subnet.main_public : subnet.id ]
}

resource "aws_network_interface" "couchdb_primary" {
  count = var.couchdb_node_count

  subnet_id = local.ordered_subnet_ids[count.index % length(local.ordered_subnet_ids)]
  security_groups = [aws_security_group.couchdb.id]
}

resource "aws_instance" "couchdb" {
  count = var.couchdb_node_count

  ami                                  = data.aws_ami.couchdb.image_id
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = var.couchdb_instance_type

  network_interface {
    network_interface_id = aws_network_interface.couchdb_primary[count.index].id
    device_index         = 0
  }

  tags = {
    CouchDbIndex = count.index
  }

  root_block_device {
    delete_on_termination = false
    volume_size           = 100
    volume_type           = "gp2"
  }
}

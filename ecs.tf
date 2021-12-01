

data "aws_ecs_cluster" "couchdb_test_cluster" {
  cluster_name = "couchdb-test-cluster"
}

resource "aws_ecs_task_definition" "couchdb" {
  family = "couchdb"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
  network_mode = "awsvpc"
  # TODO: execution role arn

  container_definitions = jsonencode([
    {
      name = "couchdb"
      image = "bitnami/couchdb:3.2.1"
      cpu = 256
      memory = 512
      essential = true
      portMappings = [
        {
          containerPort = 5984
          hostPort = 5984
          protocol = "tcp"
        },
        {
          containerPort = 4369
          hostPort = 4369
          protocol = "tcp"
        },
        {
          containerPort = 9100
          hostPort = 9100
          protocol = "tcp"
        }
      ]
      mountPoints = [
        {
          sourceVolume = "couchdb_data"
          readOnly = false
          containerPath = "/bitnami/couchdb"
        }
      ]
    }
  ])

  volume {
    name = "couchdb_data"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.couchdb_data.id
      root_directory = "/bitnami/couchdb"
      transit_encryption = "ENABLED"
      transit_encryption_port = 2999
    }
  }
}

# resource "aws_ecs_service" "couchdb" {
#   name = "couchdb"
#   cluster = data.aws_ecs_cluster.couchdb_test_cluster.id

#   task_definition = aws_ecs_task_definition.couchdb.arn
#   desired_count = 1
#   # iam_role = aws_iam_role.couchdb.arn
#   # depends_on = [aws_iam_role_policy.couchdb]
# }

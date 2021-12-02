

data "aws_ecs_cluster" "couchdb_test_cluster" {
  cluster_name = "couchdb-test-cluster"
}

resource "aws_iam_role" "couchdb_execution_role" {
  name = "couchdb-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role" "couchdb_task_role" {
  name = "couchdb-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_policy" "couchdb_task_policy" {
  name        = "couchdb-task-policy"
  description = "Allows connection from ECS to the EFS storage"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ]
        Resource = aws_efs_file_system.couchdb_data.arn,
        Condition = {
          StringEquals = {
            "elasticfilesystem:AccessPointArn" = aws_efs_access_point.couchdb_data.arn
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "couchdb_task_role_policy" {
  role = aws_iam_role.couchdb_task_role.name
  policy_arn = aws_iam_policy.couchdb_task_policy.arn
}

resource "aws_ecs_task_definition" "couchdb" {
  family = "couchdb"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
  network_mode = "awsvpc"
  execution_role_arn = aws_iam_role.couchdb_execution_role.arn
  task_role_arn = aws_iam_role.couchdb_task_role.arn

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
      root_directory = "/"
      transit_encryption = "ENABLED"
      transit_encryption_port = 2999

      authorization_config {
        access_point_id = aws_efs_access_point.couchdb_data.id
        iam             = "ENABLED"
      }
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.couchdb_task_role_policy
  ]
}

resource "aws_ecs_service" "couchdb" {
  name = "couchdb"
  cluster = data.aws_ecs_cluster.couchdb_test_cluster.id
  launch_type = "FARGATE"

  wait_for_steady_state = true

  task_definition = aws_ecs_task_definition.couchdb.arn
  desired_count = 1
  # iam_role = aws_iam_role.couchdb.arn
  # depends_on = [aws_iam_role_policy.couchdb]

  network_configuration {
    subnets = toset(data.aws_subnets.main_public.ids)
    security_groups = [aws_security_group.couchdb_service.id]
    assign_public_ip = true
  }
}

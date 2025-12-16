###############################################
# CloudWatch Log Group
###############################################
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.app_name}-${var.environment}"
  retention_in_days = 7

  tags = {
    Name = "${var.app_name}-${var.environment}-logs"
  }
}

###############################################
# Local Block for S3 ARN (for env file)
###############################################
locals {
  # Remove s3:// prefix → split to bucket + folder/file
  ecs_env_file_bucket = element(
    split("/", replace(var.ecs_env_file_s3_path, "s3://", "")),
    0
  )

  ecs_env_file_key = join(
    "/",
    slice(
      split("/", replace(var.ecs_env_file_s3_path, "s3://", "")),
      1,
      length(split("/", replace(var.ecs_env_file_s3_path, "s3://", "")))
    )
  )

  # Fully valid ARN
  ecs_env_file_s3_arn = "arn:aws:s3:::${local.ecs_env_file_bucket}/${local.ecs_env_file_key}"
}

###############################################
# S3 Read Access Policy (attach to existing IAM role)
###############################################
resource "aws_iam_role_policy" "ecs_task_s3_access" {
  name = "${var.app_name}-${var.environment}-ecs-s3-policy"
  role = aws_iam_role.ecs_task_execution_role.id   # <-- USING ROLE FROM ecs.tf

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Allow reading the env file
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "arn:aws:s3:::${local.ecs_env_file_bucket}/${local.ecs_env_file_key}"
      },

      # Allow listing prefix (required)
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::${local.ecs_env_file_bucket}"
        Condition = {
          StringLike = {
            "s3:prefix" = "${local.ecs_env_file_key}"
          }
        }
      }
    ]
  })
}

###############################################
# ECS Task Definition
###############################################
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.app_name}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn  # <-- FROM ecs.tf
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn  # <-- OK for now

  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-${var.environment}"
     image     = "${aws_ecr_repository.main.repository_url}:${var.docker_image_tag}"
     // image = "136279434049.dkr.ecr.us-west-2.amazonaws.com/notifiers-image:latest"

      essential = true
           /*
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]
      */

      # Correct environment file reference
      environmentFiles = [
        {
          type  = "s3"
          value = local.ecs_env_file_s3_arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.app_name}-${var.environment}"
  }
}


###############################################
# IAM Role for ECS Task Execution
###############################################
data "aws_iam_policy_document" "ecs_task_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.app_name}-${var.environment}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


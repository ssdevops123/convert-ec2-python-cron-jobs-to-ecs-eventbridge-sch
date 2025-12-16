/*
###############################################
# ECS Cluster
###############################################
resource "aws_ecs_cluster" "main" {
  ###name = var.app_name.var.environment
  name = "${var.app_name}-${var.environment}"

  tags = {
    Name = "${var.app_name}-${var.environment}-ecs-cluster"
  }
}

/*
###############################################
# CloudWatch Log Group for ECS Tasks
###############################################
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 7 
  
  tags = {
    Name = "${var.app_name}-ecs-logs"
  }
}
## removed comment here
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

*/

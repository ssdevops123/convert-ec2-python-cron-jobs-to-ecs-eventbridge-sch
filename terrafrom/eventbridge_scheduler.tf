resource "aws_scheduler_schedule" "ecs_task" {
  for_each = { for s in var.scripts : s.name => s }

  name                = "${each.key}-${var.environment}"
  description         = "Scheduled ECS task for ${each.key}"
  schedule_expression = each.value.schedule

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = var.ecs_cluster_arn
    role_arn = aws_iam_role.eventbridge_role.arn

    ecs_parameters {
      task_definition_arn = aws_ecs_task_definition.main.arn
      launch_type         = "FARGATE"
      platform_version    = "LATEST"

      network_configuration {
        subnets          = var.private_subnet_ids
        security_groups  = var.recupe_dev_app_sg
        //security_groups  = concat(var.sg1, var.sg2)
        assign_public_ip = false
      }
    }

    # The REAL container override location
    input = jsonencode({
      containerOverrides = [
        {
          name    = "${var.app_name}-${var.environment}"
          command = each.value.command
        }
      ]
    })
  }
}

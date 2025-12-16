
 resource "aws_ecr_repository" "main" {
  ###name                 = var.app_name.var.environment
  name                 = "${var.app_name}-${var.environment}"
  image_tag_mutability = "MUTABLE"
   force_delete = true
   
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    # Name = var.app_name
        Name = "${var.app_name}-${var.environment}"
  }
}
##
resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        action = {
          type = "expire"
        }
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 15
        }
      }
    ]
  })
}

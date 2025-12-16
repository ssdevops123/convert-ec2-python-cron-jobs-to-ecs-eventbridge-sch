# Gloabl Variables
variable "ecs_cluster_arn" {}

variable "vpc_id" {
  description = "VPC ID where ALB and SG will be created"
  type        = string
}

/* variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}*/

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
 # default     = "dev"
}

variable "app_name" {
  description = "Application name"
  type        = string
 # default     = "hello-india"
}

#s3
/*
variable "existing_artifact_bucket_name" {
  description = "Name of the existing S3 bucket for CodePipeline artifacts"
  type        = string
  default     = ""
} */

/*
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = false
} */

# sg 

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 443
}

#ecs
variable "cluster_tags" {
  description = "Additional tags for ECS cluster"
  type        = map(string)
  default     = {}
}

#Task definition Variables

variable "docker_image_tag" {
  description = "Docker image tag for ECS task definition"
  type        = string
  default     = "latest"
}

variable "use_latest_tag" {
  description = "Whether to use 'latest' tag or commit-based tags"
  type        = bool
  default     = true
}

variable "github_connection_arn" {
  description = "ARN of the existing CodeStar connection for GitHub"
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "GitHub repository URL"
  type        = string
  default     = "Plethy/notifiers"
}

variable "github_branch" {
  description = "GitHub branch"
  type        = string
   default     = "PRM-19296"
}
/*
variable "acm_certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener on ALB"
  type        = string
}

variable "enable_ssl" {
  description = "Set to true if SSL (HTTPS) is enabled, false otherwise"
  type        = bool
  default     = false
}
*/

variable "ecs_env_file_s3_path" {
  description = "S3 path for ECS environment file"
  type        = string
}

variable "recupe_dev_app_sg" {
  description = "Recupe Dev Application security groups to attach to ECS tasks"
  type        = list(string)
  default     = []
}

variable "sg1" {
  description = "api-ecs-backend-qa-db-sg  attached to ECS tasks"
  type        = list(string)
  default     = []
}
variable "sg2" {
  description = "api-ecs-backend-qa-ecs-sg attached to ECS tasks"
  type        = list(string)
  default     = []
}

variable "ecs_cpu" {
  type        = number
  description = "Fargate CPU units"
  default     = 256
}

variable "ecs_memory" {
  type        = number
  description = "Fargate memory (MiB)"
  default     = 512
}

variable "scripts" {
  type = list(object({
    name     = string
    schedule = string
    command  = list(string)
  }))
  default = []
}



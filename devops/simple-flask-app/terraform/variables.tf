variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "flask-app"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "flask-app-cluster"
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "flask-app"
}
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}
variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
}
variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "k8s_vpc_cidr" {
  description = "CIDR block of the Kubernetes VPC"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "allocated_storage" {
  description = "Storage size in GB"
  type        = number
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}
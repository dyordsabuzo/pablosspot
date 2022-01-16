variable "region" {
  description = "AWS region to create resources in"
  type  = string
  default = "ap-southeast-2"
}

variable "cluster_name" {
  type = string
  description = "ECS cluster name"
}

variable "service_name" {
  type = string
  description = "ECS service name"
}

variable "task_family" {
  type = string
  description = "ECS task family"
}

variable "target_group_arn" {
  type = string
  description = "Load balancer target group arn"
}

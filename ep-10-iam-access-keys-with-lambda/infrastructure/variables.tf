variable "repository_name" {
  description = "Repository name"
  type        = string
}

variable "image_tag" {
  description = "Image tag"
  type        = string
}

variable "schedule_expression" {
  description = "Schedule of run"
  type        = string
  default     = "rate(5 minutes)"
}

variable "region" {
  description = "AWS region"
  type        = string
}

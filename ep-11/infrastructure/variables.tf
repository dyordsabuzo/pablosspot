variable "schedule_expression" {
  description = "Schedule of run"
  type        = string
  default     = "rate(5 minutes)"
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "lambda_variables" {
  description = "Lambda variables"
  type = map
  default ={}
}
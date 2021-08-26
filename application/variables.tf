variable "application_name" {
  type        = string
  description = "name of application"
  default     = "my-application"
}

variable "error_rate" {
  type        = number
  description = "error rate to introduce into application"
  default     = 0.0
}

variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "region" {
  type        = string
  description = "AWS region to deploy the network"
}
variable "environment" {
  type        = string
  description = "The target environment (e.g., dev, test, prod)"
}

variable "location" {
  type        = string
  description = "The Azure region to deploy resources into"
}

variable "location_short" {
  type        = string
  description = "A short abbreviation of the location for naming conventions"
}

variable "common_name" {
  type        = string
  description = "The common descriptive name for the deployment workload"
  default     = "web-access"
}

variable "admin_password" {
  type        = string
  description = "The administrator password for the Linux Virtual Machine"
  sensitive   = true
}
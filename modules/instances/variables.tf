variable "project_id" {
  description = "The ID do projeto GCP"
  type        = string
}

variable "region" {
  description = "Region where the resource will de created"
  type        = string
}

variable "location" {
  description = "Location where the resource will de created"
  type        = string
}

variable "name" {
  type        = string
}

variable "tier" {
  type        = string
}

variable "users" {
  type        = list(object({
    user = string
    ip   = string
  }))
}
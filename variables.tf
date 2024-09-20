variable "project_id" {
  description = "The ID do projeto GCP"
  type        = string
}

variable "region" {
  description = "Region where the resource will de created"
  type        = string
  default     = "europe-west1"
}

variable "location" {
  description = "Location where the resource will de created"
  type        = string
  default     = "europe-west1"
}
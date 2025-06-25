variable "gcp_svc_key" {}
variable "gcp_region" {}
variable "gcp_project_id" {}
variable "gcp_zone" {}
variable "instance_name" {}
variable "ssh_key_pub" {}



variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "artifact_registry_location" {
  description = "Location for Artifact Registry repositories"
  type        = string
  default     = "us-central1"
}

variable "docker_image_cleanup_policy" {
  description = "Cleanup policy for Docker images"
  type = object({
    keep_tag_revisions = number
    max_age_days      = number
  })
  default = {
    keep_tag_revisions = 10
    max_age_days      = 30
  }
}

variable "labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default = {
    managed_by = "terraform"
    team       = "trading"
  }
}
  
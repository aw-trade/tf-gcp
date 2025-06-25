terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
  credentials = file(var.gcp_svc_key)
}

# Data sources for project information
data "google_project" "current" {}

data "google_client_config" "current" {}
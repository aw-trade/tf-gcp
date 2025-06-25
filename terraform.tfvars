artifact_registry_location = "us-central1"
environment = "dev"
gcp_svc_key    = "aw-trade-a0a723989eba.json"
gcp_project_id = "aw-trade"
gcp_region     = "us-west1"   # Free tier eligible region
gcp_zone       = "us-west1-b" # Free tier eligible zone
instance_name  = "dev-vm"
ssh_key_pub    = "~/.ssh/key.pub"
docker_image_cleanup_policy = {
  keep_tag_revisions = 10
  max_age_days      = 30
}

labels = {
  managed_by = "terraform"
  team       = "trading"
  project    = "aw-trade"
}
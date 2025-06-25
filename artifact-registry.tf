# Market Streamer Artifact Registry
resource "google_artifact_registry_repository" "market_streamer" {
  location      = var.artifact_registry_location
  repository_id = "market-streamer"
  description   = "Docker repository for market streamer service"
  format        = "DOCKER"
  
  labels = merge(var.labels, {
    service     = "market-streamer"
    environment = var.environment
  })

  # Keep recent versions regardless of tags
  cleanup_policies {
    id     = "keep-recent-versions"
    action = "KEEP"
    
    most_recent_versions {
      keep_count = var.docker_image_cleanup_policy.keep_tag_revisions
    }
  }

  # Keep tagged versions with specific prefixes
  cleanup_policies {
    id     = "keep-tagged-versions"
    action = "KEEP"
    
    condition {
      tag_state    = "TAGGED"
      tag_prefixes = ["v", "release"]
    }
  }

  # Delete old versions
  cleanup_policies {
    id     = "delete-old-versions"
    action = "DELETE"
    
    condition {
      older_than = "${var.docker_image_cleanup_policy.max_age_days}d"
    }
  }
}

# Order Book Algorithm Artifact Registry
resource "google_artifact_registry_repository" "order_book_algo" {
  location      = var.artifact_registry_location
  repository_id = "order-book-algo"
  description   = "Docker repository for order book algorithm service"
  format        = "DOCKER"
  
  labels = merge(var.labels, {
    service     = "order-book-algo"
    environment = var.environment
  })

  # Keep recent versions regardless of tags
  cleanup_policies {
    id     = "keep-recent-versions"
    action = "KEEP"
    
    most_recent_versions {
      keep_count = var.docker_image_cleanup_policy.keep_tag_revisions
    }
  }

  # Keep tagged versions with specific prefixes
  cleanup_policies {
    id     = "keep-tagged-versions"
    action = "KEEP"
    
    condition {
      tag_state    = "TAGGED"
      tag_prefixes = ["v", "release"]
    }
  }

  # Delete old versions
  cleanup_policies {
    id     = "delete-old-versions"
    action = "DELETE"
    
    condition {
      older_than = "${var.docker_image_cleanup_policy.max_age_days}d"
    }
  }
}

# Trade Simulator Artifact Registry
resource "google_artifact_registry_repository" "trade_simulator" {
  location      = var.artifact_registry_location
  repository_id = "trade-simulator"
  description   = "Docker repository for trade simulator service"
  format        = "DOCKER"
  
  labels = merge(var.labels, {
    service     = "trade-simulator"
    environment = var.environment
  })

  # Keep recent versions regardless of tags
  cleanup_policies {
    id     = "keep-recent-versions"
    action = "KEEP"
    
    most_recent_versions {
      keep_count = var.docker_image_cleanup_policy.keep_tag_revisions
    }
  }

  # Keep tagged versions with specific prefixes
  cleanup_policies {
    id     = "keep-tagged-versions"
    action = "KEEP"
    
    condition {
      tag_state    = "TAGGED"
      tag_prefixes = ["v", "release"]
    }
  }

  # Delete old versions
  cleanup_policies {
    id     = "delete-old-versions"
    action = "DELETE"
    
    condition {
      older_than = "${var.docker_image_cleanup_policy.max_age_days}d"
    }
  }
}

# IAM bindings for Artifact Registry access
resource "google_artifact_registry_repository_iam_binding" "market_streamer_readers" {
  project    = var.gcp_project_id
  location   = google_artifact_registry_repository.market_streamer.location
  repository = google_artifact_registry_repository.market_streamer.name
  role       = "roles/artifactregistry.reader"
  members = [
    "serviceAccount:${data.google_project.current.number}-compute@developer.gserviceaccount.com",
  ]
}

resource "google_artifact_registry_repository_iam_binding" "order_book_algo_readers" {
  project    = var.gcp_project_id
  location   = google_artifact_registry_repository.order_book_algo.location
  repository = google_artifact_registry_repository.order_book_algo.name
  role       = "roles/artifactregistry.reader"
  members = [
    "serviceAccount:${data.google_project.current.number}-compute@developer.gserviceaccount.com",
  ]
}

resource "google_artifact_registry_repository_iam_binding" "trade_simulator_readers" {
  project    = var.gcp_project_id
  location   = google_artifact_registry_repository.trade_simulator.location
  repository = google_artifact_registry_repository.trade_simulator.name
  role       = "roles/artifactregistry.reader"
  members = [
    "serviceAccount:${data.google_project.current.number}-compute@developer.gserviceaccount.com",
  ]
}
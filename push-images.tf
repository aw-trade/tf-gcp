# Automated Docker push with service account authentication
resource "null_resource" "docker_push" {
  depends_on = [
    google_artifact_registry_repository.market_streamer,
    google_artifact_registry_repository.order_book_algo,
    google_artifact_registry_repository.trade_simulator
  ]

  # Trigger re-run when image tags change
  triggers = {
    market_streamer_image = "market-streamer:latest"
    order_book_algo_image = "order-book-algo:latest"
    trade_simulator_image = "trade-simulator:latest"
    service_account_key   = filebase64(var.gcp_svc_key) # Re-trigger if key changes
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Authenticating with service account..."
      gcloud auth activate-service-account --key-file=${var.gcp_svc_key}
      
      echo "Setting project..."
      gcloud config set project ${var.gcp_project_id}
      
      echo "Configuring Docker authentication..."
      gcloud auth configure-docker ${google_artifact_registry_repository.market_streamer.location}-docker.pkg.dev --quiet
      
      echo "Tagging and pushing market-streamer..."
      docker tag market-streamer:latest ${google_artifact_registry_repository.market_streamer.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.market_streamer.repository_id}/market-streamer:latest
      docker push ${google_artifact_registry_repository.market_streamer.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.market_streamer.repository_id}/market-streamer:latest
      
      echo "Tagging and pushing order-book-algo..."
      docker tag order-book-algo:latest ${google_artifact_registry_repository.order_book_algo.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.order_book_algo.repository_id}/order-book-algo:latest
      docker push ${google_artifact_registry_repository.order_book_algo.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.order_book_algo.repository_id}/order-book-algo:latest
      
      echo "Tagging and pushing trade-simulator..."
      docker tag trade-simulator:latest ${google_artifact_registry_repository.trade_simulator.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.trade_simulator.repository_id}/trade-simulator:latest
      docker push ${google_artifact_registry_repository.trade_simulator.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.trade_simulator.repository_id}/trade-simulator:latest
      
      echo "All images pushed successfully!"
    EOT
  }
}

# Alternative: More robust version with error handling
resource "null_resource" "docker_push_robust" {
  count = 0 # Set to 1 to use this version instead

  depends_on = [
    google_artifact_registry_repository.market_streamer,
    google_artifact_registry_repository.order_book_algo,
    google_artifact_registry_repository.trade_simulator
  ]

  triggers = {
    market_streamer_image = "market-streamer:latest"
    order_book_algo_image = "order-book-algo:latest"
    trade_simulator_image = "trade-simulator:latest"
    service_account_key   = filebase64(var.gcp_svc_key)
  }

  provisioner "local-exec" {
    command = <<-EOT
      #!/bin/bash
      set -e  # Exit on any error
      
      echo "=== Authenticating with service account ==="
      if ! gcloud auth activate-service-account --key-file=${var.gcp_svc_key}; then
        echo "Failed to authenticate with service account"
        exit 1
      fi
      
      echo "=== Setting project ==="
      if ! gcloud config set project ${var.gcp_project_id}; then
        echo "Failed to set project"
        exit 1
      fi
      
      echo "=== Configuring Docker authentication ==="
      if ! gcloud auth configure-docker ${google_artifact_registry_repository.market_streamer.location}-docker.pkg.dev --quiet; then
        echo "Failed to configure Docker authentication"
        exit 1
      fi
      
      # Function to push image with retry
      push_image() {
        local local_tag=$1
        local remote_tag=$2
        local image_name=$3
        
        echo "=== Processing $image_name ==="
        
        # Check if local image exists
        if ! docker image inspect $local_tag > /dev/null 2>&1; then
          echo "Warning: Local image $local_tag not found. Skipping..."
          return 0
        fi
        
        echo "Tagging $local_tag as $remote_tag"
        if ! docker tag $local_tag $remote_tag; then
          echo "Failed to tag $image_name"
          return 1
        fi
        
        echo "Pushing $remote_tag"
        if ! docker push $remote_tag; then
          echo "Failed to push $image_name"
          return 1
        fi
        
        echo "$image_name pushed successfully!"
      }
      
      # Push all images
      push_image "market-streamer:latest" \
        "${google_artifact_registry_repository.market_streamer.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.market_streamer.repository_id}/market-streamer:latest" \
        "market-streamer"
      
      push_image "order-book-algo:latest" \
        "${google_artifact_registry_repository.order_book_algo.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.order_book_algo.repository_id}/order-book-algo:latest" \
        "order-book-algo"
      
      push_image "trade-simulator:latest" \
        "${google_artifact_registry_repository.trade_simulator.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.trade_simulator.repository_id}/trade-simulator:latest" \
        "trade-simulator"
      
      echo "=== All operations completed successfully! ==="
    EOT
    
    interpreter = ["bash", "-c"]
  }
}
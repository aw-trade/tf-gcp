# Add this resource to your existing Terraform configuration
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
  }

  provisioner "local-exec" {
    command = <<-EOT
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
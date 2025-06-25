


output "artifact_registries" {
  description = "Artifact Registry repository information"
  value = {
    market_streamer = {
      name         = google_artifact_registry_repository.market_streamer.name
      location     = google_artifact_registry_repository.market_streamer.location
      repository_id = google_artifact_registry_repository.market_streamer.repository_id
      docker_uri   = "${google_artifact_registry_repository.market_streamer.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.market_streamer.repository_id}"
    }
    order_book_algo = {
      name         = google_artifact_registry_repository.order_book_algo.name
      location     = google_artifact_registry_repository.order_book_algo.location
      repository_id = google_artifact_registry_repository.order_book_algo.repository_id
      docker_uri   = "${google_artifact_registry_repository.order_book_algo.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.order_book_algo.repository_id}"
    }
    trade_simulator = {
      name         = google_artifact_registry_repository.trade_simulator.name
      location     = google_artifact_registry_repository.trade_simulator.location
      repository_id = google_artifact_registry_repository.trade_simulator.repository_id
      docker_uri   = "${google_artifact_registry_repository.trade_simulator.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.trade_simulator.repository_id}"
    }
  }
}

output "docker_push_commands" {
  description = "Commands to push Docker images to each registry"
  value = {
    market_streamer = "docker push ${google_artifact_registry_repository.market_streamer.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.market_streamer.repository_id}/market-streamer:latest"
    order_book_algo = "docker push ${google_artifact_registry_repository.order_book_algo.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.order_book_algo.repository_id}/order-book-algo:latest"
    trade_simulator = "docker push ${google_artifact_registry_repository.trade_simulator.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.trade_simulator.repository_id}/trade-simulator:latest"
  }
}
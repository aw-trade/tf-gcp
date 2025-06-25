# main.tf

# VPC Network (using default network to stay within free tier)
data "google_compute_network" "default" {
  name = "default"
}

# Firewall rule to allow SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-free-tier"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-allowed"]
}

# Firewall rule to allow HTTP traffic (optional)
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-free-tier"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["80", "8000", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_firewall" "allow_https" {
  name    = "allow-https-free-tier"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["443", "8000", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}

# NEW: Firewall rule to allow UDP traffic for crypto streaming
resource "google_compute_firewall" "allow_crypto_stream" {
  name    = "allow-crypto-stream-udp"
  network = data.google_compute_network.default.name

  allow {
    protocol = "udp"
    ports    = ["8888"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["crypto-stream"]
}

# Compute Engine Instance (Free Tier)
resource "google_compute_instance" "free_tier_vm" {
  name         = var.instance_name
  machine_type = "e2-micro" # Free tier eligible machine type
  zone         = var.gcp_zone

  # Free tier eligible boot disk
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30 # Free tier includes 30GB standard persistent disk
      type  = "pd-standard"
    }
  }

  # Network interface
  network_interface {
    network = data.google_compute_network.default.name

    # Ephemeral public IP (free tier includes 1 ephemeral external IP)
    access_config {
      // Ephemeral public IP
    }
  }

  # Metadata for SSH keys and startup script
  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_key_pub)}" # Update path to your public key
  }

  # Updated startup script with better error handling
  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e
    
    # Log all output
    exec > >(tee -a /var/log/startup.log)
    exec 2>&1
    
    echo "Starting setup at $(date)"
    
    # Update package list
    sudo apt-get update
    
    # Install required packages
    sudo apt-get install  pkg-config
    sudo apt-get install build-essential libssl-dev git
    sudo snap install rustup --classic
    rustup default stable
    git clone https://github.com/aw-trade/stream-rust.git
    cd stream-rust
    cargo build --release

[Unit]
Description=Crypto Stream Service
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/stream-rust
ExecStart=/home/ubuntu/.cargo/bin/cargo run --release
Restart=always
RestartSec=10
Environment=BIND_ADDR=0.0.0.0:8888

[Install]
WantedBy=multi-user.target
EOL
      
      # Enable and start the service
      sudo systemctl daemon-reload
      sudo systemctl enable crypto-stream.service
      sudo systemctl start crypto-stream.service
    "
    
    echo "Setup completed at $(date)"
  EOF

  # Network tags for firewall rules (UPDATED to include crypto-stream)
  tags = ["ssh-allowed", "http-server", "https-server", "crypto-stream"]
}


# Outputs
output "instance_name" {
  description = "Name of the created instance"
  value       = google_compute_instance.free_tier_vm.name
}

output "instance_zone" {
  description = "Zone of the created instance"
  value       = google_compute_instance.free_tier_vm.zone
}

output "internal_ip" {
  description = "Internal IP address of the instance"
  value       = google_compute_instance.free_tier_vm.network_interface[0].network_ip
}

output "external_ip" {
  description = "External IP address of the instance"
  value       = google_compute_instance.free_tier_vm.network_interface[0].access_config[0].nat_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh ubuntu@${google_compute_instance.free_tier_vm.network_interface[0].access_config[0].nat_ip}"
}

output "crypto_stream_test" {
  description = "Command to test crypto stream connection"
  value       = "nc -u ${google_compute_instance.free_tier_vm.network_interface[0].access_config[0].nat_ip} 8888"
}
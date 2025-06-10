terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {
  description = "DigitalOcean API Token"
  type        = string
  sensitive   = true
}

variable "droplet_name" {
  description = "Name of the droplet"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key in DigitalOcean"
  type        = string
}

provider "digitalocean" {
  token = var.do_token
}

# Check if droplet with the same name already exists
data "digitalocean_droplets" "existing" {
  filter {
    key    = "name"
    values = [var.droplet_name]
  }
}

# Get existing SSH key from DigitalOcean
data "digitalocean_ssh_key" "main" {
  name = var.ssh_key_name
}

# Create droplet only if one with the same name doesn't exist
resource "digitalocean_droplet" "web" {
  count  = length(data.digitalocean_droplets.existing.droplets) == 0 ? 1 : 0
  image  = "ubuntu-22-04-x64"
  name   = var.droplet_name
  region = "nyc3"
  size   = "s-1vcpu-1gb"
  ssh_keys = [data.digitalocean_ssh_key.main.id]

  tags = ["terraform", "webapp"]
}

# Use existing droplet if it exists, otherwise use the newly created one
locals {
  droplet_ip = length(data.digitalocean_droplets.existing.droplets) > 0 ? data.digitalocean_droplets.existing.droplets[0].ipv4_address : digitalocean_droplet.web[0].ipv4_address
  droplet_id = length(data.digitalocean_droplets.existing.droplets) > 0 ? data.digitalocean_droplets.existing.droplets[0].id : digitalocean_droplet.web[0].id
}

# Output the droplet IP (whether existing or newly created)
output "droplet_ip" {
  value = local.droplet_ip
}

# Output droplet status for debugging
output "droplet_status" {
  value = length(data.digitalocean_droplets.existing.droplets) > 0 ? "Using existing droplet" : "Created new droplet"
}

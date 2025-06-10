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

# Get existing SSH key from DigitalOcean
data "digitalocean_ssh_key" "main" {
  name = var.ssh_key_name
}

# Create droplet
resource "digitalocean_droplet" "web" {
  image  = "ubuntu-22-04-x64"
  name   = var.droplet_name
  region = "nyc3"
  size   = "s-1vcpu-1gb"
  ssh_keys = [data.digitalocean_ssh_key.main.id]

  tags = ["terraform", "webapp"]
}

# Output the droplet IP
output "droplet_ip" {
  value = digitalocean_droplet.web.ipv4_address
}

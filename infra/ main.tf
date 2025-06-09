terraform {
  required_providers {
    digitalocean = {
      source  = "opentofu/digitalocean"
      version = "~> 2.30"
    }
  }

  # ▸ Optional backend (remove this block if you’re OK with local state)
  /*
  backend "s3" {
    endpoints = { s3 = "https://nyc3.digitaloceanspaces.com" }
    bucket = "tf-state"
    key    = "webapp/terraform.tfstate"
    region = "us-east-1"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
  }
  */
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "webapp" {
  name       = var.droplet_name
  region     = var.region
  size       = var.size
  image      = "ubuntu-22-04-x64"
  ssh_keys   = [var.ssh_fingerprint]
  monitoring = true

  # cloud-init template
  user_data = templatefile("${path.module}/scripts/bootstrap.sh.tpl", {
    app_port   = var.app_port,
    repo_url   = var.repo_url,
    git_branch = var.git_branch
  })
}

resource "digitalocean_firewall" "web" {
  name        = "${var.droplet_name}-fw"
  droplet_ids = [digitalocean_droplet.webapp.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = var.app_port
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
}

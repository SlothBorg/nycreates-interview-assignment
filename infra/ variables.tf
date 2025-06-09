# Required at runtime via secrets or environment
variable "do_token"        { type = string }
variable "ssh_fingerprint" { type = string }        # your DO-uploaded SSH key
variable "repo_url"        { type = string }        # e.g. https://github.com/you/my-webapp.git

# Tunables with safe defaults
variable "git_branch"   { default = "main" }
variable "droplet_name" { default = "go-webapp" }
variable "region"       { default = "nyc3" }
variable "size"         { default = "s-1vcpu-1gb" }
variable "app_port"     { default = 8080 }

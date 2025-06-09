#!/usr/bin/env bash
set -euo pipefail

APP_PORT=${app_port}
REPO_URL=${repo_url}
GIT_BRANCH=${git_branch}

export DEBIAN_FRONTEND=noninteractive

# 1 System packages
apt-get update -y
apt-get install -y nginx git curl

# 2 Install Go (edit version if desired)
curl -fsSL https://go.dev/dl/go1.22.2.linux-amd64.tar.gz | tar -C /usr/local -xz
export PATH=$PATH:/usr/local/go/bin

# 3 Clone your code
git clone --branch "$GIT_BRANCH" "$REPO_URL" /opt/webapp

# 4 Build API
cd /opt/webapp/src/api
go build -o /usr/local/bin/webapp

# 5 Static front-end
mkdir -p /var/www/webapp
cp -r /opt/webapp/src/frontend/* /var/www/webapp/

# 6 systemd unit (loads .env you committed)
cat >/etc/systemd/system/webapp.service <<EOF
[Unit]
Description=Go WebApp
After=network.target
[Service]
EnvironmentFile=/opt/webapp/src/api/.env
WorkingDirectory=/opt/webapp/src/api
ExecStart=/usr/local/bin/webapp --port $APP_PORT
Restart=on-failure
User=www-data
Group=www-data
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now webapp

# 7 Nginx reverse proxy + static host
rm /etc/nginx/sites-enabled/default
cat >/etc/nginx/sites-available/webapp.conf <<EOF
server {
  listen 80;
  server_name _;
  root /var/www/webapp;

  location /api {
    proxy_pass http://127.0.0.1:$APP_PORT;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}
EOF
ln -s /etc/nginx/sites-available/webapp.conf /etc/nginx/sites-enabled/
systemctl reload nginx

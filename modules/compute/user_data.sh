#!/bin/bash
set -e
exec > >(tee -a /var/log/user-data.log) 2>&1

echo "==== Starting user data script ===="

# Install required packages
yum update -y
yum install -y docker jq awscli httpd

# Start services
systemctl start docker
systemctl enable docker
systemctl start httpd
systemctl enable httpd

# Configure reverse proxy
cat > /etc/httpd/conf.d/reverse-proxy.conf <<'EOF'
<VirtualHost *:80>
    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:8080/
    ProxyPassReverse / http://127.0.0.1:8080/
</VirtualHost>
EOF

# Restart Apache
systemctl restart httpd

# Set database connection variables from Terraform inputs
DB_HOST="${db_host}"
DB_NAME="${db_name}"
DB_USER="${db_user}"
DB_PASS="${db_password}"

# Run the application container
docker run -d \
  --name php-app \
  -p 8080:80 \
  -e DB_HOST="$DB_HOST" \
  -e DB_USER="$DB_USER" \
  -e DB_PASSWORD="$DB_PASS" \
  -e DB_NAME="$DB_NAME" \
  realamponsah/lampstackphp:latest

echo "==== User data script completed ===="
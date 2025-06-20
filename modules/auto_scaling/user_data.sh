#!/bin/bash
set -e
exec > >(tee -a /var/log/user-data.log) 2>&1

echo "==== Starting user data script ===="

# Install required packages
yum update -y
yum install -y docker jq awscli httpd amazon-cloudwatch-agent

# Start and enable Docker and Apache
systemctl start docker
systemctl enable docker
systemctl start httpd
systemctl enable httpd

# Configure Apache reverse proxy
cat > /etc/httpd/conf.d/reverse-proxy.conf << 'EOT'
<VirtualHost *:80>
    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:8080/
    ProxyPassReverse / http://127.0.0.1:8080/
</VirtualHost>
EOT

# Restart Apache to apply reverse proxy config
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

# Wait a few seconds to allow Docker to initialize
sleep 5

# Set permissions to allow CloudWatch Agent to read Docker logs
chmod -R +r /var/lib/docker/containers

# Configure CloudWatch Agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOT'
{
  "agent": {
    "metrics_collection_interval": 60,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "metrics": {
    "namespace": "LAMPStack/Custom",
    "metrics_collected": {
      "cpu": {
        "resources": ["*"],
        "measurement": [
          { "name": "cpu_usage_active", "unit": "Percent" },
          { "name": "cpu_usage_iowait", "unit": "Percent" }
        ]
      },
      "mem": {
        "measurement": [
          { "name": "mem_used_percent", "unit": "Percent" },
          { "name": "mem_available_percent", "unit": "Percent" }
        ]
      },
      "disk": {
        "resources": ["/"],
        "measurement": [
          { "name": "disk_used_percent", "unit": "Percent" }
        ]
      },
      "net": {
        "resources": ["eth0"],
        "measurement": [
          { "name": "net_bytes_sent", "unit": "Bytes" },
          { "name": "net_bytes_recv", "unit": "Bytes" }
        ]
      }
    },
    "append_dimensions": {
      "AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
      "InstanceId": "$${aws:InstanceId}"
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "LAMPStack/ApacheAccess",
            "log_stream_name": "$${instance_id}/access_log"
          },
          {
            "file_path": "/var/log/httpd/error_log",
            "log_group_name": "LAMPStack/ApacheError",
            "log_stream_name": "$${instance_id}/error_log"
          },
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "LAMPStack/UserData",
            "log_stream_name": "$${instance_id}/user-data"
          },
          {
            "file_path": "/var/lib/docker/containers/*/*.log",
            "log_group_name": "LAMPStack/Docker",
            "log_stream_name": "$${instance_id}/docker",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/mem_metrics.log",
            "log_group_name": "LAMPStack/MemMetrics",
            "log_stream_name": "$${instance_id}/mem_metrics",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
EOT

# Start the CloudWatch Agent after container and logs are available
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

systemctl enable amazon-cloudwatch-agent

# Verify CloudWatch Agent
echo "Verifying CloudWatch Agent installation..."
if [ -f /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl ]; then
    echo "CloudWatch Agent installed successfully"
else
    echo "CloudWatch Agent installation failed"
    exit 1
fi

# Check agent status
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status

# Collect recent logs for debugging
echo "Collecting CloudWatch Agent logs..."
journalctl -u amazon-cloudwatch-agent -n 50 --no-pager > /var/log/cw-agent-debug.log

echo "==== User data script completed ===="

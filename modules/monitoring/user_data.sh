#!/bin/bash

# Install AWS CloudWatch Agent
yum update -y
yum install -y amazon-cloudwatch-agent

# Create CloudWatch Agent configuration
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
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
          {"name": "cpu_usage_active", "unit": "Percent"},
          {"name": "cpu_usage_iowait", "unit": "Percent"}
        ]
      },
      "mem": {
        "measurement": [
          {"name": "mem_used_percent", "unit": "Percent"},
          {"name": "mem_available_percent", "unit": "Percent"}
        ]
      },
      "disk": {
        "resources": ["/"],
        "measurement": [
          {"name": "disk_used_percent", "unit": "Percent"}
        ]
      },
      "net": {
        "resources": ["eth0"],
        "measurement": [
          {"name": "net_bytes_sent", "unit": "Bytes"},
          {"name": "net_bytes_recv", "unit": "Bytes"}
        ]
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/cloudwatch-agent.log",
            "log_group_name": "LAMPStack/MonitoringServer",
            "log_stream_name": "{instance_id}/cloudwatch-agent"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Ensure agent starts on boot
systemctl enable amazon-cloudwatch-agent
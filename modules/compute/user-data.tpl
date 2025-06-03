#!/bin/bash
yum update -y
yum install -y python3 awscli

# Create directory for our app
mkdir -p /opt/time-api

# Get instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

# Create the Python server file
cat > /opt/time-api/server.py << 'EOF'
#!/usr/bin/env python3

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
from datetime import datetime
import os
import socket

class TimeHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/time' or self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            
            # Get current time
            current_time = datetime.now().isoformat()
            instance_id = os.environ.get('EC2_INSTANCE_ID', 'unknown')
            availability_zone = os.environ.get('EC2_AZ', 'unknown')
            hostname = socket.gethostname()
            
            response = {
                'current_time': current_time,
                'timezone': 'UTC',
                'instance_id': instance_id,
                'availability_zone': availability_zone,
                'hostname': hostname,
                'status': 'healthy',
                'version': '${app_version}'
            }
            
            self.wfile.write(json.dumps(response, indent=2).encode())
            
        elif self.path == '/health':
            # Health check endpoint for ALB
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            health_response = {
                'status': 'healthy',
                'timestamp': datetime.now().isoformat(),
                'instance_id': os.environ.get('EC2_INSTANCE_ID', 'unknown')
            }
            
            self.wfile.write(json.dumps(health_response).encode())
            
        elif self.path == '/metrics':
            # Basic metrics endpoint
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            import psutil
            
            metrics_response = {
                'cpu_percent': psutil.cpu_percent(),
                'memory_percent': psutil.virtual_memory().percent,
                'disk_percent': psutil.disk_usage('/').percent,
                'timestamp': datetime.now().isoformat()
            }
            
            self.wfile.write(json.dumps(metrics_response).encode())
            
        else:
            self.send_response(404)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            error_response = {
                'error': 'Not Found',
                'message': 'The requested endpoint was not found',
                'available_endpoints': ['/time', '/health', '/metrics']
            }
            
            self.wfile.write(json.dumps(error_response).encode())

def run_server(port=8080):
    server_address = ('', port)
    httpd = HTTPServer(server_address, TimeHandler)
    print(f"Time API server running on port {port}")
    print("Endpoints:")
    print("  GET /time - Returns current time")
    print("  GET /health - Health check")
    print("  GET /metrics - Basic system metrics")
    httpd.serve_forever()

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    run_server(port)
EOF

# Make it executable
chmod +x /opt/time-api/server.py

# Install psutil for metrics
pip3 install psutil

# Create systemd service for auto-start
cat > /etc/systemd/system/time-api.service << EOF
[Unit]
Description=Time API Service
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/time-api
ExecStart=/usr/bin/python3 /opt/time-api/server.py
Restart=always
Environment=EC2_INSTANCE_ID=$INSTANCE_ID
Environment=EC2_AZ=$AZ
Environment=PORT=8080

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl enable time-api
systemctl start time-api

EOF

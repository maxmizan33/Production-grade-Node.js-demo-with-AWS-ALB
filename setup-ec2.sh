#!/bin/bash

# Update system
sudo yum update -y

# Install Node.js 18
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs git

# Install PM2
sudo npm install -g pm2

# Install Nginx
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Deploy app
mkdir -p /home/ec2-user/myapp
cd /home/ec2-user/myapp

# Start Node.js app with PM2
pm2 start app.js
pm2 save
pm2 startup systemd

# Configure Nginx as reverse proxy
sudo tee /etc/nginx/conf.d/myapp.conf > /dev/null <<EOL
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

sudo nginx -t
sudo systemctl restart nginx
echo "Setup complete. Node.js app running behind Nginx."

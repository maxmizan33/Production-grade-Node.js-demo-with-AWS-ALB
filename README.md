# 🚀 MyApp Production-Grade Demo

## 🌟 Project Overview
This project demonstrates a **production-grade Node.js application** deployed on **AWS**.  
It is designed as a **portfolio/demo project** to showcase **DevOps/Cloud skills**, including **high availability, load balancing, routing, and domain integration**.

**✨ Key Features:**
- 🟢 Node.js application using **Express.js**
- 🖥️ EC2 instances running the app behind **Nginx reverse proxy**
- ⚖️ **Application Load Balancer (ALB)** distributing traffic
- 🗄️ Optional **RDS database** for backend
- 🌐 Custom domain integration using **Route 53**
- 📦 Optional **S3 bucket** for static assets or backups

---

## 🏗️ Architecture Diagram

           ┌───────────────────────┐
           │    🌐 Browser / Client  │
           └─────────┬────────────┘
                     │
                     ▼
           ┌───────────────────────┐
           │    🛎️ Route 53 DNS     │
           │  (www.infomizan.xyz) │
           └─────────┬────────────┘
                     │
                     ▼
           ┌───────────────────────┐
           │   ⚡ Application Load  │
           │      Balancer (ALB)  │
           └─────────┬────────────┘
                     │
        ┌────────────┴────────────┐
        ▼                         ▼

┌─────────────────────┐ ┌─────────────────────┐
│ 🖥️ EC2 Instance 1 │ │ 🖥️ EC2 Instance 2 │
│ prod-web-01-myapp │ │ prod-web-02-myapp │
│ Node.js app (3000) │ │ Node.js app (3000) │
│ Nginx reverse proxy │ │ Nginx reverse proxy │
└─────────┬───────────┘ └─────────┬───────────┘
│ │
▼ ▼
┌─────────┐ ┌─────────┐
│ Node.js │ │ Node.js │
│ App │ │ App │
└─────────┘ └─────────┘
│ │
└─────────────┬─────────────┘
▼
┌────────────┐
│ 🗄️ RDS DB │
│ private subnet │
└────────────┘



**💡 Side Note:**  
- Requests from browser go to **Route 53 DNS**, then **ALB**, which forwards traffic to healthy EC2 instances.  
- **Nginx** on EC2 acts as a **reverse proxy**, routing port 80 requests to Node.js app on port 3000.  
- Node.js serves the demo page, optionally queries **RDS**.  
- **S3** can be used for static files or backups.  

---

## 🏗️ AWS Infrastructure & Setup

### VPC & Networking
- Create **VPC** (`prod-vpc-myapp`)  
- Create **Subnets**:  
  - Public: `prod-public-1-myapp`, `prod-public-2-myapp`  
  - Private: `prod-private-1-myapp`, `prod-private-2-myapp`  
- Create **Internet Gateway (IGW)** → attach to VPC  
- Create **Route Tables**:  
  - Public → IGW  
  - Private → optional NAT for outbound access  
- Associate subnets with route tables  

**📝 Side Note:** Public subnets host EC2 & ALB; Private subnets host optional RDS DB  

---

### EC2 Instances (Compute)
- Launch **2 EC2 instances** in public subnets:  
  - `prod-web-01-myapp`  
  - `prod-web-02-myapp`  
  - Instance type: `t3.medium`  
  - Assign public IPs  
- Security group `prod-sg-web-myapp`:  
  - Inbound: HTTP(80), HTTPS(443), SSH(22)  
  - Outbound: all traffic  

**📝 Side Note:** EC2 instances host Node.js app and Nginx reverse proxy.  

---

### Node.js Setup
- SSH into each EC2 instance  
- Install Node.js 18:  
```bash
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs
Create Node.js demo app (app.js) with Express.js
Test locally:
node app.js
curl http://localhost:3000

📝 Side Note: Node.js serves a simple page with hostname to demonstrate load balancing.

PM2 (Process Manager)
sudo npm install -g pm2
pm2 start app.js
pm2 save
pm2 startup systemd

📝 Side Note: Keeps Node.js running in background even after EC2 reboot.

Nginx Reverse Proxy
Install Nginx:
sudo yum install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
Configure /etc/nginx/conf.d/myapp.conf:
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
Test: curl http://localhost → Node.js page

📝 Side Note: Nginx handles production-ready HTTP traffic and forwards it to Node.js app.

ALB & Target Group
Create Target Group (prod-tg-web-myapp)
Protocol: HTTP, Port: 80 (Nginx)
Health check path: /
Register EC2 instances → port 80 → wait until healthy
Create ALB (prod-alb-myapp)
Scheme: Internet-facing
Listener: HTTP 80
Subnets: public subnets
Attach Target Group

📝 Side Note: ALB distributes traffic evenly across EC2 instances and performs health checks.

Domain Integration
Create Route 53 hosted zone for infomizan.xyz
Update registrar nameservers → Route 53 NS
Create A record (Alias) for www → ALB
Optional: Root domain redirect → www.infomizan.xyz

📝 Side Note: Users can access Node.js app via www.infomizan.xyz instead of AWS ALB DNS.

Testing
Local EC2: curl http://localhost → Node.js via Nginx
Target group health check → should be healthy
ALB DNS: browser → Node.js demo page
Domain: http://www.infomizan.xyz → Node.js demo page
Refresh → hostnames alternate → load balancing verified
✅ Conclusion
Production-grade Node.js AWS demo complete
High availability, load balancing, reverse proxy, domain integration
Ready for portfolio/demo 🚀

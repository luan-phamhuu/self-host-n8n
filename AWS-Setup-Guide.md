# 🚀 Complete AWS n8n Setup Guide

This guide will walk you through setting up n8n on AWS from scratch. Perfect for beginners!

## 📋 Prerequisites

- AWS account (free tier works fine)
- Basic understanding of Linux commands
- Domain name (optional but recommended)

## 🎯 What We'll Build

- **EC2 Instance**: Ubuntu server running n8n
- **Database**: PostgreSQL container (or AWS RDS)
- **SSL Certificate**: Secure HTTPS access
- **Domain**: Custom domain access
- **Monitoring**: Basic health checks

## 💰 Estimated Costs

- **EC2 t3.micro**: ~$8/month (free tier eligible)
- **RDS db.t3.micro**: ~$15/month (optional)
- **Domain**: ~$10/year (optional)
- **Total**: ~$8-25/month

## 📖 Step-by-Step Instructions

### Step 1: AWS Account Setup

#### 1.1 Create AWS Account

1. Go to [aws.amazon.com](https://aws.amazon.com)
2. Click "Create Free Account"
3. Complete the signup process (credit card required for verification)
4. Activate your free tier

#### 1.2 Choose Your Region

1. Click on the region selector (top right)
2. Choose a region close to you (e.g., `us-east-1` for US East)
3. **Important**: All resources must be in the same region

### Step 2: Create Security Group

Security groups act as a virtual firewall.

1. Go to **EC2 Dashboard** → **Security Groups**
2. Click **"Create security group"**
3. Configure:
   - **Name**: `n8n-security-group`
   - **Description**: `Security group for n8n application`
4. Add **Inbound Rules**:

   ```
   Type: SSH
   Protocol: TCP
   Port Range: 22
   Source: My IP (your IP address)

   Type: HTTP
   Protocol: TCP
   Port Range: 80
   Source: 0.0.0.0/0

   Type: HTTPS
   Protocol: TCP
   Port Range: 443
   Source: 0.0.0.0/0
   ```

5. Click **"Create security group"**

### Step 3: Launch EC2 Instance

1. Go to **EC2 Dashboard** → **Instances**
2. Click **"Launch instance"**
3. Configure:

   - **Instance name**: `n8n-server`
   - **AMI**: Ubuntu Server 22.04 LTS (Free tier eligible)
   - **Instance type**: `t3.micro` (Free tier eligible)
   - **Key pair**: Create new or select existing
   - **Network settings**: Select your `n8n-security-group`
   - **Storage**: 20 GB gp3 (free tier eligible)

4. Click **"Launch instance"**
5. **Important**: Download and save your `.pem` key file securely

### Step 4: Connect to Your Instance

#### Option A: Using SSH (Terminal/Command Prompt)

```bash
# Replace 'your-key.pem' and 'your-instance-ip' with actual values
ssh -i your-key.pem ubuntu@your-instance-ip
```

#### Option B: Using AWS Session Manager (Easier)

1. Install AWS CLI
2. Use Session Manager: `aws ssm start-session --target i-your-instance-id`

### Step 5: Set Up n8n

Once connected to your EC2 instance:

#### 5.1 Download Setup Script

```bash
# Download the setup script
curl -o setup.sh https://raw.githubusercontent.com/your-repo/setup.sh
chmod +x setup.sh
```

#### 5.2 Run Setup Script

```bash
sudo ./setup.sh
```

#### 5.3 Manual Setup (If script doesn't work)

```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER

# Create n8n directory
mkdir -p ~/n8n && cd ~/n8n
```

### Step 6: Configure n8n

#### 6.1 Create Docker Compose Configuration

Copy the `docker-compose.yml` file to your server:

```bash
# Create the docker-compose.yml file
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "80:5678"
    environment:
      - GENERIC_TIMEZONE=UTC
      - TZ=UTC
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=${DB_PASSWORD}
      - WEBHOOK_URL=http://your-domain.com/
      - EXECUTIONS_TIMEOUT=0
      - EXECUTIONS_TIMEOUT_MAX=3600
      - N8N_SECURE_COOKIE=false
      - N8N_LOG_LEVEL=info
    volumes:
      - n8n_data:/home/node/.n8n
      - /tmp:/tmp
    depends_on:
      postgres:
        condition: service_healthy

  postgres:
    image: postgres:15-alpine
    container_name: n8n_postgres
    restart: unless-stopped
    environment:
      - POSTGRES_DB=n8n
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U n8n -d n8n"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

volumes:
  n8n_data:
  postgres_data:
EOF
```

#### 6.2 Create Environment File

```bash
# Generate secure passwords
DB_PASSWORD=$(openssl rand -base64 32)
ENCRYPTION_KEY=$(openssl rand -hex 32)
JWT_SECRET=$(openssl rand -base64 32)

# Create .env file
cat > .env << EOF
DB_PASSWORD=$DB_PASSWORD
N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY
JWT_SECRET=$JWT_SECRET
EOF

echo "Generated credentials saved to .env file"
```

#### 6.3 Start n8n

```bash
# Start the services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f n8n
```

### Step 7: Access Your n8n Instance

#### 7.1 Public Access

1. Get your EC2 public IP from AWS Console
2. Open browser: `http://YOUR-PUBLIC-IP`
3. Complete the n8n setup wizard

#### 7.2 Domain Setup (Optional but Recommended)

##### Option A: Route 53 (AWS Domain Registrar)

1. Go to **Route 53** → **Hosted zones**
2. Create hosted zone for your domain
3. Create **A record** pointing to your EC2 IP
4. Update your EC2 Elastic IP (optional but recommended)

### Step 8: SSL Certificate Setup

#### 8.1 Install Certbot (for Let's Encrypt)

```bash
sudo apt-get install certbot

# Get SSL certificate (replace with your domain)
sudo certbot certonly --standalone -d your-domain.com -d www.your-domain.com
```

#### 8.2 Update Docker Compose for SSL

```bash
# Update docker-compose.yml with SSL configuration
# Add nginx service for SSL termination
```

### Step 9: Security Hardening

#### 9.1 Configure Firewall

```bash
# Enable UFW firewall
sudo ufw enable

# Allow SSH
sudo ufw allow ssh

# Allow HTTP/HTTPS
sudo ufw allow 80
sudo ufw allow 443

# Check status
sudo ufw status
```

#### 9.2 Regular Security Updates

```bash
# Set up automatic security updates
sudo apt-get install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

### Step 10: Monitoring and Backup

#### 10.1 Set Up CloudWatch Monitoring

1. Go to **CloudWatch** → **Dashboards**
2. Create custom dashboard for your EC2 instance
3. Monitor CPU, Memory, Disk usage

#### 10.2 Automated Backups

```bash
# Create backup script
cat > backup.sh << 'EOF'
#!/bin/bash
docker-compose exec -T postgres pg_dump -U n8n n8n | gzip > /home/ubuntu/backups/n8n-$(date +%Y%m%d-%H%M%S).sql.gz
# Keep only last 7 days of backups
find /home/ubuntu/backups -name "n8n-*.sql.gz" -mtime +7 -delete
EOF

chmod +x backup.sh

# Schedule daily backups
echo "0 2 * * * /home/ubuntu/n8n/backup.sh" | crontab -
```

## 🔧 Troublescasting

### Common Issues

#### Issue 1: Cannot access n8n

- **Solution**: Check security group rules
- **Solution**: Verify EC2 instance is running
- **Solution**: Check Docker containers: `docker-compose ps`

#### Issue 2: Database connection errors

- **Solution**: Check PostgreSQL container: `docker-compose logs postgres`
- **Solution**: Verify `.env` file has correct DB_PASSWORD

#### Issue 3: Out of memory

- **Solution**: Upgrade to `t3.small` or larger instance
- **Solution**: Add swap space: `sudo fallocate -l 2G /swapfile`

#### Issue 4: SSL certificate not working

- **Solution**: Check domain DNS settings
- **Solution**: Verify nginx configuration
- **Solution**: Check certificate paths

### Getting Help

- **n8n Documentation**: [docs.n8n.io](https://docs.n8n.io)
- **AWS Support**: Basic support available
- **Community Forum**: [community.n8n.io](https://education.n8n.io/)

## 📊 Performance Optimization

### For Production Use

1. **Upgrade Instance**: Use `t3.small` or larger
2. **RDS Database**: Move to AWS RDS PostgreSQL
3. **Load Balancer**: Add Application Load Balancer
4. **CDN**: Use CloudFront for static assets

### Scaling Considerations

- **Horizontal Scaling**: Use multiple EC2 instances
- **Vertical Scaling**: Increase instance size
- **Database**: Use RDS with read replicas

## 🔐 Security Checklist

- [ ] Security group configured correctly
- [ ] UFW firewall enabled
- [ ] SSL certificate installed
- [ ] Strong passwords generated
- [ ] Regular backups scheduled
- [ ] Automatic security updates enabled
- [ ] Monitoring alerts configured

---

## 🎉 Congratulations!

You now have a fully functional n8n instance running on AWS!

**Next Steps:**

1. Configure your workflows
2. Integrate with your favorite services
3. Set up monitoring alerts
4. Plan regular maintenance

**Remember to:**

- Keep your AWS costs under control
- Monitor resource usage
- Update regularly
- Backup frequently

Happy automating! 🚀

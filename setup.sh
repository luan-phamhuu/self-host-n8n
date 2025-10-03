#!/bin/bash

# n8n AWS Setup Script
# This script helps you set up n8n on AWS EC2

set -e

echo "🚀 n8n AWS Setup Script"
echo "======================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Ubuntu/Debian
if ! command -v apt-get &> /dev/null; then
    print_error "This script is designed for Ubuntu/Debian systems"
    exit 1
fi

print_status "Starting n8n setup on AWS EC2..."

# Update system packages
print_status "Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

# Install required packages
print_status "Installing required packages..."
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

# Install Docker
print_status "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
print_status "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
print_status "Adding current user to docker group..."
sudo usermod -aG docker $USER

# Create n8n directory
print_status "Creating n8n directory structure..."
mkdir -p ~/n8n/{nginx/ssl,backups}
cd ~/n8n

# Generate encryption key
print_status "Generating encryption key..."
ENCRYPTION_KEY=$(openssl rand -hex 32)
echo "Generated encryption key: $ENCRYPTION_KEY"

# Generate JWT secret
JWT_SECRET=$(openssl rand -base64 32)
echo "Generated JWT secret: $JWT_SECRET"

# Generate a secure database password
DB_PASSWORD=$(openssl rand -base64 32)
echo "Generated database password: $DB_PASSWORD"

# Create .env file
print_status "Creating environment configuration..."
cat > .env << EOF
# Database Configuration
DB_PASSWORD=$DB_PASSWORD

# n8n Configuration
N8N_HOST=ec2-54-254-253-15.ap-southeast-1.compute.amazonaws.com
N8N_PORT=5678
N8N_PROTOCOL=http

# Security
N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY
JWT_SECRET=$JWT_SECRET

# Email Configuration (Optional)
N8N_EMAIL_MODE='smtp'
N8N_SMTP_HOST=localhost
N8N_SMTP_PORT=587
N8N_SMTP_USER=
N8N_SMTP_PASS=

# Monitoring
N8N_PROMETHEUS=false
EOF

print_status "Setup completed successfully!"
print_warning "Important:"
echo "1. Copy docker-compose.yml to ~/n8n/"
echo "2. Update the .env file with your domain name"
echo "3. Restart your shell session: source ~/.bashrc"
echo "4. Run: cd ~/n8n && docker-compose up -d"

print_status "Your n8n will be available at: http://$(curl -s ifconfig.me):80"

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
mkdir -p ~/n8n-compose/local-files
cd ~/n8n-compose

# Create .env file
print_status "Creating environment configuration..."
cat > .env << EOF
# DOMAIN_NAME and SUBDOMAIN together determine where n8n will be reachable from
# The top level domain to serve from
DOMAIN_NAME=your-domain.com

# The subdomain to serve from
SUBDOMAIN=n8n

# The above example serve n8n at: https://n8n.your-domain.com

# Optional timezone to set which gets used by Cron and other scheduling nodes
GENERIC_TIMEZONE=UTC

# The email address to use for the TLS/SSL certificate creation
SSL_EMAIL=your-email@gmail.com
EOF

print_status "Setup completed successfully!"
print_warning "Important next steps:"
echo "1. Update the .env file with your actual domain name"
echo "2. Update the .env file with your email for SSL certificates"
echo "3. Restart your shell session: source ~/.bashrc"
echo "4. Run: cd ~/n8n-compose && docker compose up -d"
echo "5. Set up DNS A record pointing your domain to $(curl -s ifconfig.me)"
echo ""
print_status "Your n8n will be available at: https://n8n.your-domain.com (after DNS setup)"

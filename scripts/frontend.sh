#!/bin/bash

set -e

# ===========================
# Logging
# ===========================
exec > >(tee /var/log/frontend-setup.log)
exec 2>&1

echo "=========================================="
echo "Starting Frontend VM Configuration"
echo "=========================================="

# ===========================
# Variables
# ===========================
USERNAME="azureuser"
HOME_DIR="/home/$USERNAME"
APP_DIR="$HOME_DIR/azure-3tier-cineverse"
REPO_URL="https://github.com/Lokesh012/azure-3tier-cineverse.git"

# ===========================
# Update OS
# ===========================
echo "Updating Ubuntu..."
apt-get update -y
apt-get upgrade -y

# ===========================
# Install Packages
# ===========================
echo "Installing required packages..."
apt-get install -y \
git \
curl \
wget \
unzip \
build-essential \
nginx

# ===========================
# Install NVM
# ===========================
echo "Installing NVM..."

su - $USERNAME -c '
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
'

# Load NVM
export NVM_DIR="$HOME_DIR/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# ===========================
# Install Node.js
# ===========================
echo "Installing Node.js..."

nvm install 20
nvm use 20
nvm alias default 20

echo "Node Version:"
node -v

echo "NPM Version:"
npm -v

# ===========================
# Clone Repository
# ===========================
echo "Cloning Git Repository..."

if [ ! -d "$APP_DIR" ]; then
    git clone $REPO_URL $APP_DIR
else
    echo "Repository already exists."
fi

chown -R $USERNAME:$USERNAME $APP_DIR

# ===========================
# Build React Application
# ===========================
echo "Installing frontend dependencies..."

cd $APP_DIR/frontend

npm install

echo "Building React application..."

npm run build

# ===========================
# Deploy Frontend
# ===========================
echo "Deploying React build..."

rm -rf /var/www/html/*

cp -r dist/* /var/www/html/

# ===========================
# Nginx
# ===========================
echo "Starting Nginx..."

systemctl enable nginx

systemctl restart nginx

# ===========================
# Validation
# ===========================
echo "Checking Nginx status..."

systemctl status nginx --no-pager

echo "Testing Frontend..."

curl http://localhost

echo "=========================================="
echo "Frontend Deployment Completed Successfully"
echo "=========================================="
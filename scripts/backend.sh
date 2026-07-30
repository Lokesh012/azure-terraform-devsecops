#!/bin/bash

set -e

# ===========================
# Logging
# ===========================
exec > >(tee /var/log/backend-setup.log)
exec 2>&1

echo "=========================================="
echo "Starting Backend VM Configuration"
echo "=========================================="

# ===========================
# Variables
# ===========================
USERNAME="azureuser"
HOME_DIR="/home/$USERNAME"
APP_DIR="$HOME_DIR/azure-3tier-cineverse"
REPO_URL="https://github.com/Lokesh012/azure-3tier-cineverse.git"

# Database Configuration
DB_SERVER="cineverse-sql-server.database.windows.net"
DB_NAME="cineverse-sql-db"
DB_USER="sqladmin"
DB_PASSWORD="admin@123"
DB_PORT="1433"

# ===========================
# Update Ubuntu
# ===========================
echo "Updating Ubuntu..."

apt-get update -y
apt-get upgrade -y

# ===========================
# Install Packages
# ===========================
echo "Installing packages..."

apt-get install -y \
git \
curl \
wget \
unzip \
build-essential

# ===========================
# Install NVM
# ===========================
echo "Installing NVM..."

su - $USERNAME -c '
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
'

export NVM_DIR="$HOME_DIR/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

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
# Install PM2
# ===========================
echo "Installing PM2..."

npm install -g pm2

# ===========================
# Clone Repository
# ===========================
echo "Cloning repository..."

if [ ! -d "$APP_DIR" ]; then
    git clone $REPO_URL $APP_DIR
else
    echo "Repository already exists."
fi

chown -R $USERNAME:$USERNAME $APP_DIR

# ===========================
# Backend
# ===========================
cd $APP_DIR/backend

echo "Installing backend dependencies..."

npm install

# ===========================
# Create .env
# ===========================
echo "Creating .env file..."

cat > .env <<EOF
PORT=5000
DB_SERVER=$DB_SERVER
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_PORT=$DB_PORT
EOF

# ===========================
# Start Backend
# ===========================
echo "Starting Backend..."

pm2 delete cineverse-backend || true

pm2 start src/server.js \
--name cineverse-backend

pm2 save

pm2 startup systemd -u $USERNAME --hp $HOME_DIR

# ===========================
# Validation
# ===========================
echo "Checking PM2..."

pm2 status

sleep 15

echo "Testing Backend..."

curl http://localhost:5000

curl http://localhost:5000/api/movies || true

echo "=========================================="
echo "Backend Deployment Completed Successfully"
echo "=========================================="
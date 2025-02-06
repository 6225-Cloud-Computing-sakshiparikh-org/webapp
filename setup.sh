#!/bin/bash

# Exit on error
set -e

if [ -z "$DB_ROOT_PASSWORD" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USER" ]; then
    echo "Error: Required environment variables not set"
    echo "Please export: DB_ROOT_PASSWORD, DB_NAME, DB_USER"
    exit 1
fi

APP_USER="csye6225-cloud"
APP_GROUP="csye6225"
APP_DIR="/opt/csye6225"

echo "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

echo "Setting up swap space..."
if grep -q "/swapfile" /etc/fstab; then
    echo "Swap file already exists, skipping swap creation..."
else
    sudo swapoff /swapfile || true
    sudo rm -f /swapfile
    
    sudo fallocate -l 1G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

echo "Installing MySQL..."
sudo apt-get install -y mysql-server
echo "Configuring MySQL for low memory usage..."
sudo bash -c "cat > /etc/mysql/mysql.conf.d/mysqld.cnf << EOF
[mysqld]
performance_schema = off
key_buffer_size = 8M
max_connections = 10
innodb_buffer_pool_size = 64M
innodb_log_buffer_size = 2M
thread_cache_size = 4
host_cache_size = 0
table_open_cache = 256
tmp_table_size = 16M
max_heap_table_size = 16M
EOF"

echo "Cleaning up MySQL files..."
sudo systemctl stop mysql || true
sudo rm -rf /var/lib/mysql/*
sudo mkdir -p /var/lib/mysql
sudo chown -R mysql:mysql /var/lib/mysql
sudo chmod 750 /var/lib/mysql
sudo mysqld --initialize-insecure --user=mysql

echo "Starting MySQL service..."
sudo systemctl start mysql
sudo systemctl enable mysql

echo "Configuring MySQL root password..."
sudo mysql --user=root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

echo "Securing MySQL installation..."
sudo mysql -u root -p"${DB_ROOT_PASSWORD}" <<EOF
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

echo "Creating database..."
sudo mysql -u root -p"${DB_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
FLUSH PRIVILEGES;
EOF

echo "Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "Creating application group and user..."
sudo groupadd -f "${APP_GROUP}"
sudo useradd -m -g "${APP_GROUP}" -s /bin/bash "${APP_USER}" 2>/dev/null || true

echo "Setting up application directory..."
sudo mkdir -p "${APP_DIR}"
sudo chown -R "${APP_USER}:${APP_GROUP}" "${APP_DIR}"

echo "Installing unzip..."
sudo apt-get install -y unzip

echo "Unzipping application..."
if [ -f /tmp/webapp-fork.zip ]; then
    sudo unzip -o /tmp/webapp-fork.zip -d "${APP_DIR}/"
else
    echo "Error: webapp.zip not found in /tmp directory"
    exit 1
fi

echo "Setting permissions..."
sudo chown -R "${APP_USER}:${APP_GROUP}" "${APP_DIR}"
sudo chmod -R 755 "${APP_DIR}"

echo "Creating systemd service..."
sudo bash -c "cat > /etc/systemd/system/webapp.service << EOF
[Unit]
Description=Web Application
After=network.target mysql.service

[Service]
Type=simple
User=${APP_USER}
Group=${APP_GROUP}
WorkingDirectory=${APP_DIR}
ExecStart=/usr/bin/npm start
Restart=always
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF"

echo "Creating .env file..."
sudo -u "${APP_USER}" bash -c "cat > ${APP_DIR}/webapp-fork/.env << EOF
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASS=${DB_ROOT_PASSWORD}
DB_HOST=${DB_HOST:-localhost}
PORT=${PORT:-8080}
EOF"

echo "Setup completed successfully!"
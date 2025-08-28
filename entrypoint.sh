#!/bin/bash

if [[ "$1" == "setup" ]]; then
    echo "Setting up UNIT3D..."
    # Run setup commands here
    cd /var/www/html
    #composer install --no-interaction --prefer-dist
    #php artisan key:generate
    echo "Please save this to APP_KEY in UNIT3D/.env"
    echo "Setting correct permissions for MariaDB data directory..."
    sudo chown -R mysql:mysql /var/lib/mysql
    sudo chmod 750 /var/lib/mysql

    sudo chage -E -1 mysql

    echo "Initializing MariaDB system tables if necessary..."
    if [ ! -d "/var/lib/mysql/mysql" ]; then
        sudo mysql_install_db --basedir=/usr --datadir=/var/lib/mysql

        # Extract DB credentials from .env
        DB_USER=$(grep '^DB_USERNAME=' /var/www/html/.env | cut -d '=' -f2)
        DB_PASS=$(grep '^DB_PASSWORD=' /var/www/html/.env | cut -d '=' -f2)
        DB_NAME=$(grep '^DB_DATABASE=' /var/www/html/.env | cut -d '=' -f2)

        # Start MariaDB temporarily to create user and database
        sudo mysqld_safe --skip-networking &
        sleep 5

        # Create user, database, and grant privileges
        mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

        # Stop MariaDB
        mysqladmin -u root shutdown
    fi
    fi

    echo "Starting MariaDB..."

    su -s /bin/bash mysql -c "mysqld &"
    # Wait for MariaDB to be ready
    until mysqladmin ping -h "localhost" --silent; do
        echo "Waiting for MariaDB to be available..."
        sleep 2
    done
    # Keep MariaDB running in the background
    tail -f /dev/null 
    php artisan migrate:fresh --seed
    npm install -g bun || npm update -g bun
    #npm install
    #npm run build
fi
if [[ "$1" == "debug" ]]; then
    echo "Debug mode: keeping container running..."
    tail -f /dev/null
fi
if [[ -z "$1" ]]; then
    echo "Starting Nginx with /etc/nginx/conf.d/unit3d.conf..."
    nginx -c /etc/nginx/conf.d/unit3d.conf
fi
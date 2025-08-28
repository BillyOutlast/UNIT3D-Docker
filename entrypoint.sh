#!/bin/bash

if [[ "$1" == "setup" ]]; then
    echo "Setting up UNIT3D..."
    # Run setup commands here
    cd /var/www/html
    #composer install --no-interaction --prefer-dist
    #php artisan key:generate
    #echo "Please save this to APP_KEY in UNIT3D/.env"
    echo "Setting correct permissions for MariaDB data directory..."
    sudo chown -R mysql:mysql /var/lib/mysql
    sudo chmod -R 750 /var/lib/mysql

    sudo chage -E -1 mysql

    echo "Initializing MariaDB system tables if necessary..."
    if [ ! -d "/var/lib/mysql/mysql" ]; then
        su -s /bin/bash mysql -c "mysql_install_db --basedir=/usr --datadir=/var/lib/mysql"
    fi

    # Prevent tail from running on /dev/null, use a log file instead
    # Example: tail MariaDB log file to keep container alive and show logs


    su -s /bin/bash mysql -c "mysqld &"
    # Wait for MariaDB to be ready
    until mysqladmin ping -h "localhost" --silent; do
        echo "Waiting for MariaDB to be available..."
        sleep 2
    done
    python3 /database-setup.py
    # Keep MariaDB running in the background
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
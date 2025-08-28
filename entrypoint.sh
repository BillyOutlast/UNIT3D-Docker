#!/bin/bash

if [[ "$1" == "setup" ]]; then
    echo "Updating DNF packages..."
    sudo dnf -y update
    echo "Setting up UNIT3D..."
    sudo chown -R mysql:mysql /var/lib/mysql
    sudo chmod -R 750 /var/lib/mysql
    sudo chage -E -1 mysql
    echo "Initializing MariaDB system tables if necessary..."
    if [ ! -d "/var/lib/mysql/mysql" ]; then
        su -s /bin/bash mysql -c "mysql_install_db --basedir=/usr --datadir=/var/lib/mysql"
    fi
    echo "Setting correct permissions for MariaDB data directory..."
    su -s /bin/bash mysql -c "mysqld &"
    redis-server --daemonize yes
    php-fpm &

    # Wait for MariaDB to be ready
    until mysqladmin ping -h "localhost" --silent; do
        echo "Waiting for MariaDB to be available..."
        sleep 2
    done
    python3 /database-setup.py

    sudo chown -R unit3d:unit3d /var/www/html /home/unit3d/
    su -s /bin/bash unit3d -c "/setup.sh"
fi
if [[ "$1" == "debug" ]]; then
    echo "Debug mode: keeping container running..."
    tail -f /dev/null
fi


if [[ "$1" == "backup-mysql" ]]; then
    BACKUP_DIR="/backup"
    BACKUP_FILE="$BACKUP_DIR/mysql-$(date +%Y%m%d-%H%M%S).sql"
    mkdir -p "$BACKUP_DIR"
    echo "Backing up MySQL database to $BACKUP_FILE..."
    mysqldump --all-databases --single-transaction --quick --lock-tables=false -u root > "$BACKUP_FILE"
    if [[ $? -eq 0 ]]; then
        echo "Backup completed successfully."
    else
        echo "Backup failed."
        exit 1
    fi
fi

if [[ -z "$1" ]]; then
    echo "Updating DNF packages..."
    sudo dnf -y update
    pecl channel-update pecl.php.net
    pecl upgrade-all
    echo "Starting MySQL..."
    sudo chown -R mysql:mysql /var/lib/mysql
    sudo chmod -R 750 /var/lib/mysql
    sudo chage -E -1 mysql
    # Ensure correct ownership for /var/www/html
    sudo chown -R unit3d:unit3d /var/www/html
    su -s /bin/bash mysql -c "mysqld &"
    # Wait for MariaDB to be ready
    until mysqladmin ping -h "localhost" --silent; do
        echo "Waiting for MariaDB to be available..."
        sleep 2
    done
    echo "Starting Redis..."
    redis-server --daemonize yes
    echo "Starting PHP-FPM..."
    php-fpm &
    echo "Starting PHP Artisan server..."
    su -s /bin/bash unit3d -c "/run.sh"

fi
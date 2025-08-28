#!/bin/bash

if [[ "$1" == "setup" ]]; then
    echo "Setting up UNIT3D..."
    # Run setup commands here
    cd /var/www/html
    composer install --no-interaction --prefer-dist
    php artisan key:generate
    echo "Please save this to APP_KEY in UNIT3D/.env"
    echo "Setting correct permissions for MariaDB data directory..."
    sudo chown -R mysql:mysql /var/lib/mysql
    sudo chmod -R 750 /var/lib/mysql

    sudo chage -E -1 mysql

    echo "Initializing MariaDB system tables if necessary..."
    if [ ! -d "/var/lib/mysql/mysql" ]; then
        su -s /bin/bash mysql -c "mysql_install_db --basedir=/usr --datadir=/var/lib/mysql"
    fi

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
    bun install
    bun pm untrusted
    bun pm trust --all
    bun install
    bun run build

    php artisan set:all_cache
    php artisan queue:restart
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
    echo "Starting Nginx with /etc/nginx/conf.d/unit3d.conf..."
    nginx -c /etc/nginx/conf.d/unit3d.conf
fi
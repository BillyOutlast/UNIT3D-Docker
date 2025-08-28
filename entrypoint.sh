#!/bin/bash

if [[ "$1" == "setup" ]]; then
    echo "Setting up UNIT3D..."
    # Run setup commands here
    cd /var/www/html
    composer install --no-interaction --prefer-dist
    php artisan key:generate --show
    echo "Please save this to APP_KEY in UNIT3D/.env"
fi
if [[ "$1" == "debug" ]]; then
    echo "Debug mode: keeping container running..."
    tail -f /dev/null
fi
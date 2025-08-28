#!/bin/bash
# Run setup commands here
cd /var/www/html
composer install --no-interaction --prefer-dist
php artisan key:generate
echo "Please save this to APP_KEY in UNIT3D/.env"

# Keep MariaDB running in the background

php artisan migrate:fresh --seed
mkdir -p $HOME/.npm-packages
export NPM_PACKAGES="$HOME/.npm-packages"
PATH="$NPM_PACKAGES/bin:$PATH"
curl -fsSL https://bun.sh/install | bash
export BUN_INSTALL="$HOME/.bun" 
export PATH="$BUN_INSTALL/bin:$PATH" 
bun install
bun pm untrusted
bun pm trust --all
bun install
bun run build

php artisan set:all_cache
php artisan queue:restart

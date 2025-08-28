#!/bin/bash
cd /var/www/html
PATH="$NPM_PACKAGES/bin:$PATH"
curl -fsSL https://bun.sh/install | bash
export BUN_INSTALL="$HOME/.bun" 
export PATH="$BUN_INSTALL/bin:$PATH" 
/usr/bin/php -d variables_order=EGPCS /var/www/html/artisan serve --host=0.0.0.0 --port=80
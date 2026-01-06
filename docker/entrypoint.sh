#!/bin/bash

# Exit on fail
set -e

# Clear any stale bootstrap cache from the host
rm -f /var/www/bootstrap/cache/*.php

# Fix permissions for storage and cache immediately
echo "Fixing permissions..."
mkdir -p /var/www/storage/framework/{sessions,views,cache}
mkdir -p /var/www/storage/logs
mkdir -p /var/www/bootstrap/cache

chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Wait for database to be ready (simple wait)
echo "Waiting for database..."
sleep 5

# Force Laravel to use built assets (disable HMR)
rm -f public/hot

# Ensure storage link exists
echo "Creating storage link..."
php artisan storage:link || true

# Run migrations
echo "Running migrations..."
php artisan migrate --force --path="database/migrations/*"

# Cache config/routes/views for production
echo "Caching configuration..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Setup Vite for Local Development
if [ "$APP_ENV" = "local" ]; then
    echo "Setting up Vite for local development..."
    # Install node_modules if missing (mounted volume might be empty)
    if [ ! -d "node_modules" ]; then
        echo "Installing Node dependencies..."
        npm install
    fi

    # Create Supervisor config for Vite
    cat > /etc/supervisor/conf.d/vite.conf <<EOF
[program:vite]
command=npm run dev -- --host 0.0.0.0
user=www-data
autostart=true
autorestart=true
stdout_logfile=/var/www/storage/logs/vite.log
redirect_stderr=true
EOF
fi

# Start PHP-FPM
echo "Starting PHP-FPM..."
exec "$@"

#!/bin/bash

# Exit on fail
set -e

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
php artisan mfs

# Cache config/routes/views for production
echo "Caching configuration..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Start PHP-FPM
echo "Starting PHP-FPM..."
exec "$@"

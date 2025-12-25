#!/bin/bash

# Exit on fail
set -e

# Wait for database to be ready (simple wait)
echo "Waiting for database..."
sleep 5

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

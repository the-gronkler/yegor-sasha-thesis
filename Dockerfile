# Stage 1: Build Frontend Assets
FROM node:20-alpine as frontend

WORKDIR /app

COPY package.json package-lock.json ./
# Force install of linux-specific rollup binary
# TODO: add it to package.json it should be added to package.json as an optional dependency before building the image.
RUN npm ci --include=optional && npm install @rollup/rollup-linux-x64-musl --save-optional

COPY . .
RUN npm run build

# Stage 2: Build Backend & Serve
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    default-mysql-client \
    nginx \
    supervisor

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy composer files first to leverage cache
COPY composer.json composer.lock ./

# Install dependencies (skip scripts to avoid 'artisan not found' error)
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts

# Copy application code
COPY . .

# Run post-autoload scripts now that artisan is present
RUN composer dump-autoload --optimize

# Copy built frontend assets from Stage 1
COPY --from=frontend /app/public/build ./public/build

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u 1000 -d /home/dev dev
RUN mkdir -p /home/dev/.composer && \
    chown -R dev:dev /home/dev

# Set permissions
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Configure Nginx
COPY docker/nginx/default.conf /etc/nginx/sites-available/default
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Configure Supervisor
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy entrypoint
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

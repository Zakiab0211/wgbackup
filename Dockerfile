# Gunakan base image PHP dan Nginx
FROM php:8.1-fpm

# Setel direktori kerja
WORKDIR /var/www

# Salin semua file ke dalam container
COPY . .

# Install dependensi PHP
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-install zip pdo pdo_mysql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install dependensi Laravel
RUN composer install --optimize-autoloader --no-dev

# Salin konfigurasi Nginx
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Set permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www

# Expose port 80
EXPOSE 80

# Start PHP-FPM dan Nginx
CMD ["php-fpm"]

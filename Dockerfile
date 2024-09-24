# # Gunakan base image PHP dan Nginx
# FROM php:8.1-fpm

# # Setel direktori kerja
# WORKDIR /var/www

# # Salin semua file ke dalam container
# COPY . .

# # Install dependensi PHP
# RUN apt-get update && apt-get install -y \
#     libpng-dev \
#     libjpeg62-turbo-dev \
#     libfreetype6-dev \
#     libzip-dev \
#     zip \
#     unzip \
#     && docker-php-ext-configure gd --with-freetype --with-jpeg \
#     && docker-php-ext-install gd \
#     && docker-php-ext-install zip pdo pdo_mysql

# # Install Composer
# COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# # Install dependensi Laravel
# RUN composer install --optimize-autoloader --no-dev

# # Salin konfigurasi Nginx
# COPY nginx/nginx.conf /etc/nginx/nginx.conf

# # Set permissions
# RUN chown -R www-data:www-data /var/www \
#     && chmod -R 755 /var/www

# # Expose port 80
# EXPOSE 80

# # Start PHP-FPM dan Nginx
# CMD ["php-fpm"]

# Menggunakan image resmi PHP dengan PHP-FPM 8.1
FROM php:8.1-fpm

# Menetapkan direktori kerja di dalam container
WORKDIR /var/www/wgbackup

# Menyalin file composer untuk mengunduh dependensi proyek Laravel
COPY composer.json composer.lock /var/www/wgbackup/

# Install dependensi yang diperlukan untuk Laravel dan PHP extensions
RUN apt-get update && apt-get install -y \
    build-essential \
    mariadb-client \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    vim \
    unzip \
    git \
    curl \
    libzip-dev \
    zip && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install pdo pdo_mysql gd zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Instal Composer untuk manajemen dependensi PHP
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Membuat grup dan pengguna baru untuk menjalankan aplikasi
RUN groupadd -g 1000 www && \
    useradd -u 1000 -ms /bin/bash -g www www

# Mengubah kepemilikan direktori kerja ke user www
RUN chown -R www:www /var/www

# Menyalin seluruh file proyek ke dalam container
COPY --chown=www:www . /var/www/wgbackup

# Beralih ke user www
USER www

# Mengunduh dependensi Laravel
RUN composer install --no-scripts --no-autoloader && \
    composer dump-autoload && \
    composer install

# Menyalin file konfigurasi Laravel
COPY --chown=www:www .env.example /var/www/wgbackup/.env

# Menghasilkan application key Laravel
RUN php artisan key:generate

# Mengatur permissions untuk storage dan bootstrap/cache agar Laravel bisa menulis ke direktori tersebut
RUN chmod -R 775 /var/www/wgbackup/storage /var/www/wgbackup/bootstrap/cache

# Mengekspos port 9000 untuk PHP-FPM
EXPOSE 9000

# Menjalankan PHP-FPM server
CMD ["php-fpm"]

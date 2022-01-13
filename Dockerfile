FROM php:8.1.1-apache-bullseye

LABEL maintainer="Bohdan Burym <bgdn2007@ukr.net>" \
      version="1.0"

COPY --chown=www-data:www-data . /srv/app

COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /srv/app



RUN apt-get update && apt-get install -y \
        libonig-dev \
        openssl \
        zip \
        unzip \
        git \
        curl \
        libpng-dev \
        libxml2-dev

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN pecl install redis-5.3.5 \
    && docker-php-ext-enable redis


RUN docker-php-ext-install mbstring pdo pdo_mysql \
    && a2enmod rewrite negotiation \
    && docker-php-ext-install opcache

RUN composer install --no-scripts --no-ansi --no-interaction --working-dir=/srv/app

RUN chmod -R o+w /srv/app/storage
RUN chown -R www-data:www-data ./storage
RUN chgrp -R www-data storage bootstrap/cache
RUN chmod -R ug+rwx storage bootstrap/cache
RUN chmod -R 755 /srv/app/
RUN find /srv/app/ -type d -exec chmod 775 {} \;
RUN chown -R www-data:www-data /srv/app
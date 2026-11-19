# --------------------------------------------------
# PHP / Apache
# --------------------------------------------------
FROM php:8.5-apache

ARG IMAGEMAGICK_VERSION=7.1.2-25
ARG IMAGICK_VERSION=3.8.1

ENV DEBIAN_FRONTEND=noninteractive

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# --------------------------------------------------
# System dependencies
# --------------------------------------------------
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        git \
        build-essential \
        pkg-config \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libwebp-dev \
        libzip-dev \
        libicu-dev \
        libxml2-dev \
        libltdl-dev \
        locales-all \
        rsyslog \
        sendmail \
    && rm -rf /var/lib/apt/lists/*

# --------------------------------------------------
# PHP extensions
# --------------------------------------------------
RUN docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    && docker-php-ext-install -j"$(nproc)" \
        exif \
        iconv \
        intl \
        mysqli \
        pdo_mysql \
        xml \
        zip \
        gd

# --------------------------------------------------
# ImageMagick 7
# --------------------------------------------------
RUN git clone \
        --depth 1 \
        --branch "${IMAGEMAGICK_VERSION}" \
        https://github.com/ImageMagick/ImageMagick.git \
        /tmp/ImageMagick \
    && cd /tmp/ImageMagick \
    && ./configure --with-modules \
    && make -j"$(nproc)" \
    && make install \
    && ldconfig \
    && cd / \
    && rm -rf /tmp/ImageMagick

# --------------------------------------------------
# Imagick PHP extension
# --------------------------------------------------
RUN if [ -n "${HTTP_PROXY:-}" ]; then \
        pear config-set http_proxy "${HTTP_PROXY}"; \
    fi \
    && pecl install "imagick-${IMAGICK_VERSION}" \
    && docker-php-ext-enable imagick \
    && rm -rf /tmp/pear

# --------------------------------------------------
# Apache modules
# --------------------------------------------------
RUN a2dismod status \
    && a2enmod cache expires rewrite headers

# --------------------------------------------------
# Apache configuration
# --------------------------------------------------
COPY files/apache/mods/*.conf /etc/apache2/mods-available/
COPY files/apache/conf/*.conf /etc/apache2/conf-available/

# --------------------------------------------------
# PHP configuration
# --------------------------------------------------
COPY files/php/*.ini /usr/local/etc/php/conf.d/

# --------------------------------------------------
# Rsyslog service script
# --------------------------------------------------
COPY files/rsyslog/rsyslog /etc/init.d/rsyslog

RUN chmod a+x /etc/init.d/rsyslog

# --------------------------------------------------
# Application directories
# --------------------------------------------------
RUN mkdir -p \
        /var/www/dataroot \
        /var/www/cacheroot \
        /var/www/assetroot \
    && chown -R www-data:www-data \
        /var/www/dataroot \
        /var/www/cacheroot \
        /var/www/assetroot

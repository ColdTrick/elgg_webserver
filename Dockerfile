# PHP container
FROM php:8.3-apache

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Install additional php modules
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
		git \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libmagickwand-dev \
		libwebp-dev \
		libzip-dev \
		locales-all \
        rsyslog \
		sendmail \
    && apt-get autoclean \
    && apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/*

# copy rsyslog service script (Debian 12 is missing this)
# @see https://github.com/rsyslog/rsyslog/issues/5324
COPY files/rsyslog/rsyslog /etc/init.d/
# make sure it's executable
RUN chmod a+x /etc/init.d/rsyslog

# Enable/configure PHP modules
RUN docker-php-ext-install -j$(nproc) exif iconv intl mysqli opcache pdo pdo_mysql xml zip \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
	&& docker-php-ext-install -j$(nproc) gd

# Install ImageMagick 7.0 (not available in apt-get)
RUN git clone https://github.com/ImageMagick/ImageMagick.git /tmp/ImageMagick \
	&& cd /tmp/ImageMagick \
	&& ./configure --with-modules \
	&& make \
	&& make install \
	&& ldconfig /usr/local/lib \
	&& cd /tmp \
	&& rm -R /tmp/ImageMagick \
	&& apt-get remove -y git

# Install imagick
RUN if [ ! -z ${HTTP_PROXY} ] ; then pear config-set http_proxy ${HTTP_PROXY} ; fi
RUN pecl update-channels \
	&& echo "\n" | pecl install imagick \
	&& docker-php-ext-enable imagick

# Disable / enable mods for Apache
RUN a2dismod status \
	&& a2enmod cache expires rewrite headers \
	&& service apache2 restart

# Create dataroot directory
RUN mkdir /var/www/dataroot \
	&& chown -R www-data:www-data /var/www/dataroot

# Create cacheroot directory
RUN mkdir /var/www/cacheroot \
	&& chown -R www-data:www-data /var/www/cacheroot

# Create assetroot directory
RUN mkdir /var/www/assetroot \
	&& chown -R www-data:www-data /var/www/assetroot

# copy Apache config adjustments
COPY files/apache/mods/*.conf /etc/apache2/mods-available/
COPY files/apache/conf/*.conf /etc/apache2/conf-available/

# copy PHP ini adjustments
COPY files/php/*.ini /usr/local/etc/php/conf.d/

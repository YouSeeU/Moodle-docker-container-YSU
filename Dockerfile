FROM ubuntu:16.04
MAINTAINER Aleksandr Belous

RUN apt-get update -y
RUN apt-get install -y \
	vim \
	zip \
	curl \
	wget \
	apache2 \
	php7.0 \
	php7.0-cli \
	libapache2-mod-php7.0 \
	php7.0-intl \
	php7.0-gd \
	php7.0-curl \
	php7.0-mysql \
	php-pear \
	php7.0-dev \
	php-xdebug \
	php-mbstring \
	php7.0-mbstring \
	php-memcached \
	php-memcache

RUN apt-get clean \
 	&& rm -rf /var/lib/apt/lists/*

## setup locale

# Set the locale
RUN apt-get clean && apt-get update && apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

## install composer

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

## install timezonedb

RUN pecl install timezonedb
RUN sed -i '$ a\extension=timezonedb.so' /etc/php/7.0/apache2/php.ini
RUN sed -i '$ a\extension=timezonedb.so' /etc/php/7.0/cli/php.ini


RUN a2dissite 000-default
COPY app_vhost.conf /etc/apache2/sites-available/
COPY app_vhost_ssl.conf /etc/apache2/sites-available/
RUN a2ensite app_vhost app_vhost_ssl

RUN mkdir -p /usr/local/openssl/include/openssl/ && \
    ln -s /usr/include/openssl/evp.h /usr/local/openssl/include/openssl/evp.h && \
    mkdir -p /usr/local/openssl/lib/ && \
    ln -s /usr/lib/x86_64-linux-gnu/libssl.a /usr/local/openssl/lib/libssl.a && \
    ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/local/openssl/lib/
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
	php-memcache \
	git \
	php7.0-zip
RUN apt-get clean \
 	&& rm -rf /var/lib/apt/lists/*


RUN a2enmod rewrite ssl headers
RUN mkdir /etc/apache2/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/app.key -out /etc/apache2/ssl/app.crt -subj /C=US/ST=New\ York/L=New\ York\ City/O=SuperDeveloper/OU=Developers/CN=localhost

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
RUN rm -rf /etc/apache2/ports.conf
COPY ports.conf /etc/apache2/
RUN a2ensite app_vhost app_vhost_ssl

RUN mkdir -p /usr/local/openssl/include/openssl/ && \
    ln -s /usr/include/openssl/evp.h /usr/local/openssl/include/openssl/evp.h && \
    mkdir -p /usr/local/openssl/lib/ && \
    ln -s /usr/lib/x86_64-linux-gnu/libssl.a /usr/local/openssl/lib/libssl.a && \
    ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/local/openssl/lib/

EXPOSE 80 443

RUN mkdir /unison
RUN mkdir -p /home/webapp

RUN ln -s /unison /home/webapp/htdocs
RUN git clone --depth=1 -b MOODLE_33_STABLE git://git.moodle.org/moodle.git /unison
COPY app_start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/app_start.sh
CMD ["/usr/local/bin/app_start.sh"]
#RUN wget  "https://download.moodle.org/download.php/stable33/moodle-latest-33.zip"
FROM moodlehq/moodle-php-apache:7.1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-transport-https \
    git \
    mysql-client

# download Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# download Moodle
RUN git clone --depth=1 -b MOODLE_33_STABLE git://git.moodle.org/moodle.git /var/www/html/

# download Moosh
RUN git clone --depth=1 git://github.com/tmuras/moosh.git /var/www/html/moosh \
 && cd /var/www/html/moosh \
 && composer install --no-dev

# add virtual host for https
COPY apache /etc/apache2/
RUN a2enmod ssl

COPY moodle-config.php /var/www/html/config.php
COPY db/moodle_db.sql /tmp
COPY app_start.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/app_start.sh

EXPOSE 80 444
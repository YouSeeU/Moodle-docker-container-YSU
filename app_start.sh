#!/bin/bash
echo "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE_NAME;" | mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD

/usr/bin/php /unison/admin/cli/mysql_collation.php --collation=utf8mb4_unicode_ci
/usr/bin/php /unison/admin/cli/install_database.php --agree-license --adminuser=$MOODLE_USERNAME --adminpass=$MOODLE_PASSWORD --adminemail=$MOODLE_EMAIL --fullname=$MOODLE_SITENAME --shortname=$MOODLE_SITENAME_SHORT
#mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE_NAME < /usr/local/bin/lti_settings.sql
set -e

source /etc/apache2/envvars

rm -f $APACHE_PID_FILE

exec /usr/sbin/apache2 -D FOREGROUND


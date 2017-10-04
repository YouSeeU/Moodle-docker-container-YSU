#!/bin/bash
set -e

source /etc/apache2/envvars

rm -f $APACHE_PID_FILE

exec /usr/sbin/apache2 -D FOREGROUND

/usr/bin/php /unison/admin/cli/install_database.php --agree-license --adminuser=admin --adminpass='test!QAZ2wsx' --adminemail=test@example.com --fullname=test --shortname=test
/usr/bin/php /unison/admin/cli/mysql_collation.php --collation=utf8mb4_unicode_ci

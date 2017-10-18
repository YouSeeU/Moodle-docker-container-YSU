#!/bin/bash
echo "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE_NAME;" | mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD
sed -i "s/\${YSU_HOST}/$YSU_HOST/g" /usr/local/bin/moodle_db.sql
/usr/bin/php /unison/admin/cli/mysql_collation.php --collation=utf8mb4_unicode_ci
mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE_NAME < /usr/local/bin/moodle_db.sql
/usr/bin/php /unison/admin/cli/reset_password.php --username=admin --password=$MOODLE_PASSWORD --ignore-password-policy
/usr/bin/php /unison/admin/cli/reset_password.php --username=student --password=$MOODLE_PASSWORD --ignore-password-policy
/usr/bin/php /unison/admin/cli/reset_password.php --username=contentdeveloper  --password=$MOODLE_PASSWORD --ignore-password-policy
set -e

source /etc/apache2/envvars

rm -f $APACHE_PID_FILE

exec /usr/sbin/apache2 -D FOREGROUND

#!/bin/bash

echo 'Waiting for Mysql server to be available...'
maxTries=10; try=0
while [ "$try" -lt "$maxTries" ] && ! mysql -h "$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e 'DO 1'; do
    sleep 10
    try=$(($try+1))
    echo $try
done
if [ "$try" -ge "$maxTries" ]; then
    echo >&2 "Error: unable to connect with Mysql after $maxTries tries"
    exit 1
fi

MOODLE_CLI_DIR="/var/www/html/admin/cli"

if [[ ! $(mysql -h "$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '"$MYSQL_DATABASE_NAME"'") ]] ; then
    echo "Database does not exist. Trying to create ..."

    php "$MOODLE_CLI_DIR/install.php"  --wwwroot="$MOODLE_URL" --dbtype="$DATABASE_TYPE" --dbhost="$MYSQL_HOST" --dbname="$MYSQL_DATABASE_NAME" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --fullname="$MOODLE_SITENAME" --shortname="$MOODLE_SITENAME_SHORT" --adminuser="$MOODLE_USERNAME" --adminpass="$MOODLE_PASSWORD" --adminemail="admin@moodle.loc" --agree-license=1 --non-interactive

    chmod a+r /var/www/html/config.php

    php "$MOODLE_CLI_DIR/mysql_collation.php" --collation=utf8mb4_unicode_ci > /dev/null
    # creating educators
    for i in `seq 1 3`; do
       php /var/www/html/moosh/moosh.php -n user-create "educator-$i" > /dev/null
    done
    # creating students
    for i in `seq 1 10`; do
       php /var/www/html/moosh/moosh.php -n user-create "student-$i" > /dev/null
    done
fi

echo "Database exist. Let's check it."
php "$MOODLE_CLI_DIR/check_database_schema.php"
if [ $? -ne 0 ]; then
    echo "Database is not OK"
    exit 1
fi

# update Admin's password
php "$MOODLE_CLI_DIR/reset_password.php" --username=admin --password="$MOODLE_PASSWORD" --ignore-password-policy
# updating educators password
for i in `seq 1 3`; do
    php "$MOODLE_CLI_DIR/reset_password.php" --username="educator-$i" --password="$MOODLE_PASSWORD" --ignore-password-policy > /dev/null
done
# updating students password
for i in `seq 1 10`; do
    php "$MOODLE_CLI_DIR/reset_password.php" --username="student-$i" --password="$MOODLE_PASSWORD" --ignore-password-policy > /dev/null
done

apachectl -D FOREGROUND


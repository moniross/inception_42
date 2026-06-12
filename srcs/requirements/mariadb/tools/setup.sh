#!/bin/sh

set -eu

if [ -d "/var/lib/mysql/wordpress" ]; then
	echo "Database already exists"
else
	echo "Initializing MariaDB..."

	mysql_install_db --user=mysql --datadir=/var/lib/mysql

	DB_PASSWORD=$(cat /run/secrets/db_password)
	DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

	mysqld --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'mofouzi'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'mofouzi'@'%';
FLUSH PRIVILEGES;
EOF
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql
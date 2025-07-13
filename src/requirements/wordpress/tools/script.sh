#!/bin/bash

# Function to read secret from file
read_secret() {
	local secret_file="$1"
	if [ -f "$secret_file" ]; then
		cat "$secret_file"
	else
		echo "Error: Secret file '$secret_file' not found." >&2
		exit 1
	fi
}

cd /var/www/html
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

DB_NAME=$(read_secret "/run/secrets/DB_NAME")
DB_USER=$(read_secret "/run/secrets/DB_USER")
DB_USER_PWD=$(read_secret "/run/secrets/DB_USER_PWD")
DB_MASTER_USER=$(read_secret "/run/secrets/DB_MASTER_USER")
DB_MASTER_PWD=$(read_secret "/run/secrets/DB_MASTER_PWD")
WP_MASTER_USER=$(read_secret "/run/secrets/WP_MASTER_USER")
WP_MASTER_PWD=$(read_secret "/run/secrets/WP_MASTER_PWD")
WP_MASTER_EMAIL=$(read_secret "/run/secrets/WP_MASTER_EMAIL")
WP_USER=$(read_secret "/run/secrets/WP_USER")
WP_USER_PWD=$(read_secret "/run/secrets/WP_USER_PWD")
WP_USER_EMAIL=$(read_secret "/run/secrets/WP_USER_EMAIL")

echo $DB_NAME
echo $DB_USER
echo $DB_USER_PWD
echo $DB_MASTER_USER
echo $DB_MASTER_PWD
echo $WP_MASTER_EMAIL


chmod +x wp-cli.phar

echo "Downloading WordPress..."
./wp-cli.phar core download --allow-root
echo "Configuring WordPress..."
./wp-cli.phar config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_USER_PWD" --dbhost=mariadb --allow-root
./wp-cli.phar core install --url=https://daparici.42.fr --title=inception --admin_user="$WP_MASTER_USER" --admin_password="$WP_MASTER_PWD" --admin_email="$WP_MASTER_EMAIL" --allow-root
./wp-cli.phar user create "$WP_USER" "$WP_USER_EMAIL" --role=author --user_pass="$WP_USER_PWD" --allow-root
./wp-cli.phar option update siteurl "https://daparici.42.fr" --allow-root
./wp-cli.phar option update home "https://daparici.42.fr" --allow-root
# Ensure the /run/php directory exists
mkdir -p /run/php

php-fpm7.4 -F
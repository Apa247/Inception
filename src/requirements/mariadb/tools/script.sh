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

DB_MASTER_USER=$(read_secret "/run/secrets/DB_MASTER_USER")
DB_MASTER_PWD=$(read_secret "/run/secrets/DB_MASTER_PWD")
DB_USER=$(read_secret "/run/secrets/DB_USER")
DB_USER_PWD=$(read_secret "/run/secrets/DB_USER_PWD")
DB_NAME=$(read_secret "/run/secrets/DB_NAME")
DB_ROOT_PWD=$(read_secret "/run/secrets/DB_ROOT_PWD")

echo "DEBUG - DB_MASTER_PWD: $DB_MASTER_PWD"
echo "DEBUG - DB_USER: $DB_USER"
echo "DEBUG - DB_USER_PWD: $DB_USER_PWD"
echo "DEBUG - DB_NAME: $DB_NAME"
echo "DEBUG - DB_ROOT_PWD: $DB_ROOT_PWD"

# Ensure data directory exists and set proper ownership
mkdir -p /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql

# Explicitly create the socket directory and set permissions
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld
chmod 777 /run/mysqld # Give broad permissions for testing

# Start MariaDB in the background
/usr/sbin/mariadbd --user=mysql &

# Espera a que MariaDB acepte conexiones
until mysqladmin ping -u root -p"$DB_ROOT_PWD" --silent; do
  echo "Waiting for MariaDB to be ready..."
  sleep 2
done

# Wait for MariaDB to be ready
while [ ! -S /var/run/mysqld/mysqld.sock ]; do
  echo "Waiting for MariaDB socket..."
  sleep 2
done

# Initialize the database
mysql -u root -p"$DB_ROOT_PWD" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
mysql -u root -p"$DB_ROOT_PWD" -e "CREATE USER IF NOT EXISTS '$DB_USER' IDENTIFIED BY '$DB_USER_PWD';"
mysql -u root -p"$DB_ROOT_PWD" -e "CREATE USER IF NOT EXISTS '$DB_MASTER_USER' IDENTIFIED BY '$DB_MASTER_PWD';"
mysql -u root -p"$DB_ROOT_PWD" -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX, LOCK TABLES, EXECUTE ON $DB_NAME.* TO '$DB_USER';"
mysql -u root -p"$DB_ROOT_PWD" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_MASTER_USER';"
mysql -u root -p"$DB_ROOT_PWD" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PWD' WITH GRANT OPTION;"
mysql -u root -p"$DB_ROOT_PWD" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' IDENTIFIED BY '$DB_ROOT_PWD' WITH GRANT OPTION;"
mysql -u root -p"$DB_ROOT_PWD" -e "FLUSH PRIVILEGES;"

echo "MariaDB initialization complete."

# Keep the container running
exec /usr/sbin/mariadbd --user=mysql

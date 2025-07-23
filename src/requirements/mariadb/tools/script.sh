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

# Verificar si la base de datos necesita inicialización
echo "DEBUG - Verificando directorio: /var/lib/mysql/mysql"
ls -la /var/lib/mysql/ || echo "Directorio /var/lib/mysql/ no existe"

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Inicializando base de datos MariaDB..."
    
    # Instalar base de datos inicial
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # Configurar base de datos usando bootstrap (sin daemon)
    /usr/sbin/mariadbd --user=mysql --bootstrap <<EOF
USE mysql;
FLUSH PRIVILEGES;

-- Configurar contraseña de root (SOLO en inicialización)
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PWD';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PWD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' IDENTIFIED BY '$DB_ROOT_PWD' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOF
    
    echo "MariaDB initialization complete."
fi

# ✅ CONFIGURACIÓN COMÚN (se ejecuta SIEMPRE)
echo "Configurando base de datos y usuarios..."

/usr/sbin/mariadbd --user=mysql --bootstrap <<EOF
USE mysql;
FLUSH PRIVILEGES;

-- Crear base de datos si no existe
CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- Crear usuarios remotos si no existen  
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_USER_PWD';
CREATE USER IF NOT EXISTS '$DB_MASTER_USER'@'%' IDENTIFIED BY '$DB_MASTER_PWD';

-- Asignar permisos remotos
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX, LOCK TABLES, EXECUTE ON $DB_NAME.* TO '$DB_USER'@'%';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_MASTER_USER'@'%';

FLUSH PRIVILEGES;
EOF

echo "Configuración de base de datos y usuarios completada."

echo "Iniciando servidor MariaDB..."

# Iniciar MariaDB como proceso principal (CUMPLE TODAS LAS REGLAS)
exec /usr/sbin/mariadbd --user=mysql --bind-address=0.0.0.0

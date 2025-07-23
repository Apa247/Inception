#!/bin/bash
# ==============================================================================
# HEALTHCHECK SCRIPT FOR MARIADB
# ==============================================================================
# 
# PROBLEMA RESUELTO:
# El healthcheck original en docker-compose.yml tenía el problema de que
# intentaba usar $DB_ROOT_PWD como variable de entorno, pero esta variable
# no estaba definida en el contenedor. Esto causaba errores de "Access denied"
# cada 5 segundos porque el healthcheck fallaba constantemente.
#
# SOLUCIÓN:
# Este script lee la contraseña de root directamente del archivo de secreto
# montado por Docker Compose en /run/secrets/DB_ROOT_PWD y la usa para
# hacer ping a la base de datos de forma segura.
#
# VENTAJAS:
# - Elimina los errores de "Access denied" en los logs
# - Permite que el healthcheck funcione correctamente
# - Mantiene la seguridad usando Docker secrets
# - Es más robusto que intentar expandir variables en el healthcheck
# ==============================================================================

# Leer la contraseña de root desde el archivo de secreto
DB_ROOT_PWD=$(cat /run/secrets/DB_ROOT_PWD)

# Usar mysqladmin para hacer ping a la base de datos con la contraseña correcta
mysqladmin ping -u root -p"$DB_ROOT_PWD"

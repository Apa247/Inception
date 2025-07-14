FROM debian:bullseye-slim

EXPOSE 3306

RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*


COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/mariadb.cnf /etc/mysql/mariadb.cnf
#COPY tools/init.sql /etc/mysql/init.sql

COPY tools/script.sh .
# SOLUCIÓN HEALTHCHECK: Copiar el script de healthcheck personalizado
# Este script resuelve el problema de "Access denied" leyendo la contraseña
# directamente del archivo de secreto en lugar de usar variables de entorno
COPY tools/healthcheck.sh .

RUN mkdir /run/mysqld && chmod +x script.sh && chmod +x healthcheck.sh

CMD ["./script.sh"]
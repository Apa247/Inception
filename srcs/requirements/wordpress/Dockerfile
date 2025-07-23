FROM debian:bullseye-slim

# Actualizar e instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysqli \
    curl

EXPOSE 9000

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf


COPY tools/script.sh .
RUN chmod +x script.sh

# Ejecutar php-fpm en primer plano
CMD ["./script.sh"]
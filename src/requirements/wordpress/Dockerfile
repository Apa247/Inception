FROM debian:bookworm-slim

# Actualizar e instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysqli \
    curl

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/script.sh .
RUN chmod +x script.sh

# Ejecutar php-fpm en primer plano
CMD ["./script.sh"]
FROM debian:bookworm-slim

# Actualizar e instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    php-fpm 

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Ejecutar php-fpm en primer plano
CMD ["php-fpm8.2", "-F"]
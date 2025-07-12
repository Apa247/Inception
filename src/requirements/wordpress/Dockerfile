FROM debian:bookworm-slim

# Actualizar e instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    php-fpm 

# Ejecutar php-fpm en primer plano
CMD ["php-fpm8.2", "-F"]
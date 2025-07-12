# Dockerfile para nginx usando Debian 11 slim
FROM debian:bullseye-slim

# Instalamos nginx y openssl para TLS
RUN apt-get update && apt-get install -y nginx openssl curl && rm -rf /var/lib/apt/lists/*

# Copiamos la configuración personalizada de nginx
#COPY conf/nginx.conf /etc/nginx/nginx.conf

# Exponemos el puerto 443 para HTTPS
#EXPOSE 443

# Ejecutamos nginx en primer plano para que el contenedor no se detenga
CMD ["nginx", "-g", "daemon off;"]
# Dockerfile para nginx usando Debian 11 slim
FROM debian:bullseye-slim

# Instalamos nginx y openssl para TLS
RUN apt-get update && apt-get install -y nginx openssl curl && rm -rf /var/lib/apt/lists/*

# Generamos un certificado autofirmado para HTTPS
RUN mkdir -p /etc/ssl/private && \
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -sha256\
	-keyout /etc/ssl/certs/cert-key.pem \
	-out /etc/ssl/certs/cert.pem \
	-subj "/C=Es/ST=S/L=Madrid/O=42Madrid/CN=cert_daparici.com"
# Copiamos la configuración personalizada de nginx
COPY conf/default /etc/nginx/sites-available/default

# Exponemos el puerto 443 para HTTPS
EXPOSE 443

# Ejecutamos nginx en primer plano para que el contenedor no se detenga
CMD ["nginx", "-g", "daemon off;"]
#!/bin/bash

# ==============================================================================
# SCRIPT DE INSTALACIÓN RÁPIDA - PROYECTO INCEPTION
# ==============================================================================
# Versión simplificada para instalación rápida de dependencias esenciales
# ==============================================================================

set -e

echo "🚀 Instalación rápida de dependencias para Inception..."

# Actualizar sistema
echo "📦 Actualizando sistema..."
sudo apt update -y && sudo apt upgrade -y

# Instalar dependencias básicas
echo "🔧 Instalando dependencias básicas..."
sudo apt install -y curl wget git make vim

# Instalar Docker
echo "🐳 Instalando Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
rm get-docker.sh

# Instalar Docker Compose
echo "🔨 Instalando Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Iniciar Docker
echo "🚀 Iniciando Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# Crear directorios
echo "📁 Creando directorios..."
mkdir -p /home/$USER/data/{wordpress,mariadb}

echo "✅ ¡Instalación completada!"
echo "⚠️  IMPORTANTE: Ejecuta 'newgrp docker' o reinicia tu sesión"
echo "🔍 Verifica con: docker --version && docker-compose --version"

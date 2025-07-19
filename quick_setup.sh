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

# Instalar Visual Studio Code
echo "💻 Instalando Visual Studio Code..."
# Agregar la clave GPG de Microsoft
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'

# Actualizar e instalar VS Code
sudo apt update -y
sudo apt install -y code

# Limpiar archivo temporal
rm -f packages.microsoft.gpg

echo "✅ Visual Studio Code instalado"

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

# Inicializar Docker Swarm
echo "🐝 Inicializando Docker Swarm..."
if ! docker info | grep -q "Swarm: active"; then
    # Obtener la IP principal del sistema
    HOST_IP=$(ip route get 8.8.8.8 | awk '{print $7; exit}')
    
    if [ -z "$HOST_IP" ]; then
        echo "⚠️  No se pudo detectar la IP automáticamente, usando 127.0.0.1"
        HOST_IP="127.0.0.1"
    fi
    
    echo "📍 Inicializando swarm con IP: $HOST_IP"
    docker swarm init --advertise-addr $HOST_IP
    echo "✅ Docker Swarm inicializado"
else
    echo "ℹ️  Docker Swarm ya está activo"
fi

# Crear directorios
echo "📁 Creando directorios..."
mkdir -p /home/$USER/data/{wordpress,mariadb}

# Configurar sudo sin contraseña para el usuario actual
echo "🔐 Configurando sudo sin contraseña..."
echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER > /dev/null
sudo chmod 0440 /etc/sudoers.d/$USER

echo "✅ ¡Instalación completada!"
echo "⚠️  IMPORTANTE: Ejecuta 'newgrp docker' o reinicia tu sesión"
echo "🔍 Verifica con: docker --version && docker-compose --version"
echo "🐝 Docker Swarm inicializado y listo para usar secrets"
echo "🔓 Tu usuario ahora puede ejecutar sudo sin contraseña"
echo "💻 Visual Studio Code instalado - ejecuta 'code' para abrir"

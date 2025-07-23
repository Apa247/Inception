#!/bin/bash

# ==============================================================================
# SCRIPT DE INSTALACIÓN DE DEPENDENCIAS - PROYECTO INCEPTION
# ==============================================================================
# Este script instala todas las dependencias necesarias para ejecutar el
# proyecto Inception en una máquina virtual con Ubuntu 24.04 LTS.
#
# Autor: GitHub Copilot
# Fecha: 22 de Julio, 2025
# Sistema: Ubuntu 24.04 LTS (Compatible también con 22.04)
# ==============================================================================

set -e  # Salir si cualquier comando falla

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Verificar que estamos en Ubuntu 24.04 o 22.04
check_ubuntu_version() {
    log "Verificando versión de Ubuntu..."
    
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        if [[ "$ID" == "ubuntu" ]]; then
            case "$VERSION_ID" in
                "24.04")
                    log "✅ Ubuntu 24.04 LTS detectado correctamente"
                    UBUNTU_VERSION="24.04"
                    ;;
                "22.04")
                    log "✅ Ubuntu 22.04 LTS detectado correctamente"
                    UBUNTU_VERSION="22.04"
                    ;;
                *)
                    warning "⚠️  Este script está optimizado para Ubuntu 24.04 LTS y 22.04 LTS"
                    warning "    Versión actual: $ID $VERSION_ID"
                    read -p "¿Deseas continuar de todos modos? (y/N): " -n 1 -r
                    echo
                    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                        exit 1
                    fi
                    UBUNTU_VERSION="$VERSION_ID"
                    ;;
            esac
        else
            warning "⚠️  Sistema detectado: $ID $VERSION_ID"
            warning "    Este script está diseñado para Ubuntu 24.04 LTS"
            read -p "¿Deseas continuar de todos modos? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    else
        error "No se pudo detectar la versión del sistema operativo"
        exit 1
    fi
}

# Actualizar sistema
update_system() {
    log "Actualizando sistema..."
    sudo apt update -y
    sudo apt upgrade -y
    log "✅ Sistema actualizado"
}

# Instalar dependencias básicas
install_basic_dependencies() {
    log "Instalando dependencias básicas..."
    
    # Dependencias base comunes
    BASIC_PACKAGES=(
        apt-transport-https
        ca-certificates
        curl
        gnupg
        lsb-release
        software-properties-common
        wget
        git
        make
        vim
        net-tools
        htop
        tree
        unzip
    )
    
    # Agregar paquetes específicos para Ubuntu 24.04
    if [[ "$UBUNTU_VERSION" == "24.04" ]]; then
        BASIC_PACKAGES+=(
            gpg-agent
            dirmngr
        )
        log "ℹ️  Agregando paquetes específicos para Ubuntu 24.04"
    fi
    
    sudo apt install -y "${BASIC_PACKAGES[@]}"
    
    log "✅ Dependencias básicas instaladas"
}

# Instalar Docker
install_docker() {
    log "Instalando Docker..."
    
    # Remover versiones anteriores de Docker si existen
    sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Crear directorio para keyrings si no existe
    sudo mkdir -p /etc/apt/keyrings
    
    # Agregar la clave GPG oficial de Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Detectar la arquitectura
    ARCH=$(dpkg --print-architecture)
    
    # Detectar el codename correcto para el repositorio
    CODENAME=$(lsb_release -cs)
    
    # Para Ubuntu 24.04, usar el repositorio de Ubuntu 22.04 si no está disponible
    if [[ "$UBUNTU_VERSION" == "24.04" ]]; then
        # Verificar si existe repositorio específico para 24.04
        if ! curl -s "https://download.docker.com/linux/ubuntu/dists/$CODENAME/Release" > /dev/null 2>&1; then
            warning "Repositorio Docker para Ubuntu 24.04 no disponible, usando repositorio de Ubuntu 22.04"
            CODENAME="jammy"  # Ubuntu 22.04 codename
        fi
    fi
    
    # Agregar repositorio de Docker
    echo \
        "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Actualizar índice de paquetes
    sudo apt update -y
    
    # Instalar Docker Engine
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    log "✅ Docker instalado (usando repositorio: $CODENAME)"
}

# Configurar Docker
configure_docker() {
    log "Configurando Docker..."
    
    # Agregar usuario actual al grupo docker
    sudo usermod -aG docker $USER
    
    # Habilitar y iniciar Docker
    sudo systemctl enable docker
    sudo systemctl start docker
    
    log "✅ Docker configurado"
    
    # Inicializar Docker Swarm
    log "Inicializando Docker Swarm..."
    if ! docker info | grep -q "Swarm: active"; then
        # Obtener la IP principal del sistema
        HOST_IP=$(ip route get 8.8.8.8 | awk '{print $7; exit}' 2>/dev/null)
        
        if [ -z "$HOST_IP" ]; then
            warning "No se pudo detectar la IP automáticamente, usando 127.0.0.1"
            HOST_IP="127.0.0.1"
        fi
        
        log "Inicializando swarm con IP: $HOST_IP"
        if docker swarm init --advertise-addr $HOST_IP; then
            log "✅ Docker Swarm inicializado correctamente"
        else
            error "❌ Error al inicializar Docker Swarm"
            exit 1
        fi
    else
        log "ℹ️  Docker Swarm ya está activo"
    fi
    
    info "📝 Nota: Necesitarás reiniciar la sesión o hacer logout/login para que los cambios del grupo docker tengan efecto"
}

# Instalar Docker Compose (standalone)
install_docker_compose() {
    log "Instalando Docker Compose standalone..."
    
    # Obtener la última versión de Docker Compose
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    
    # Descargar Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    
    # Dar permisos de ejecución
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Crear enlace simbólico para compatibilidad
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    log "✅ Docker Compose instalado (versión: $DOCKER_COMPOSE_VERSION)"
}

# Verificar instalación
verify_installation() {
    log "Verificando instalación..."
    
    # Verificar Docker
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version)
        log "✅ Docker: $DOCKER_VERSION"
    else
        error "❌ Docker no está instalado correctamente"
        exit 1
    fi
    
    # Verificar Docker Compose
    if command -v docker-compose &> /dev/null; then
        DOCKER_COMPOSE_VERSION=$(docker-compose --version)
        log "✅ Docker Compose: $DOCKER_COMPOSE_VERSION"
    else
        error "❌ Docker Compose no está instalado correctamente"
        exit 1
    fi
    
    # Verificar que Docker está corriendo
    if sudo systemctl is-active --quiet docker; then
        log "✅ Docker daemon está corriendo"
    else
        error "❌ Docker daemon no está corriendo"
        exit 1
    fi
    
    # Verificar Docker Swarm
    if docker info | grep -q "Swarm: active"; then
        log "✅ Docker Swarm está activo"
    else
        warning "⚠️  Docker Swarm no está activo"
    fi
    
    # Verificar que el usuario está en el grupo docker
    if groups $USER | grep -q docker; then
        log "✅ Usuario $USER está en el grupo docker"
    else
        warning "⚠️  Usuario $USER no está en el grupo docker (puede requerir reiniciar sesión)"
    fi
}

# Crear directorios necesarios para el proyecto
setup_project_directories() {
    log "Configurando directorios del proyecto..."
    
    # Crear directorio de datos si no existe
    DATA_DIR="/home/$USER/data"
    if [ ! -d "$DATA_DIR" ]; then
        mkdir -p "$DATA_DIR"/{wordpress,mariadb}
        log "✅ Directorios de datos creados en $DATA_DIR"
    else
        log "ℹ️  Directorio de datos ya existe: $DATA_DIR"
    fi
    
    # Establecer permisos apropiados
    sudo chown -R $USER:$USER "$DATA_DIR"
    chmod -R 755 "$DATA_DIR"
    
    log "✅ Directorios del proyecto configurados"
}

# Configurar dominio local
configure_local_domain() {
    log "Configurando dominio local..."
    
    DOMAIN="$USER.42.fr"
    
    # Verificar si el dominio ya está configurado
    if grep -q "$DOMAIN" /etc/hosts; then
        log "ℹ️  Dominio $DOMAIN ya está configurado en /etc/hosts"
    else
        # Añadir dominio al archivo hosts
        echo "127.0.0.1 $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
        log "✅ Dominio $DOMAIN añadido a /etc/hosts"
    fi
    
    # Verificar la configuración
    if grep -q "127.0.0.1.*$DOMAIN" /etc/hosts; then
        log "✅ Dominio $DOMAIN configurado correctamente"
        info "🌐 Tu sitio estará disponible en: https://$DOMAIN"
    else
        warning "⚠️  Error al configurar el dominio $DOMAIN"
    fi
}

# Configurar sudo sin contraseña
configure_sudo_nopasswd() {
    log "Configurando sudo sin contraseña para el usuario actual..."
    
    # Crear archivo sudoers para el usuario actual
    SUDOERS_FILE="/etc/sudoers.d/$USER"
    
    # Verificar si ya existe la configuración
    if sudo test -f "$SUDOERS_FILE"; then
        log "ℹ️  Configuración sudo sin contraseña ya existe para $USER"
    else
        # Crear regla sudo sin contraseña
        echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee "$SUDOERS_FILE" > /dev/null
        
        # Establecer permisos correctos (muy importante para sudoers)
        sudo chmod 0440 "$SUDOERS_FILE"
        
        # Verificar que la sintaxis es correcta
        if sudo visudo -c -f "$SUDOERS_FILE"; then
            log "✅ Sudo sin contraseña configurado correctamente para $USER"
        else
            error "❌ Error en la configuración de sudoers"
            sudo rm -f "$SUDOERS_FILE"
            exit 1
        fi
    fi
}

# Instalar herramientas de desarrollo
install_development_tools() {
    log "Instalando herramientas de desarrollo..."
    
    # Instalar herramientas básicas de desarrollo
    sudo apt install -y \
        build-essential \
        jq \
        httpie \
        ncdu \
        btop
    
    # Instalar Visual Studio Code
    log "Instalando Visual Studio Code..."
    
    # Verificar si ya está instalado
    if command -v code &> /dev/null; then
        log "ℹ️  Visual Studio Code ya está instalado"
    else
        # Agregar la clave GPG de Microsoft
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        
        # Detectar arquitectura para VS Code
        ARCH=$(dpkg --print-architecture)
        
        # Agregar repositorio de VS Code con arquitecturas soportadas
        sudo sh -c "echo 'deb [arch=$ARCH,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main' > /etc/apt/sources.list.d/vscode.list"
        
        # Actualizar e instalar VS Code
        sudo apt update -y
        sudo apt install -y code
        
        # Limpiar archivos temporales
        rm -f packages.microsoft.gpg
        
        log "✅ Visual Studio Code instalado"
    fi
    log "✅ Herramientas de desarrollo instaladas"
}

# Instalar herramientas adicionales útiles
install_additional_tools() {
    log "Instalando herramientas adicionales..."
    
    # Instalar Oh My Bash (opcional, para mejorar la experiencia de terminal)
    read -p "¿Deseas instalar Oh My Bash para mejorar la terminal? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
        log "✅ Oh My Bash instalado"
    fi
    
    log "✅ Herramientas adicionales instaladas"
}

# Crear alias útiles
create_useful_aliases() {
    log "Creando aliases útiles..."
    
    # Crear aliases para Docker y el proyecto
    ALIASES_FILE="$HOME/.bash_aliases"
    
    cat >> "$ALIASES_FILE" << 'EOF'
# Aliases para Docker y proyecto Inception
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dlog='docker logs'
alias dstop='docker stop $(docker ps -q)'
alias dclean='docker system prune -af'

# Aliases para Visual Studio Code
alias c='code'
alias c.='code .'

# Aliases para el proyecto Inception
alias inception-up='cd ~/campus42/proyectos/inception/inceptio_apa && make up'
alias inception-down='cd ~/campus42/proyectos/inception/inceptio_apa && make down'
alias inception-logs='cd ~/campus42/proyectos/inception/inceptio_apa && make logs'
alias inception-clean='cd ~/campus42/proyectos/inception/inceptio_apa && make clean'
alias inception-status='cd ~/campus42/proyectos/inception/inceptio_apa && make ps'
alias inception-code='cd ~/campus42/proyectos/inception/inceptio_apa && code .'
EOF
    
    log "✅ Aliases creados en $ALIASES_FILE"
    info "📝 Ejecuta 'source ~/.bashrc' o reinicia la terminal para cargar los aliases"
}

# Mostrar información final
show_final_info() {
    log "🎉 ¡Instalación completada exitosamente!"
    echo
    info "═══════════════════════════════════════════════════════════════════"
    info "                    INFORMACIÓN IMPORTANTE"
    info "═══════════════════════════════════════════════════════════════════"
    echo
    info "🖥️  Sistema: Ubuntu $UBUNTU_VERSION LTS"
    info "✅ Docker y Docker Compose han sido instalados"
    info "✅ Docker Swarm inicializado"
    info "✅ Visual Studio Code instalado"
    info "✅ Usuario agregado al grupo docker"
    info "✅ Sudo sin contraseña configurado"
    info "✅ Directorios del proyecto configurados"
    info "✅ Dominio local $USER.42.fr configurado"
    info "✅ Aliases útiles creados"
    echo
    warning "⚠️  IMPORTANTE: Necesitas reiniciar tu sesión (logout/login) o ejecutar:"
    warning "   newgrp docker"
    warning "   Para que los cambios del grupo docker tengan efecto"
    echo
    info "📁 Directorio de datos del proyecto: /home/$USER/data"
    info "🌐 Tu sitio web estará disponible en: https://$USER.42.fr"
    info "🔗 Aliases disponibles después de reiniciar:"
    info "   - inception-up    : Levantar el proyecto"
    info "   - inception-down  : Parar el proyecto"
    info "   - inception-logs  : Ver logs"
    info "   - inception-clean : Limpiar proyecto"
    info "   - inception-status: Ver estado"
    echo
    info "🚀 Para probar la instalación:"
    info "   1. Reinicia tu sesión o ejecuta: newgrp docker"
    info "   2. Ejecuta: docker --version"
    info "   3. Ejecuta: docker-compose --version"
    info "   4. Ejecuta: code --version"
    info "   5. Clona tu proyecto Inception"
    info "   6. Abre VS Code: code ."
    info "   7. Ejecuta: make up"
    echo
    info "═══════════════════════════════════════════════════════════════════"
}

# Función principal
main() {
    log "🚀 Iniciando instalación de dependencias para proyecto Inception"
    echo
    
    check_ubuntu_version
    update_system
    install_basic_dependencies
    install_development_tools
    install_docker
    configure_docker
    install_docker_compose
    verify_installation
    setup_project_directories
    configure_local_domain
    configure_sudo_nopasswd
    install_additional_tools
    create_useful_aliases
    show_final_info
    
    log "✨ Script completado. ¡Disfruta tu proyecto Inception!"
}

# Ejecutar si el script se ejecuta directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

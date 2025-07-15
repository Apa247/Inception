# INSTALACIÓN DE DEPENDENCIAS - PROYECTO INCEPTION

Este directorio contiene scripts para instalar todas las dependencias necesarias para ejecutar el proyecto Inception en Ubuntu 22.04.

## 📋 Requisitos

- **Sistema Operativo**: Ubuntu 22.04 LTS (recién instalado)
- **Permisos**: Acceso sudo
- **Conexión**: Internet estable

## 🚀 Opciones de Instalación

### Opción 1: Instalación Completa (Recomendada)

```bash
# Dar permisos de ejecución
chmod +x setup_dependencies.sh

# Ejecutar el script
./setup_dependencies.sh
```

**Incluye:**
- ✅ Docker y Docker Compose
- ✅ Docker Swarm inicializado
- ✅ Dependencias básicas del sistema
- ✅ Herramientas de desarrollo
- ✅ Configuración de directorios
- ✅ Aliases útiles
- ✅ Verificación completa de instalación
- ✅ Configuración de sudo sin contraseña
- ✅ Oh My Bash (opcional)

### Opción 2: Instalación Rápida

```bash
# Dar permisos de ejecución
chmod +x quick_setup.sh

# Ejecutar el script
./quick_setup.sh
```

**Incluye:**
- ✅ Docker y Docker Compose
- ✅ Docker Swarm inicializado
- ✅ Dependencias básicas
- ✅ Configuración mínima
- ✅ Sudo sin contraseña

## 📦 Dependencias Instaladas

### Docker
- **Docker Engine** (última versión estable)
- **Docker Compose** (latest)
- **Docker Buildx Plugin**
- **Docker Swarm** (inicializado automáticamente)

### Herramientas del Sistema
- `curl`, `wget`, `git`
- `make`, `vim`
- `net-tools`, `htop`, `tree`
- `build-essential`, `jq`

### Estructura de Directorios
```
/home/usuario/data/
├── wordpress/    # Volumen para WordPress
└── mariadb/      # Volumen para MariaDB
```

## 🔧 Post-Instalación

### 1. Reiniciar Sesión
```bash
# Opción 1: Reiniciar sesión completa (recomendado)
logout

# Opción 2: Cambiar grupo temporalmente
newgrp docker
```

### 2. Verificar Instalación
```bash
# Verificar Docker
docker --version
docker-compose --version

# Probar Docker
docker run hello-world
```

### 3. Clonar y Ejecutar Proyecto
```bash
# Clonar tu proyecto (ajusta la URL)
git clone <tu-repositorio> ~/campus42/proyectos/inception/inceptio_apa

# Navegar al proyecto
cd ~/campus42/proyectos/inception/inceptio_apa

# Ejecutar el proyecto
make up
```

## 🎯 Aliases Útiles (Solo instalación completa)

Después de reiniciar la sesión:

```bash
# Aliases de Docker
d           # docker
dc          # docker-compose
dps         # docker ps
dpsa        # docker ps -a
di          # docker images
dlog        # docker logs
dstop       # docker stop $(docker ps -q)
dclean      # docker system prune -af

# Aliases del proyecto Inception
inception-up      # Levantar el proyecto
inception-down    # Parar el proyecto
inception-logs    # Ver logs
inception-clean   # Limpiar proyecto
inception-status  # Ver estado
```

## 🛠️ Solución de Problemas

### Docker no funciona después de la instalación
```bash
# Verificar que Docker está corriendo
sudo systemctl status docker

# Verificar permisos del usuario
groups $USER | grep docker

# Si no está en el grupo docker
sudo usermod -aG docker $USER
newgrp docker
```

### Error de permisos en directorios
```bash
# Corregir permisos en el directorio de datos
sudo chown -R $USER:$USER /home/$USER/data
chmod -R 755 /home/$USER/data
```

### Error de Docker Swarm al crear secrets
```bash
# Verificar estado de Docker Swarm
docker info | grep Swarm

# Si no está activo, inicializarlo manualmente
docker swarm init

# Si hay problema con múltiples IPs
docker swarm init --advertise-addr <tu-ip-principal>

# Verificar que funciona
docker node ls
```

### Configuración sudo sin contraseña no funciona
```bash
# Verificar si el archivo existe
sudo ls -la /etc/sudoers.d/$USER

# Verificar contenido
sudo cat /etc/sudoers.d/$USER

# Probar manualmente
sudo visudo -c -f /etc/sudoers.d/$USER
```

### Revertir configuración sudo sin contraseña
```bash
# Si quieres volver a pedir contraseña para sudo
sudo rm /etc/sudoers.d/$USER
```

## 🔒 Consideraciones de Seguridad

- **Sudo sin contraseña**: Útil para desarrollo, pero evalúa si es apropiado para tu entorno
- **Grupo docker**: Los usuarios del grupo docker tienen acceso root equivalente
- **Firewall**: Considera mantener ufw activo con reglas específicas
- **Actualizaciones**: Mantén el sistema y Docker actualizados regularmente

## 📝 Notas Importantes

1. **Reinicio obligatorio**: Después de la instalación, DEBES reiniciar tu sesión para que los cambios del grupo docker tengan efecto.

2. **Configuración de sudo**: Los scripts configuran tu usuario para ejecutar comandos sudo sin contraseña. Esto es útil para desarrollo pero considéralo para entornos de producción.

3. **Firewall**: Ubuntu 22.04 viene con ufw habilitado por defecto. Si tienes problemas de conectividad, verifica:
   ```bash
   sudo ufw status
   sudo ufw allow 443/tcp  # Para HTTPS
   sudo ufw allow 80/tcp   # Para HTTP (si necesario)
   ```

4. **Espacio en disco**: Asegúrate de tener al menos 10GB libres para las imágenes de Docker y el proyecto.

5. **Memoria RAM**: Se recomienda al menos 2GB de RAM para ejecutar todos los contenedores cómodamente.

## 🆘 Soporte

Si encuentras algún problema:

1. **Verifica los logs**: `journalctl -u docker`
2. **Revisa los permisos**: `ls -la /var/run/docker.sock`
3. **Comprueba la versión**: `lsb_release -a`
4. **Revisa la documentación**: [Docker Docs](https://docs.docker.com/)

---

**Creado por**: GitHub Copilot  
**Fecha**: 15 de Julio, 2025  
**Versión**: 1.0

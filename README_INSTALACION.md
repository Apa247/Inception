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
- ✅ Dependencias básicas del sistema
- ✅ Herramientas de desarrollo
- ✅ Configuración de directorios
- ✅ Aliases útiles
- ✅ Verificación completa de instalación
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
- ✅ Dependencias básicas
- ✅ Configuración mínima

## 📦 Dependencias Instaladas

### Docker
- **Docker Engine** (última versión estable)
- **Docker Compose** (latest)
- **Docker Buildx Plugin**

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

### Docker Compose no se encuentra
```bash
# Verificar instalación
which docker-compose

# Reinstalar si es necesario
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## 📝 Notas Importantes

1. **Reinicio obligatorio**: Después de la instalación, DEBES reiniciar tu sesión para que los cambios del grupo docker tengan efecto.

2. **Firewall**: Ubuntu 22.04 viene con ufw habilitado por defecto. Si tienes problemas de conectividad, verifica:
   ```bash
   sudo ufw status
   sudo ufw allow 443/tcp  # Para HTTPS
   sudo ufw allow 80/tcp   # Para HTTP (si necesario)
   ```

3. **Espacio en disco**: Asegúrate de tener al menos 10GB libres para las imágenes de Docker y el proyecto.

4. **Memoria RAM**: Se recomienda al menos 2GB de RAM para ejecutar todos los contenedores cómodamente.

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

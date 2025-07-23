# 📋 GUÍA DE EVALUACIÓN - PROYECTO INCEPTION

## 🎯 **PROYECTO OVERVIEW - PREGUNTAS CONCEPTUALES**

### 1. **¿Cómo funcionan Docker y Docker Compose?**

**RESPUESTA:**
- **Docker** es una plataforma de containerización que permite empaquetar aplicaciones con todas sus dependencias en contenedores ligeros y portables
- Los contenedores comparten el kernel del sistema operativo host, pero están aislados entre sí
- **Docker Compose** es una herramienta que permite definir y ejecutar aplicaciones multi-contenedor usando un archivo YAML
- Con Docker Compose puedes levantar múltiples servicios con un solo comando: `docker compose up`
- Gestiona automáticamente la creación de redes, volúmenes y dependencias entre contenedores

### 2. **¿Diferencia entre imagen Docker con y sin Docker Compose?**

**RESPUESTA:**
- **Sin Docker Compose**: Ejecutas contenedores individualmente con `docker run`, debes crear manualmente redes, volúmenes y gestionar dependencias
- **Con Docker Compose**: 
  - Defines toda la infraestructura en un archivo `docker-compose.yml`
  - Gestiona automáticamente la comunicación entre contenedores
  - Crea redes compartidas automáticamente
  - Permite escalar servicios fácilmente
  - Simplifica el despliegue de aplicaciones complejas

### 3. **¿Beneficios de Docker vs Máquinas Virtuales?**

**RESPUESTA:**
- **Eficiencia de recursos**: Docker comparte el kernel del host, las VMs necesitan un SO completo
- **Velocidad**: Los contenedores inician en segundos, las VMs en minutos
- **Tamaño**: Imágenes Docker son MB, VMs son GB
- **Portabilidad**: "Funciona en mi máquina" se resuelve con contenedores
- **Escalabilidad**: Más fácil escalar horizontalmente con contenedores
- **Aislamiento**: Suficiente para aplicaciones, sin overhead de virtualización completa

### 4. **¿Pertinencia de la estructura de directorios del proyecto?**

**RESPUESTA:**
```
inception/
├── Makefile                 # Automatización de tareas
├── srcs/                   # OBLIGATORIO: Todo el código fuente
│   ├── docker-compose.yml  # Definición de servicios
│   ├── .env                # Variables de entorno
│   └── requirements/       # Un directorio por servicio
│       ├── nginx/         # Servidor web con SSL
│       ├── wordpress/     # CMS con php-fpm
│       └── mariadb/       # Base de datos
└── secrets/               # Credenciales sensibles
```

**Justificación:**
- **Separación de responsabilidades**: Cada servicio tiene su directorio
- **Seguridad**: Secrets separados del código
- **Mantenibilidad**: Estructura clara y organizada
- **Compliance**: Cumple requisitos del subject (srcs/ obligatorio)

---

## 🌐 **DOCKER NETWORK**

### **Verificación y Explicación de Docker Network:**

#### **Verificar que docker-network está en uso:**
```bash
# Verificar docker-compose.yml contiene networks
grep -A 5 "networks:" /home/daparici/campus42/proyectos/inception/apa/srcs/docker-compose.yml

# Listar redes existentes
docker network ls

# Inspeccionar la red del proyecto
docker network inspect apa_inception
```

#### **¿Qué es Docker Network? - EXPLICACIÓN SENCILLA**

**RESPUESTA PREPARADA:**

**Docker Network** es el sistema que permite que los contenedores se comuniquen entre sí de forma aislada y segura:

1. **¿Qué hace?**
   - Crea una red virtual privada para tus contenedores
   - Permite que los servicios se hablen usando sus nombres (nginx puede conectar a mariadb)
   - Aísla tu aplicación del host y otros proyectos

2. **¿Cómo funciona en nuestro proyecto?**
   - Todos los contenedores (nginx, wordpress, mariadb) están en la red `inception`
   - Se comunican usando nombres de servicio: `wordpress` puede conectar a `maria_db:3306`
   - La red es tipo `bridge` (aislada pero con acceso a internet)

3. **Beneficios:**
   - **Seguridad**: Contenedores aislados del exterior
   - **Simplicidad**: No necesitas IPs, usas nombres de servicio
   - **Flexibilidad**: Puedes tener múltiples redes para diferentes propósitos

4. **En nuestro docker-compose.yml:**
   ```yaml
   networks:
     inception:        # Nombre de nuestra red
       driver: bridge  # Tipo de red (aislada con internet)
   ```

5. **Comandos útiles:**
   ```bash
   # Ver qué contenedores están en la red
   docker network inspect apa_inception
   
   # Probar conectividad entre contenedores
   docker exec -it nginx ping maria_db
   ```

**✅ RESPUESTA ESPERADA DEL EVALUADO:**
- Debe explicar que permite comunicación entre contenedores
- Debe mencionar que usan nombres de servicio en lugar de IPs
- Debe entender que proporciona aislamiento y seguridad
- Si no puede explicar esto correctamente → **FALLO DE EVALUACIÓN**

---

## 🔒 **NGINX CON SSL/TLS**

### **Verificaciones Durante la Evaluación:**

#### 1. **Verificar existencia del Dockerfile**
```bash
ls -la /home/daparici/campus42/proyectos/inception/apa/srcs/requirements/nginx/Dockerfile
```
**✅ RESPUESTA**: Dockerfile presente y configurado correctamente

#### 2. **Verificar contenedor creado**
```bash
cd /home/daparici/campus42/proyectos/inception/apa
# Opción 1: Usar Makefile (Recomendado)
make ps

# Opción 2: Docker compose desde directorio srcs
cd srcs && docker compose ps

# Opción 3: Docker compose con flag -f
docker compose -f srcs/docker-compose.yml ps
```
**✅ RESPUESTA**: Debe mostrar contenedor `nginx` en estado `running`

#### 3. **Verificar que NO funciona HTTP (puerto 80)**
```bash
curl -I http://daparici.42.fr
# o
curl -I http://localhost:80
```
**✅ RESPUESTA**: Debe fallar la conexión - "Connection refused" o similar

#### 4. **Verificar HTTPS funciona (puerto 443)**
```bash
# En navegador abrir:
https://daparici.42.fr
```
**✅ RESPUESTA**: 
- Debe mostrar sitio WordPress configurado (NO página de instalación)
- Puede aparecer advertencia de certificado autofirmado (NORMAL)
- Verificar en DevTools que usa TLS 1.2 o 1.3

#### 5. **Demostrar certificado TLS v1.2/v1.3**
```bash
# Verificar protocolo TLS:
openssl s_client -connect daparici.42.fr:443 -tls1_2
# o
openssl s_client -connect localhost:443 -tls1_3
```
**✅ RESPUESTA**: Debe conectar exitosamente y mostrar certificado

**Configuración NGINX (para explicar):**
```nginx
listen 443 ssl default_server;
ssl_certificate /etc/ssl/certs/cert.pem;
ssl_certificate_key /etc/ssl/certs/cert-key.pem;
ssl_protocols TLSv1.2 TLSv1.3;  # ✅ REQUISITO CUMPLIDO
```

---

## 🗄️ **MARIADB Y SU VOLUMEN**

### **Cómo hacer login en la base de datos:**

#### **Método 1: Desde el contenedor MariaDB**
```bash
# Acceder al contenedor
docker exec -it mariadb bash

# Login como root
mysql -u root -p
# Password: (contenido de /run/secrets/DB_ROOT_PWD)

# O login como usuario de aplicación
mysql -u wordpress_user -p wordpress_db
# Password: (contenido de /run/secrets/DB_USER_PWD)
```

#### **Método 2: Desde host (si puerto expuesto)**
```bash
# Login directo desde host
mysql -h localhost -P 3306 -u wordpress_user -p wordpress_db
```

#### **Método 3: Usando Docker directamente**
```bash
# Ejecutar comando mysql directamente
docker exec -it mariadb mysql -u root -p wordpress_db
```

### **Verificar que la base de datos NO está vacía:**

#### **Comandos SQL para verificar:**
```sql
-- Ver todas las bases de datos
SHOW DATABASES;

-- Usar la base de datos de WordPress
USE wordpress_db;

-- Ver todas las tablas (debe mostrar tablas de WordPress)
SHOW TABLES;

-- Verificar datos en tabla de usuarios
SELECT user_login, user_email FROM wp_users;

-- Verificar posts
SELECT post_title, post_status FROM wp_posts WHERE post_status = 'publish';

-- Verificar configuración
SELECT option_name, option_value FROM wp_options WHERE option_name IN ('siteurl', 'home');
```

**✅ RESPUESTA ESPERADA:**
- Base de datos `wordpress_db` debe existir
- Tablas de WordPress deben estar presentes (wp_users, wp_posts, wp_options, etc.)
- Debe haber al menos 2 usuarios: admin (ridick) y usuario normal
- Debe haber contenido/posts configurados
- URLs deben apuntar a https://daparici.42.fr

### **Verificar Volumen Persistente:**

#### **Comando para verificar volumen:**
```bash
# Listar volúmenes
docker volume ls

# Inspeccionar volumen de MariaDB
docker volume inspect apa_Mariadb_volumen

# Verificar que apunta a /home/daparici/data/
```

**✅ RESPUESTA ESPERADA:**
```json
{
    "Mountpoint": "/var/lib/docker/volumes/apa_Mariadb_volumen/_data",
    "Options": {
        "device": "/home/daparici/data/mariadb",
        "o": "bind",
        "type": "none"
    }
}
```

#### **Verificar archivos físicos:**
```bash
# Ver archivos de la base de datos
ls -la /home/daparici/data/mariadb/
```
**✅ RESPUESTA**: Debe mostrar archivos `.frm`, `.ibd`, etc. de MariaDB

---

## 🔧 **COMANDOS ÚTILES PARA LA EVALUACIÓN**

### **Inicialización del proyecto:**
```bash
cd /home/daparici/campus42/proyectos/inception/apa
make up
```

### **Verificación de estado:**
```bash
# Ver contenedores activos (desde directorio raíz)
cd /home/daparici/campus42/proyectos/inception/apa
make ps

# O desde directorio srcs
cd /home/daparici/campus42/proyectos/inception/apa/srcs
docker compose ps

# Ver logs
cd /home/daparici/campus42/proyectos/inception/apa
make logs

# Ver procesos en contenedores
docker stats
```

### **Limpieza (si necesario):**
```bash
make down
make clean
```

### **Comandos de debugging:**
```bash
# Entrar a contenedores para debug
docker exec -it nginx bash
docker exec -it mariadb bash
docker exec -it wp-php bash

# Ver logs específicos
docker logs nginx
docker logs mariadb
docker logs wp-php
```

---

## ✅ **CHECKLIST PARA EVALUADOR**

### **Preliminares:**
- [ ] Carpeta `srcs/` en la raíz
- [ ] `Makefile` en la raíz
- [ ] Sin secrets hardcodeados en el código
- [ ] Archivo `.env` presente pero mínimo

### **Docker Compose:**
- [ ] Sin `network: host`
- [ ] Sin `links:`
- [ ] Networks configuradas
- [ ] Sin `--link` en scripts

### **Dockerfiles:**
- [ ] Un Dockerfile por servicio
- [ ] Base Debian/Alpine correcta
- [ ] Sin `tail -f` o comandos background
- [ ] Imágenes propias (no DockerHub)

### **NGINX:**
- [ ] Solo puerto 443 (no 80)
- [ ] Certificado SSL/TLS v1.2/v1.3
- [ ] WordPress accesible vía HTTPS

### **WordPress:**
- [ ] Sin NGINX en el Dockerfile
- [ ] Usuario admin sin "admin" en el nombre
- [ ] Volumen persistente configurado
- [ ] Comentarios funcionales

### **MariaDB:**
- [ ] Sin NGINX en el Dockerfile
- [ ] Login funcional
- [ ] Base de datos con contenido
- [ ] Volumen persistente

### **Persistencia:**
- [ ] Reinicio mantiene datos
- [ ] Volúmenes apuntan a `/home/login/data/`

---

## 🎯 **PUNTOS CRÍTICOS QUE FALLAN LA EVALUACIÓN**

❌ **FALLO INMEDIATO SI:**
- Secrets hardcodeados en el repositorio
- `network: host` o `links:` en docker-compose
- `--link` en scripts
- `tail -f`, loops infinitos o comandos background
- Imágenes de DockerHub en lugar de propias
- Base que no sea Alpine/Debian
- WordPress muestra página de instalación
- No se puede acceder vía HTTPS
- Usuario admin contiene "admin"
- Base de datos vacía
- Sin persistencia después de reinicio

---

**¡PROYECTO LISTO PARA EVALUACIÓN!** 🚀

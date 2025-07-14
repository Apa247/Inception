# DOCUMENTACIÓN - SOLUCIÓN AL PROBLEMA DE ACCESS DENIED EN MARIADB

## PROBLEMA IDENTIFICADO
El proyecto Inception mostraba constantemente errores de "Access denied for user 'root'@'localhost' (using password: NO)" cada 5 segundos en los logs de MariaDB.

## CAUSA RAÍZ
El healthcheck en docker-compose.yml estaba configurado así:
```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-u", "root", "-p$DB_ROOT_PWD"]
```

**El problema era que:**
- `$DB_ROOT_PWD` no estaba definida como variable de entorno en el contenedor
- Docker Compose no podía expandir esta variable correctamente en el contexto del healthcheck
- Esto resultaba en intentos de conexión sin contraseña (`using password: NO`)
- El healthcheck fallaba constantemente, generando errores cada 5 segundos

## SOLUCIÓN IMPLEMENTADA

### 1. Creación del script de healthcheck personalizado
**Archivo:** `src/requirements/mariadb/tools/healthcheck.sh`
- Lee la contraseña directamente del archivo de secreto `/run/secrets/DB_ROOT_PWD`
- Usa `mysqladmin ping` con la contraseña correcta
- Es más robusto que intentar expandir variables en el healthcheck

### 2. Modificación del Dockerfile
**Archivo:** `src/requirements/mariadb/Dockerfile`
- Copia el script `healthcheck.sh` al contenedor
- Le da permisos de ejecución

### 3. Actualización del docker-compose.yml
**Archivo:** `src/docker-compose.yml`
- Cambió el healthcheck para usar el script personalizado: `["CMD", "./healthcheck.sh"]`
- Eliminó la dependencia de variables de entorno no definidas

## ARCHIVOS MODIFICADOS
1. `src/requirements/mariadb/tools/healthcheck.sh` - NUEVO
2. `src/requirements/mariadb/Dockerfile` - MODIFICADO
3. `src/docker-compose.yml` - MODIFICADO

## RESULTADO
- ✅ Eliminación completa de los errores "Access denied"
- ✅ Healthcheck funciona correctamente
- ✅ MariaDB se muestra como "Healthy"
- ✅ Logs limpios sin errores constantes
- ✅ Mantiene la seguridad usando Docker secrets

## ANTES Y DESPUÉS

### ANTES:
```
mariadb  | 2025-07-14 18:20:07 12 [Warning] Access denied for user 'root'@'localhost' (using password: NO)
mariadb  | 2025-07-14 18:20:12 13 [Warning] Access denied for user 'root'@'localhost' (using password: NO)
mariadb  | 2025-07-14 18:20:17 19 [Warning] Access denied for user 'root'@'localhost' (using password: NO)
```

### DESPUÉS:
```
mariadb  | 2025-07-14 18:24:53 0 [Note] /usr/sbin/mariadbd: ready for connections.
mariadb  | Version: '10.5.29-MariaDB-0+deb11u1'  socket: '/run/mysqld/mysqld.sock'  port: 3306  Debian 11
mariadb  | mysqld is alive
mariadb  | MariaDB initialization complete.
```

## LECCIONES APRENDIDAS
1. **Docker Secrets vs Variables de Entorno**: Los secrets de Docker Compose son archivos, no variables de entorno
2. **Healthcheck Complexity**: Los healthchecks complejos es mejor manejarlos con scripts personalizados
3. **Debugging**: Los logs constantes pueden indicar problemas de configuración, no solo de la aplicación
4. **File-based Secrets**: Para proyectos locales, los file-based secrets son más simples que Docker Swarm secrets

## COMANDOS ÚTILES PARA VERIFICAR
```bash
# Ver logs sin errores
make logs

# Verificar estado de los contenedores
make ps

# Verificar que MariaDB esté "Healthy"
docker compose -f ./src/docker-compose.yml ps
```


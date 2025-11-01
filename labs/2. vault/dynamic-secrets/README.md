# Lab Vault: Secretos Dinámicos

![Vault](https://img.shields.io/badge/Vault-Practitioner-FFD814?style=flat&logo=vault)

## 🎯 Objetivo
Configurar Vault para generar credenciales dinámicas de base de datos, aprendiendo los fundamentos de gestión de secretos.

## ⏱️ Duración
10-15 minutos

## 📋 Prerrequisitos
- Docker instalado y ejecutándose
- Vault CLI instalado
- Puerto 8200 y 5432 disponibles

## 🚀 Instrucciones Paso a Paso

### Paso 1: Iniciar el entorno
```bash
# Iniciar Vault en modo dev y PostgreSQL
./start-vault.sh

# Verificar que Vault está ejecutándose
curl -s http://localhost:8200/v1/sys/health | jq .
```

### Paso 2: Configurar el motor de base de datos
```bash
# Configurar Vault para generar credenciales dinámicas
./configure-db-engine.sh

# Verificar que el motor está habilitado
vault secrets list | grep database
```

### Paso 3: Generar credenciales dinámicas
```bash
# Generar nuevas credenciales
./generate-credentials.sh

# Las credenciales se guardan en archivos locales
cat db_username.txt
cat db_password.txt
```

### Paso 4: Verificar las credenciales
```bash
# Probar conexión con las credenciales generadas
./verify-credentials.sh

# Verificar que las credenciales funcionan
echo "SELECT current_user, now();" | docker exec -i postgres-lab psql -U $(cat db_username.txt) -d mydb
```

### Paso 5: Ejecutar validación del laboratorio
```bash
# Ejecutar script de validación
./validate-lab.sh
```

### Paso 6: Limpiar el entorno
```bash
# Limpiar todos los recursos
./cleanup.sh
```

## ✅ Criterios de Validación
Para obtener el badge, el laboratorio debe cumplir:

1. **Vault operativo**: Vault responde en puerto 8200
2. **Motor de DB habilitado**: `database/` aparece en secrets list
3. **Rol configurado**: Rol `my-role` existe y está configurado
4. **Credenciales generadas**: Se pueden generar credenciales dinámicas
5. **Conexión exitosa**: Las credenciales permiten conectar a PostgreSQL

## 🏆 Badge: Vault Practitioner
Al completar exitosamente este laboratorio, obtienes el badge **Vault Practitioner** que certifica que puedes:
- Configurar y operar Vault
- Habilitar y configurar motores de secretos
- Generar credenciales dinámicas
- Gestionar el ciclo de vida de secretos

## 🔧 Troubleshooting
- **Puerto ocupado**: Cambiar puertos en scripts o detener servicios
- **Docker no responde**: Verificar que Docker está ejecutándose
- **Credenciales fallan**: Verificar configuración de PostgreSQL
- **Vault no inicia**: Verificar logs con `docker logs postgres-lab`

## 📚 Conceptos Aprendidos
- **Secretos dinámicos**: Credenciales generadas bajo demanda
- **TTL (Time To Live)**: Tiempo de vida de las credenciales
- **Motores de secretos**: Plugins para diferentes tipos de secretos
- **Roles**: Plantillas para generar credenciales con permisos específicos

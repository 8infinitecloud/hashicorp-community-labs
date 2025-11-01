#!/bin/bash

echo "🧹 Limpiando entorno..."

# Detener Vault si está ejecutándose
if [ -f vault.pid ]; then
    VAULT_PID=$(cat vault.pid)
    kill $VAULT_PID 2>/dev/null
    rm vault.pid
    echo "✅ Vault detenido"
fi

# Detener y remover contenedor PostgreSQL
docker stop postgres-lab 2>/dev/null
docker rm postgres-lab 2>/dev/null
echo "✅ PostgreSQL detenido y removido"

# Limpiar archivos temporales
rm -f db_username.txt db_password.txt
echo "✅ Archivos temporales eliminados"

echo "🎉 Limpieza completada"

#!/bin/bash

echo "🚀 Iniciando Vault en modo desarrollo..."

# Iniciar PostgreSQL en Docker
docker run --name postgres-lab -e POSTGRES_PASSWORD=mypassword -e POSTGRES_DB=mydb -p 5432:5432 -d postgres:13

# Esperar a que PostgreSQL esté listo
sleep 10

# Iniciar Vault en modo dev
vault server -dev -dev-root-token-id=myroot &
VAULT_PID=$!

# Configurar variables de entorno
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='myroot'

echo "✅ Vault iniciado en http://127.0.0.1:8200"
echo "🔑 Token: myroot"
echo "📝 PID del proceso Vault: $VAULT_PID"

# Guardar PID para cleanup
echo $VAULT_PID > vault.pid

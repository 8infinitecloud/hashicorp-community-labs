#!/bin/bash

export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='myroot'

echo "🔑 Generando credenciales dinámicas..."

# Generar credenciales
CREDS=$(vault read database/creds/my-role -format=json)

# Extraer username y password
USERNAME=$(echo $CREDS | jq -r '.data.username')
PASSWORD=$(echo $CREDS | jq -r '.data.password')

echo "✅ Credenciales generadas:"
echo "   Usuario: $USERNAME"
echo "   Password: $PASSWORD"

# Guardar credenciales para verificación
echo $USERNAME > db_username.txt
echo $PASSWORD > db_password.txt

echo "📝 Credenciales guardadas en archivos locales"

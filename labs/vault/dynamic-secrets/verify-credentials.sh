#!/bin/bash

echo "🔍 Verificando credenciales dinámicas..."

# Leer credenciales guardadas
USERNAME=$(cat db_username.txt)
PASSWORD=$(cat db_password.txt)

# Probar conexión a PostgreSQL
PGPASSWORD=$PASSWORD psql -h localhost -U $USERNAME -d mydb -c "SELECT current_user, now();"

if [ $? -eq 0 ]; then
    echo "✅ Credenciales válidas - Conexión exitosa"
else
    echo "❌ Error en la conexión con las credenciales"
    exit 1
fi

#!/bin/bash

echo "📁 Creando repositorio de prueba con secretos..."

# Crear directorio del repositorio de prueba
mkdir -p test-repo
cd test-repo

# Inicializar git
git init

# Crear archivo con secretos (simulados)
cat > config.env << EOF
# Configuración de la aplicación
APP_NAME=my-app
DEBUG=true

# ⚠️ SECRETOS EXPUESTOS (SOLO PARA PRUEBA)
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
DATABASE_URL=postgresql://user:password123@localhost:5432/mydb
API_KEY=sk-1234567890abcdef1234567890abcdef
STRIPE_SECRET_KEY=sk_test_1234567890abcdef1234567890abcdef

# Configuración adicional
PORT=3000
NODE_ENV=development
EOF

# Crear archivo Python con secretos
cat > app.py << EOF
import os
import requests

# ⚠️ SECRETOS HARDCODEADOS (SOLO PARA PRUEBA)
API_KEY = "sk-1234567890abcdef1234567890abcdef"
DATABASE_PASSWORD = "super_secret_password_123"

def connect_to_api():
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "X-API-Key": "pk_test_abcdef123456789"
    }
    return requests.get("https://api.example.com", headers=headers)

# Más código...
EOF

# Crear archivo de configuración con tokens
cat > .env << EOF
GITHUB_TOKEN=ghp_1234567890abcdef1234567890abcdef123456
SLACK_WEBHOOK=https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
JWT_SECRET=my-super-secret-jwt-key-that-should-not-be-here
EOF

# Commit inicial
git add .
git commit -m "Initial commit with configuration"

cd ..

echo "✅ Repositorio de prueba creado en ./test-repo"
echo "🔍 Contiene varios tipos de secretos para detectar"

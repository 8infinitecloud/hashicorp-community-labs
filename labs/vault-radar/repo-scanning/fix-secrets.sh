#!/bin/bash

echo "🔧 Limpiando secretos del repositorio de prueba..."

cd test-repo

# Crear versiones limpias de los archivos
cat > config.env << EOF
# Configuración de la aplicación
APP_NAME=my-app
DEBUG=true

# Configuración usando variables de entorno
AWS_ACCESS_KEY_ID=\${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=\${AWS_SECRET_ACCESS_KEY}
DATABASE_URL=\${DATABASE_URL}
API_KEY=\${API_KEY}
STRIPE_SECRET_KEY=\${STRIPE_SECRET_KEY}

# Configuración adicional
PORT=3000
NODE_ENV=development
EOF

cat > app.py << EOF
import os
import requests

# Usar variables de entorno para secretos
API_KEY = os.getenv("API_KEY")
DATABASE_PASSWORD = os.getenv("DATABASE_PASSWORD")

def connect_to_api():
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "X-API-Key": os.getenv("X_API_KEY")
    }
    return requests.get("https://api.example.com", headers=headers)

# Más código...
EOF

# Crear .env.example en lugar de .env con secretos reales
cat > .env.example << EOF
# Copia este archivo a .env y completa con valores reales
GITHUB_TOKEN=your_github_token_here
SLACK_WEBHOOK=your_slack_webhook_url_here
JWT_SECRET=your_jwt_secret_here
EOF

# Remover .env original
rm -f .env

# Crear .gitignore para prevenir futuros commits de secretos
cat > .gitignore << EOF
# Variables de entorno con secretos
.env

# Archivos de configuración local
config.local.*
*.key
*.pem

# Logs
*.log
EOF

# Commit de la limpieza
git add .
git commit -m "Fix: Remove hardcoded secrets and use environment variables"

cd ..

echo "✅ Secretos limpiados del repositorio"
echo "📝 Se crearon archivos .env.example y .gitignore"

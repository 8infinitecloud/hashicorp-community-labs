#!/bin/bash

echo "🚀 Iniciando Nomad en modo desarrollo..."

# Verificar si Nomad está instalado
if ! command -v nomad &> /dev/null; then
    echo "❌ Nomad no está instalado"
    echo "📥 Descarga desde: https://www.nomadproject.io/downloads"
    exit 1
fi

# Iniciar Nomad en modo dev
nomad agent -dev -bind 0.0.0.0 -log-level INFO &
NOMAD_PID=$!

# Esperar a que Nomad esté listo
sleep 5

# Configurar variables de entorno
export NOMAD_ADDR=http://localhost:4646

echo "✅ Nomad iniciado en http://localhost:4646"
echo "📝 PID del proceso Nomad: $NOMAD_PID"

# Guardar PID para cleanup
echo $NOMAD_PID > nomad.pid

# Verificar estado
nomad node status

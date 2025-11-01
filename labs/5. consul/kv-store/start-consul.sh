#!/bin/bash

echo "🚀 Iniciando Consul en modo desarrollo..."

# Verificar si Consul está instalado
if ! command -v consul &> /dev/null; then
    echo "❌ Consul no está instalado"
    echo "📥 Descarga desde: https://www.consul.io/downloads"
    exit 1
fi

# Iniciar Consul en modo dev
consul agent -dev -ui -client=0.0.0.0 &
CONSUL_PID=$!

# Esperar a que Consul esté listo
sleep 5

echo "✅ Consul iniciado"
echo "🌐 UI disponible en: http://localhost:8500"
echo "📝 PID del proceso Consul: $CONSUL_PID"

# Guardar PID para cleanup
echo $CONSUL_PID > consul.pid

# Verificar estado
consul members

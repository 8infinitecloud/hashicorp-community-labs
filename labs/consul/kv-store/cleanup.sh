#!/bin/bash

echo "🧹 Limpiando entorno Consul..."

# Limpiar datos del KV Store
echo "🗑️  Limpiando datos del KV Store..."
consul kv delete -recurse app/ 2>/dev/null
consul kv delete -recurse services/ 2>/dev/null

# Detener Consul si está ejecutándose
if [ -f consul.pid ]; then
    CONSUL_PID=$(cat consul.pid)
    echo "🛑 Deteniendo Consul (PID: $CONSUL_PID)..."
    kill $CONSUL_PID 2>/dev/null
    rm consul.pid
    echo "✅ Consul detenido"
fi

# Limpiar archivos temporales
rm -f app-config.conf
echo "✅ Archivos temporales eliminados"

# Limpiar directorio de datos de Consul (si existe)
rm -rf consul-data 2>/dev/null

echo "🎉 Limpieza de Consul completada"

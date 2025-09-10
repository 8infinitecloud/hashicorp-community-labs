#!/bin/bash

export NOMAD_ADDR=http://localhost:4646

echo "🧹 Limpiando entorno Nomad..."

# Detener el job si está ejecutándose
echo "🛑 Deteniendo job webapp..."
nomad job stop webapp 2>/dev/null

# Purgar el job del sistema
echo "🗑️  Purgando job webapp..."
nomad job purge webapp 2>/dev/null

# Detener Nomad si está ejecutándose
if [ -f nomad.pid ]; then
    NOMAD_PID=$(cat nomad.pid)
    echo "🛑 Deteniendo Nomad (PID: $NOMAD_PID)..."
    kill $NOMAD_PID 2>/dev/null
    rm nomad.pid
    echo "✅ Nomad detenido"
fi

# Limpiar archivos temporales
rm -f webapp-scaled.nomad
echo "✅ Archivos temporales eliminados"

# Limpiar contenedores Docker si quedaron huérfanos
echo "🐳 Limpiando contenedores Docker huérfanos..."
docker container prune -f 2>/dev/null

echo "🎉 Limpieza de Nomad completada"

#!/bin/bash

export NOMAD_ADDR=http://localhost:4646

echo "🚀 Desplegando aplicación web con Nomad..."

# Validar job definition
echo "🔍 Validando job definition..."
nomad job validate webapp.nomad

if [ $? -ne 0 ]; then
    echo "❌ Error en la validación del job"
    exit 1
fi

# Planificar el job
echo "📋 Planificando deployment..."
nomad job plan webapp.nomad

# Ejecutar el job
echo "▶️  Ejecutando job..."
nomad job run webapp.nomad

# Esperar a que el job esté ejecutándose
echo "⏳ Esperando a que la aplicación esté lista..."
sleep 10

# Verificar estado del job
nomad job status webapp

echo "✅ Aplicación desplegada"
echo "🌐 Accede a: http://localhost:8080"

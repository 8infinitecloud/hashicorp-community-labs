#!/bin/bash

export NOMAD_ADDR=http://localhost:4646

echo "🔍 Verificando deployment..."

# Verificar estado del job
echo "📊 Estado del job:"
nomad job status webapp

echo ""
echo "🏥 Estado de salud del servicio:"
nomad service info webapp

echo ""
echo "🌐 Probando conectividad HTTP..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Aplicación respondiendo correctamente (HTTP $HTTP_STATUS)"
    echo "🎉 Deployment exitoso!"
else
    echo "❌ Aplicación no responde (HTTP $HTTP_STATUS)"
    echo "🔧 Revisando logs..."
    nomad alloc logs -job webapp
fi

echo ""
echo "📋 Información de allocations:"
nomad job allocs webapp

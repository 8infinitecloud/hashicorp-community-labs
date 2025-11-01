#!/bin/bash

echo "🔍 Validando Laboratorio Nomad..."
echo "================================="

VALIDATION_PASSED=true
SCORE=0
MAX_SCORE=5

export NOMAD_ADDR=http://localhost:4646

# Test 1: Verificar que Nomad está ejecutándose
echo "📋 Test 1: Verificando que Nomad está activo..."
if curl -s http://localhost:4646/v1/status/leader > /dev/null 2>&1; then
    echo "✅ Nomad está ejecutándose en puerto 4646"
    ((SCORE++))
else
    echo "❌ Nomad no está ejecutándose. Ejecuta: ./start-nomad.sh"
    VALIDATION_PASSED=false
fi

# Test 2: Verificar que el job está definido correctamente
echo "📋 Test 2: Verificando definición del job..."
if [ -f "webapp.nomad" ] && nomad job validate webapp.nomad > /dev/null 2>&1; then
    echo "✅ Job definition válida"
    ((SCORE++))
else
    echo "❌ Job definition inválida o faltante"
    VALIDATION_PASSED=false
fi

# Test 3: Verificar que el job está ejecutándose
echo "📋 Test 3: Verificando job desplegado..."
JOB_STATUS=$(nomad job status webapp -short 2>/dev/null | grep "Status" | awk '{print $3}')
if [ "$JOB_STATUS" = "running" ]; then
    echo "✅ Job 'webapp' está ejecutándose"
    ((SCORE++))
else
    echo "❌ Job no está ejecutándose (Status: $JOB_STATUS). Ejecuta: ./deploy-webapp.sh"
    VALIDATION_PASSED=false
fi

# Test 4: Verificar que la aplicación responde
echo "📋 Test 4: Verificando conectividad HTTP..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null)
if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Aplicación responde correctamente (HTTP $HTTP_STATUS)"
    ((SCORE++))
else
    echo "❌ Aplicación no responde (HTTP $HTTP_STATUS)"
    VALIDATION_PASSED=false
fi

# Test 5: Verificar allocations saludables
echo "📋 Test 5: Verificando estado de allocations..."
HEALTHY_ALLOCS=$(nomad job allocs webapp -json 2>/dev/null | jq -r '.[] | select(.ClientStatus=="running") | .ID' | wc -l)
if [ "$HEALTHY_ALLOCS" -gt 0 ]; then
    echo "✅ $HEALTHY_ALLOCS allocation(s) ejecutándose correctamente"
    ((SCORE++))
else
    echo "❌ No hay allocations saludables"
    VALIDATION_PASSED=false
fi

# Test bonus: Verificar escalado (si existe webapp-scaled.nomad)
if [ -f "webapp-scaled.nomad" ]; then
    echo "📋 Test Bonus: Verificando capacidad de escalado..."
    SCALED_COUNT=$(nomad job status webapp -json 2>/dev/null | jq -r '.JobSummary.Summary.web.Running // 0')
    if [ "$SCALED_COUNT" -gt 1 ]; then
        echo "✅ Bonus: Aplicación escalada a $SCALED_COUNT instancias"
    fi
fi

# Mostrar resultado final
echo ""
echo "📊 RESULTADO DE LA VALIDACIÓN"
echo "=============================="
echo "Puntuación: $SCORE/$MAX_SCORE"

if [ "$VALIDATION_PASSED" = true ] && [ $SCORE -eq $MAX_SCORE ]; then
    echo "🎉 ¡LABORATORIO COMPLETADO EXITOSAMENTE!"
    echo "🏆 Badge obtenido: Nomad Practitioner"
    echo ""
    echo "Has demostrado que puedes:"
    echo "✅ Configurar y operar Nomad"
    echo "✅ Escribir job definitions"
    echo "✅ Desplegar aplicaciones containerizadas"
    echo "✅ Verificar estado y salud de aplicaciones"
    echo ""
    echo "🌐 Tu aplicación está disponible en: http://localhost:8080"
    echo "🎯 Próximo paso: Continúa con el laboratorio de Consul"
    
    # Crear archivo de badge con timestamp
    echo "$(date +%Y%m%d-%H%M%S)" > .badge-nomad-earned
    echo "🏆 Badge Nomad Practitioner generado automáticamente!"
    exit 0
else
    echo "❌ LABORATORIO INCOMPLETO"
    echo "Por favor, completa todos los pasos antes de continuar."
    echo ""
    echo "💡 Consejos:"
    echo "- Verifica que Docker está ejecutándose: docker ps"
    echo "- Verifica el estado del job: nomad job status webapp"
    echo "- Revisa los logs: nomad alloc logs -job webapp"
    exit 1
fi

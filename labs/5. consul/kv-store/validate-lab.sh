#!/bin/bash

echo "🔍 Validando Laboratorio Consul..."
echo "=================================="

VALIDATION_PASSED=true
SCORE=0
MAX_SCORE=5

# Test 1: Verificar que Consul está ejecutándose
echo "📋 Test 1: Verificando que Consul está activo..."
if curl -s http://localhost:8500/v1/status/leader > /dev/null 2>&1; then
    echo "✅ Consul está ejecutándose en puerto 8500"
    ((SCORE++))
else
    echo "❌ Consul no está ejecutándose. Ejecuta: ./start-consul.sh"
    VALIDATION_PASSED=false
fi

# Test 2: Verificar que los datos están en el KV Store
echo "📋 Test 2: Verificando datos en KV Store..."
EXPECTED_KEYS=(
    "app/config/database/host"
    "app/config/api/version"
    "app/features/new_ui"
    "app/env/name"
    "services/redis/host"
)

KEYS_FOUND=0
for key in "${EXPECTED_KEYS[@]}"; do
    if consul kv get "$key" > /dev/null 2>&1; then
        ((KEYS_FOUND++))
    fi
done

if [ $KEYS_FOUND -eq ${#EXPECTED_KEYS[@]} ]; then
    echo "✅ Todos los datos están configurados en KV Store ($KEYS_FOUND/${#EXPECTED_KEYS[@]})"
    ((SCORE++))
else
    echo "❌ Faltan datos en KV Store ($KEYS_FOUND/${#EXPECTED_KEYS[@]}). Ejecuta: ./setup-kv-data.sh"
    VALIDATION_PASSED=false
fi

# Test 3: Verificar lectura de configuración
echo "📋 Test 3: Verificando lectura de configuración..."
DB_HOST=$(consul kv get app/config/database/host 2>/dev/null)
API_VERSION=$(consul kv get app/config/api/version 2>/dev/null)

if [ "$DB_HOST" = "localhost" ] && [ "$API_VERSION" = "v1" ]; then
    echo "✅ Configuración se lee correctamente"
    echo "   🗄️  DB Host: $DB_HOST"
    echo "   🔌 API Version: $API_VERSION"
    ((SCORE++))
else
    echo "❌ Error al leer configuración"
    VALIDATION_PASSED=false
fi

# Test 4: Verificar generación de archivo de configuración
echo "📋 Test 4: Verificando generación de configuración..."
if [ -f "app-config.conf" ]; then
    # Verificar que el archivo contiene datos del KV Store
    if grep -q "localhost" app-config.conf && grep -q "v1" app-config.conf; then
        echo "✅ Archivo de configuración generado correctamente"
        ((SCORE++))
    else
        echo "❌ Archivo de configuración no contiene datos correctos"
        VALIDATION_PASSED=false
    fi
else
    echo "❌ Archivo de configuración no encontrado. Ejecuta: ./generate-config.sh"
    VALIDATION_PASSED=false
fi

# Test 5: Verificar UI de Consul accesible
echo "📋 Test 5: Verificando UI de Consul..."
UI_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8500/ui/ 2>/dev/null)
if [ "$UI_STATUS" = "200" ]; then
    echo "✅ UI de Consul accesible (HTTP $UI_STATUS)"
    ((SCORE++))
else
    echo "❌ UI de Consul no accesible (HTTP $UI_STATUS)"
    VALIDATION_PASSED=false
fi

# Test bonus: Verificar estructura jerárquica de datos
echo "📋 Test Bonus: Verificando estructura de datos..."
APP_KEYS=$(consul kv get -keys -separator="/" app/ 2>/dev/null | wc -l)
if [ "$APP_KEYS" -gt 5 ]; then
    echo "✅ Bonus: Estructura jerárquica bien organizada ($APP_KEYS claves)"
fi

# Mostrar resultado final
echo ""
echo "📊 RESULTADO DE LA VALIDACIÓN"
echo "=============================="
echo "Puntuación: $SCORE/$MAX_SCORE"

if [ "$VALIDATION_PASSED" = true ] && [ $SCORE -eq $MAX_SCORE ]; then
    echo "🎉 ¡LABORATORIO COMPLETADO EXITOSAMENTE!"
    echo "🏆 Badge obtenido: Consul Practitioner"
    echo ""
    echo "Has demostrado que puedes:"
    echo "✅ Configurar y operar Consul"
    echo "✅ Usar el KV Store para configuración"
    echo "✅ Organizar datos jerárquicamente"
    echo "✅ Generar configuración desde templates"
    echo ""
    echo "🌐 UI de Consul disponible en: http://localhost:8500/ui"
    echo "🎯 Próximo paso: Continúa con el laboratorio de Vault Radar"
    
    # Crear archivo de badge con timestamp
    echo "$(date +%Y%m%d-%H%M%S)" > .badge-consul-earned
    echo "🏆 Badge Consul Practitioner generado automáticamente!"
    exit 0
else
    echo "❌ LABORATORIO INCOMPLETO"
    echo "Por favor, completa todos los pasos antes de continuar."
    echo ""
    echo "💡 Consejos:"
    echo "- Verifica que Consul responde: curl http://localhost:8500/v1/status/leader"
    echo "- Lista las claves: consul kv get -keys -separator=/ app/"
    echo "- Revisa la UI: http://localhost:8500/ui"
    exit 1
fi

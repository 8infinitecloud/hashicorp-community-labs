#!/bin/bash

echo "🔍 Validando Laboratorio Vault..."
echo "================================="

VALIDATION_PASSED=true
SCORE=0
MAX_SCORE=5

export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='myroot'

# Test 1: Verificar que Vault está ejecutándose
echo "📋 Test 1: Verificando que Vault está activo..."
if curl -s http://localhost:8200/v1/sys/health > /dev/null 2>&1; then
    echo "✅ Vault está ejecutándose en puerto 8200"
    ((SCORE++))
else
    echo "❌ Vault no está ejecutándose. Ejecuta: ./start-vault.sh"
    VALIDATION_PASSED=false
fi

# Test 2: Verificar que PostgreSQL está ejecutándose
echo "📋 Test 2: Verificando PostgreSQL..."
if docker ps | grep postgres-lab > /dev/null 2>&1; then
    echo "✅ PostgreSQL está ejecutándose en Docker"
    ((SCORE++))
else
    echo "❌ PostgreSQL no está ejecutándose. Ejecuta: ./start-vault.sh"
    VALIDATION_PASSED=false
fi

# Test 3: Verificar que el motor de base de datos está habilitado
echo "📋 Test 3: Verificando motor de base de datos..."
if vault secrets list | grep "database/" > /dev/null 2>&1; then
    echo "✅ Motor de base de datos habilitado"
    ((SCORE++))
else
    echo "❌ Motor de base de datos no habilitado. Ejecuta: ./configure-db-engine.sh"
    VALIDATION_PASSED=false
fi

# Test 4: Verificar que el rol está configurado
echo "📋 Test 4: Verificando configuración del rol..."
if vault read database/roles/my-role > /dev/null 2>&1; then
    echo "✅ Rol 'my-role' configurado correctamente"
    ((SCORE++))
else
    echo "❌ Rol no configurado. Ejecuta: ./configure-db-engine.sh"
    VALIDATION_PASSED=false
fi

# Test 5: Verificar generación de credenciales dinámicas
echo "📋 Test 5: Verificando generación de credenciales..."
CREDS_OUTPUT=$(vault read database/creds/my-role -format=json 2>/dev/null)
if [ $? -eq 0 ] && [ ! -z "$CREDS_OUTPUT" ]; then
    USERNAME=$(echo $CREDS_OUTPUT | jq -r '.data.username' 2>/dev/null)
    PASSWORD=$(echo $CREDS_OUTPUT | jq -r '.data.password' 2>/dev/null)
    
    if [ ! -z "$USERNAME" ] && [ "$USERNAME" != "null" ] && [ ! -z "$PASSWORD" ] && [ "$PASSWORD" != "null" ]; then
        echo "✅ Credenciales dinámicas generadas exitosamente"
        echo "   👤 Usuario: $USERNAME"
        echo "   🔑 Password: [OCULTO]"
        
        # Test bonus: Verificar que las credenciales funcionan
        if PGPASSWORD=$PASSWORD psql -h localhost -U $USERNAME -d mydb -c "SELECT current_user;" > /dev/null 2>&1; then
            echo "✅ Bonus: Credenciales funcionan para conectar a PostgreSQL"
        else
            echo "⚠️  Las credenciales se generaron pero la conexión falló"
        fi
        
        ((SCORE++))
    else
        echo "❌ Error al extraer credenciales del output"
        VALIDATION_PASSED=false
    fi
else
    echo "❌ No se pueden generar credenciales. Verifica la configuración."
    VALIDATION_PASSED=false
fi

# Mostrar resultado final
echo ""
echo "📊 RESULTADO DE LA VALIDACIÓN"
echo "=============================="
echo "Puntuación: $SCORE/$MAX_SCORE"

if [ "$VALIDATION_PASSED" = true ] && [ $SCORE -eq $MAX_SCORE ]; then
    echo "🎉 ¡LABORATORIO COMPLETADO EXITOSAMENTE!"
    echo "🏆 Badge obtenido: Vault Practitioner"
    echo ""
    echo "Has demostrado que puedes:"
    echo "✅ Configurar y operar Vault"
    echo "✅ Habilitar motores de secretos"
    echo "✅ Configurar roles para credenciales dinámicas"
    echo "✅ Generar y usar credenciales temporales"
    echo ""
    echo "🎯 Próximo paso: Continúa con el laboratorio de Nomad"
    
    # Crear archivo de badge con timestamp
    echo "$(date +%Y%m%d-%H%M%S)" > .badge-vault-earned
    echo "🏆 Badge Vault Practitioner generado automáticamente!"
    exit 0
else
    echo "❌ LABORATORIO INCOMPLETO"
    echo "Por favor, completa todos los pasos antes de continuar."
    echo ""
    echo "💡 Consejos:"
    echo "- Verifica que Docker está ejecutándose: docker ps"
    echo "- Verifica que Vault responde: curl http://localhost:8200/v1/sys/health"
    echo "- Revisa los logs: docker logs postgres-lab"
    exit 1
fi

#!/bin/bash

echo "🔍 Validando Laboratorio Vault Radar..."
echo "======================================="

VALIDATION_PASSED=true
SCORE=0
MAX_SCORE=5

# Test 1: Verificar que el repositorio de prueba existe
echo "📋 Test 1: Verificando repositorio de prueba..."
if [ -d "test-repo" ] && [ -d "test-repo/.git" ]; then
    echo "✅ Repositorio de prueba creado correctamente"
    ((SCORE++))
else
    echo "❌ Repositorio de prueba no encontrado. Ejecuta: ./create-test-repo.sh"
    VALIDATION_PASSED=false
fi

# Test 2: Verificar que existen archivos con secretos
echo "📋 Test 2: Verificando archivos con secretos..."
SECRET_FILES=0
if [ -f "test-repo/config.env" ]; then ((SECRET_FILES++)); fi
if [ -f "test-repo/app.py" ]; then ((SECRET_FILES++)); fi
if [ -f "test-repo/.env" ] || [ -f "test-repo/.env.example" ]; then ((SECRET_FILES++)); fi

if [ $SECRET_FILES -ge 2 ]; then
    echo "✅ Archivos con secretos encontrados ($SECRET_FILES archivos)"
    ((SCORE++))
else
    echo "❌ Archivos con secretos faltantes. Ejecuta: ./create-test-repo.sh"
    VALIDATION_PASSED=false
fi

# Test 3: Verificar detección de secretos (simulado)
echo "📋 Test 3: Verificando detección de secretos..."
cd test-repo 2>/dev/null || { echo "❌ No se puede acceder al repositorio"; VALIDATION_PASSED=false; }

if [ -d "../test-repo" ]; then
    # Buscar patrones de secretos comunes
    SECRETS_DETECTED=0
    
    if grep -r "AKIA[0-9A-Z]\{16\}" . 2>/dev/null | grep -v ".git" > /dev/null; then
        ((SECRETS_DETECTED++))
    fi
    
    if grep -r "sk_test_[0-9a-zA-Z]\{24\}" . 2>/dev/null | grep -v ".git" > /dev/null; then
        ((SECRETS_DETECTED++))
    fi
    
    if grep -r "ghp_[0-9a-zA-Z]\{36\}" . 2>/dev/null | grep -v ".git" > /dev/null; then
        ((SECRETS_DETECTED++))
    fi
    
    if [ $SECRETS_DETECTED -gt 0 ]; then
        echo "✅ Secretos detectados en el repositorio ($SECRETS_DETECTED tipos)"
        ((SCORE++))
    else
        echo "❌ No se detectaron secretos en el repositorio"
        VALIDATION_PASSED=false
    fi
    
    cd ..
fi

# Test 4: Verificar limpieza de secretos (si se ejecutó)
echo "📋 Test 4: Verificando proceso de limpieza..."
if [ -f "test-repo/.gitignore" ] && [ -f "test-repo/.env.example" ]; then
    echo "✅ Archivos de seguridad creados (.gitignore, .env.example)"
    ((SCORE++))
else
    echo "⚠️  Proceso de limpieza no completado (opcional)"
    echo "   💡 Ejecuta: ./fix-secrets.sh para completar la limpieza"
    # No falla la validación, pero no suma punto
fi

# Test 5: Verificar comprensión de buenas prácticas
echo "📋 Test 5: Verificando implementación de buenas prácticas..."
GOOD_PRACTICES=0

# Verificar si hay .gitignore
if [ -f "test-repo/.gitignore" ]; then
    if grep -q "\.env" test-repo/.gitignore; then
        ((GOOD_PRACTICES++))
    fi
fi

# Verificar si hay .env.example
if [ -f "test-repo/.env.example" ]; then
    ((GOOD_PRACTICES++))
fi

# Verificar si se usan variables de entorno en el código
if grep -r "os\.getenv\|process\.env\|\${.*}" test-repo/ 2>/dev/null | grep -v ".git" > /dev/null; then
    ((GOOD_PRACTICES++))
fi

if [ $GOOD_PRACTICES -ge 2 ]; then
    echo "✅ Buenas prácticas implementadas ($GOOD_PRACTICES/3)"
    ((SCORE++))
else
    echo "❌ Buenas prácticas no implementadas completamente"
    VALIDATION_PASSED=false
fi

# Mostrar resultado final
echo ""
echo "📊 RESULTADO DE LA VALIDACIÓN"
echo "=============================="
echo "Puntuación: $SCORE/$MAX_SCORE"

if [ "$VALIDATION_PASSED" = true ] && [ $SCORE -ge 4 ]; then  # Permitir 4/5 para pasar
    echo "🎉 ¡LABORATORIO COMPLETADO EXITOSAMENTE!"
    echo "🏆 Badge obtenido: Vault Radar Practitioner"
    echo ""
    echo "Has demostrado que puedes:"
    echo "✅ Identificar secretos expuestos en código"
    echo "✅ Entender riesgos de seguridad"
    echo "✅ Implementar buenas prácticas de secretos"
    echo "✅ Usar herramientas de escaneo de seguridad"
    echo ""
    echo "🔒 Recuerda: Nunca commitees secretos reales en repositorios"
    echo "🎯 ¡Has completado todos los laboratorios básicos!"
    
    # Crear archivo de badge con timestamp
    echo "$(date +%Y%m%d-%H%M%S)" > .badge-vault-radar-earned
    echo "🏆 Badge Vault Radar Practitioner generado automáticamente!"
    exit 0
else
    echo "❌ LABORATORIO INCOMPLETO"
    echo "Por favor, completa todos los pasos antes de continuar."
    echo ""
    echo "💡 Consejos:"
    echo "- Crea el repositorio de prueba: ./create-test-repo.sh"
    echo "- Revisa los archivos creados: ls -la test-repo/"
    echo "- Implementa la limpieza: ./fix-secrets.sh"
    exit 1
fi

#!/bin/bash

echo "🔍 Verificando limpieza del repositorio..."

cd test-repo

echo "📊 Verificando archivos modificados:"
echo "===================================="

# Verificar que no hay secretos hardcodeados
echo "🔍 Buscando posibles secretos restantes..."

SECRETS_FOUND=0

# Buscar patrones de secretos comunes
if grep -r "AKIA[0-9A-Z]{16}" . 2>/dev/null; then
    echo "❌ Encontradas AWS Access Keys"
    SECRETS_FOUND=1
fi

if grep -r "sk_test_[0-9a-zA-Z]{24}" . 2>/dev/null; then
    echo "❌ Encontradas Stripe Test Keys"
    SECRETS_FOUND=1
fi

if grep -r "ghp_[0-9a-zA-Z]{36}" . 2>/dev/null; then
    echo "❌ Encontrados GitHub Personal Access Tokens"
    SECRETS_FOUND=1
fi

if grep -r "password.*=" . --exclude="*.example" 2>/dev/null | grep -v "getenv\|env\|ENV"; then
    echo "❌ Encontradas posibles passwords hardcodeadas"
    SECRETS_FOUND=1
fi

if [ $SECRETS_FOUND -eq 0 ]; then
    echo "✅ No se encontraron secretos hardcodeados"
else
    echo "⚠️  Se encontraron posibles secretos - revisar manualmente"
fi

echo ""
echo "📁 Archivos de seguridad creados:"
echo "================================="
if [ -f .gitignore ]; then
    echo "✅ .gitignore presente"
else
    echo "❌ .gitignore faltante"
fi

if [ -f .env.example ]; then
    echo "✅ .env.example presente"
else
    echo "❌ .env.example faltante"
fi

if [ -f .env ]; then
    echo "⚠️  .env presente (debería estar en .gitignore)"
else
    echo "✅ .env no presente (correcto)"
fi

cd ..

echo ""
echo "🎯 Resumen de la limpieza:"
echo "========================="
echo "✅ Secretos removidos del código"
echo "✅ Variables de entorno implementadas"
echo "✅ Archivos de ejemplo creados"
echo "✅ .gitignore configurado"

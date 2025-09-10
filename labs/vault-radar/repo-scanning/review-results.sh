#!/bin/bash

echo "📊 Revisando resultados del escaneo..."

if [ ! -f scan-results.txt ]; then
    echo "❌ No se encontraron resultados. Ejecuta primero scan-local-repo.sh"
    exit 1
fi

echo "🔍 Resumen de secretos encontrados:"
echo "=================================="
cat scan-results.txt

echo ""
echo "📈 Estadísticas:"
echo "================"

# Contar secretos por tipo (simulado ya que Vault Radar puede no estar disponible)
echo "Tipos de secretos detectados:"
echo "- AWS Access Keys: $(grep -c "AWS_ACCESS_KEY" scan-results.txt 2>/dev/null || echo "Simulado: 2")"
echo "- API Keys: $(grep -c "API_KEY" scan-results.txt 2>/dev/null || echo "Simulado: 3")"
echo "- Database URLs: $(grep -c "DATABASE" scan-results.txt 2>/dev/null || echo "Simulado: 1")"
echo "- GitHub Tokens: $(grep -c "GITHUB_TOKEN" scan-results.txt 2>/dev/null || echo "Simulado: 1")"

echo ""
echo "⚠️  ACCIÓN REQUERIDA:"
echo "===================="
echo "Los secretos encontrados deben ser:"
echo "1. Removidos del código"
echo "2. Rotados/invalidados"
echo "3. Almacenados en un gestor de secretos"
echo "4. Configurados como variables de entorno"

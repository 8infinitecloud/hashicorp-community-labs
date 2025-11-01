#!/bin/bash

echo "🔍 Escaneando repositorio local con Vault Radar..."

# Verificar si Vault Radar está instalado
if ! command -v vault-radar &> /dev/null; then
    echo "❌ Vault Radar no está instalado"
    echo "📥 Descarga desde: https://releases.hashicorp.com/vault-radar/"
    exit 1
fi

# Escanear el repositorio de prueba
echo "🚀 Iniciando escaneo..."
vault-radar scan repo --path ./test-repo --output-format json --output-file scan-results.json

# También generar reporte en formato texto
vault-radar scan repo --path ./test-repo --output-format text --output-file scan-results.txt

echo "✅ Escaneo completado"
echo "📄 Resultados guardados en:"
echo "   - scan-results.json (formato JSON)"
echo "   - scan-results.txt (formato texto)"

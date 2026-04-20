#!/bin/bash

# Lab 2: Data Sources - Script de Validación

set -e

echo "🧪 Validando Lab 2: Data Sources..."
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0

# Función para verificar
check() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $1"
        ((FAILED++))
    fi
}

# 1. Verificar directorio del proyecto
echo "📁 Verificando estructura del proyecto..."
if [ -d "lab2-data-sources" ]; then
    cd lab2-data-sources
    check "Directorio lab2-data-sources existe"
else
    echo -e "${RED}✗${NC} Directorio lab2-data-sources no encontrado"
    echo ""
    echo "Crea el directorio con: mkdir lab2-data-sources"
    exit 1
fi

# 2. Verificar archivos de configuración
echo ""
echo "📄 Verificando archivos de configuración..."

files=(
    "local-data-sources.tf"
    "http-data-sources.tf"
    "data-in-resources.tf"
    "data-filters.tf"
    "dynamic-data.tf"
)

for file in "${files[@]}"; do
    [ -f "$file" ] && check "Archivo $file existe" || echo -e "${YELLOW}⚠${NC} Archivo $file no encontrado (opcional)"
done

# 3. Verificar que Terraform está inicializado
echo ""
echo "🔧 Verificando inicialización de Terraform..."
[ -d ".terraform" ] && check "Terraform inicializado (.terraform/ existe)" || echo -e "${YELLOW}⚠${NC} Terraform no inicializado"

# 4. Verificar sintaxis
echo ""
echo "✅ Verificando sintaxis de Terraform..."
if command -v terraform &> /dev/null; then
    if terraform fmt -check &> /dev/null; then
        check "Formato de código correcto"
    else
        echo -e "${YELLOW}⚠${NC} Código necesita formateo (ejecuta: terraform fmt)"
    fi
    
    if terraform validate &> /dev/null 2>&1; then
        check "Configuración válida"
    else
        echo -e "${YELLOW}⚠${NC} Configuración tiene errores (ejecuta: terraform validate)"
    fi
else
    echo -e "${YELLOW}⚠${NC} Terraform no está instalado"
fi

# 5. Verificar uso de data sources
echo ""
echo "🔍 Verificando data sources..."

if [ -f "local-data-sources.tf" ]; then
    grep -q "data \"local_file\"" local-data-sources.tf && check "Data source local_file encontrado" || echo -e "${YELLOW}⚠${NC} Data source local_file no encontrado"
fi

if [ -f "http-data-sources.tf" ]; then
    grep -q "data \"http\"" http-data-sources.tf && check "Data source http encontrado" || echo -e "${YELLOW}⚠${NC} Data source http no encontrado"
fi

if [ -f "aws-data-sources.tf" ]; then
    grep -q "data \"aws_" aws-data-sources.tf && check "Data sources AWS encontrados" || echo -e "${YELLOW}⚠${NC} Data sources AWS no encontrados (opcional)"
fi

# 6. Verificar filtros
echo ""
echo "🔎 Verificando filtros..."

if [ -f "aws-data-sources.tf" ]; then
    grep -q "filter {" aws-data-sources.tf && check "Filtros implementados" || echo -e "${YELLOW}⚠${NC} Filtros no encontrados"
fi

# 7. Verificar que data sources se usan en resources
echo ""
echo "🔗 Verificando uso de data sources en resources..."

for file in *.tf; do
    if grep -q "data\." "$file" 2>/dev/null; then
        check "Data sources usados en resources"
        break
    fi
done

# 8. Verificar outputs
echo ""
echo "📤 Verificando outputs..."

for file in *.tf; do
    if grep -q "output" "$file" 2>/dev/null; then
        check "Outputs definidos"
        break
    fi
done

# Resumen
echo ""
echo "================================"
echo "📊 Resumen de Validación"
echo "================================"
echo -e "${GREEN}Pasadas:${NC} $PASSED"
echo -e "${RED}Fallidas:${NC} $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 ¡Laboratorio completado exitosamente!${NC}"
    echo ""
    echo "🏆 Has ganado el badge: Terraform Data Sources Expert"
    echo ""
    echo "Conceptos dominados:"
    echo "  ✓ Data sources locales"
    echo "  ✓ Data sources HTTP"
    echo "  ✓ Data sources AWS (opcional)"
    echo "  ✓ Filtros en data sources"
    echo "  ✓ Usar data sources en resources"
    echo "  ✓ Data sources dinámicos"
    echo ""
    echo "Siguiente: Lab 3 - Variables con Validación"
    exit 0
else
    echo -e "${YELLOW}⚠ Laboratorio incompleto${NC}"
    echo ""
    echo "Revisa los pasos del README.md"
    exit 1
fi

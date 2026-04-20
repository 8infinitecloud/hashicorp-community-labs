#!/bin/bash

# Lab 4: Outputs y Funciones - Script de Validación

set -e

echo "🧪 Validando Lab 4: Outputs y Funciones..."
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
if [ -d "lab4-outputs-funciones" ]; then
    cd lab4-outputs-funciones
    check "Directorio lab4-outputs-funciones existe"
else
    echo -e "${RED}✗${NC} Directorio lab4-outputs-funciones no encontrado"
    echo ""
    echo "Crea el directorio con: mkdir lab4-outputs-funciones"
    exit 1
fi

# 2. Verificar archivos de configuración
echo ""
echo "📄 Verificando archivos de configuración..."

files=(
    "string-functions.tf"
    "collection-functions.tf"
    "numeric-date-functions.tf"
    "network-functions.tf"
    "for-expressions.tf"
    "advanced-outputs.tf"
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

# 5. Verificar funciones de string
echo ""
echo "🔤 Verificando funciones de string..."

if [ -f "string-functions.tf" ]; then
    grep -q "upper\|lower\|title" string-functions.tf && check "Funciones de string encontradas" || echo -e "${YELLOW}⚠${NC} Funciones de string no encontradas"
    grep -q "join\|split" string-functions.tf && check "Funciones join/split encontradas" || echo -e "${YELLOW}⚠${NC} join/split no encontradas"
fi

# 6. Verificar funciones de colecciones
echo ""
echo "📊 Verificando funciones de colecciones..."

if [ -f "collection-functions.tf" ]; then
    grep -q "length\|concat\|contains" collection-functions.tf && check "Funciones de colecciones encontradas" || echo -e "${YELLOW}⚠${NC} Funciones de colecciones no encontradas"
    grep -q "merge\|keys\|values" collection-functions.tf && check "Funciones de map encontradas" || echo -e "${YELLOW}⚠${NC} Funciones de map no encontradas"
fi

# 7. Verificar funciones de red
echo ""
echo "🌐 Verificando funciones de red..."

if [ -f "network-functions.tf" ]; then
    grep -q "cidrhost\|cidrsubnet\|cidrnetmask" network-functions.tf && check "Funciones de red encontradas" || echo -e "${YELLOW}⚠${NC} Funciones de red no encontradas"
fi

# 8. Verificar for expressions
echo ""
echo "🔄 Verificando for expressions..."

if [ -f "for-expressions.tf" ]; then
    grep -q "for.*in.*:" for-expressions.tf && check "For expressions encontradas" || echo -e "${YELLOW}⚠${NC} For expressions no encontradas"
fi

# 9. Verificar outputs
echo ""
echo "📤 Verificando outputs..."

for file in *.tf; do
    if grep -q "output" "$file" 2>/dev/null; then
        check "Outputs definidos"
        break
    fi
done

if grep -q "sensitive.*=.*true" *.tf 2>/dev/null; then
    check "Outputs sensibles encontrados"
else
    echo -e "${YELLOW}⚠${NC} Outputs sensibles no encontrados (opcional)"
fi

# 10. Verificar locals
echo ""
echo "🔧 Verificando locals..."

if grep -q "locals {" *.tf 2>/dev/null; then
    check "Locals definidos"
else
    echo -e "${YELLOW}⚠${NC} Locals no encontrados"
fi

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
    echo "🏆 Has ganado el badge: Terraform Functions Expert"
    echo ""
    echo "Conceptos dominados:"
    echo "  ✓ Funciones de string"
    echo "  ✓ Funciones de colecciones"
    echo "  ✓ Funciones de red (CIDR)"
    echo "  ✓ For expressions"
    echo "  ✓ Outputs avanzados"
    echo "  ✓ Terraform console"
    echo ""
    echo "🎖️  ¡MÓDULO 4 COMPLETADO!"
    echo ""
    echo "Siguiente: Módulo 5 - Terraform Modules"
    exit 0
else
    echo -e "${YELLOW}⚠ Laboratorio incompleto${NC}"
    echo ""
    echo "Revisa los pasos del README.md"
    exit 1
fi

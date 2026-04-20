#!/bin/bash

# Lab 1: Resources con Dependencias y Lifecycle - Script de Validación

set -e

echo "🧪 Validando Lab 1: Resources con Dependencias y Lifecycle..."
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
if [ -d "lab1-lifecycle" ]; then
    cd lab1-lifecycle
    check "Directorio lab1-lifecycle existe"
else
    echo -e "${RED}✗${NC} Directorio lab1-lifecycle no encontrado"
    echo ""
    echo "Crea el directorio con: mkdir lab1-lifecycle"
    exit 1
fi

# 2. Verificar archivos de configuración
echo ""
echo "📄 Verificando archivos de configuración..."

files=(
    "implicit-dependencies.tf"
    "explicit-dependencies.tf"
    "lifecycle-create-before.tf"
    "lifecycle-prevent.tf"
    "lifecycle-ignore.tf"
    "lifecycle-replace.tf"
    "lifecycle-combined.tf"
)

for file in "${files[@]}"; do
    [ -f "$file" ] && check "Archivo $file existe" || echo -e "${YELLOW}⚠${NC} Archivo $file no encontrado (opcional)"
done

# 3. Verificar que Terraform está inicializado
echo ""
echo "🔧 Verificando inicialización de Terraform..."
[ -d ".terraform" ] && check "Terraform inicializado (.terraform/ existe)" || echo -e "${YELLOW}⚠${NC} Terraform no inicializado"

# 4. Verificar sintaxis de archivos
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

# 5. Verificar conceptos de lifecycle en archivos
echo ""
echo "🔍 Verificando conceptos de lifecycle..."

if [ -f "lifecycle-create-before.tf" ]; then
    grep -q "create_before_destroy" lifecycle-create-before.tf && check "create_before_destroy implementado" || echo -e "${YELLOW}⚠${NC} create_before_destroy no encontrado"
fi

if [ -f "lifecycle-prevent.tf" ]; then
    grep -q "prevent_destroy" lifecycle-prevent.tf && check "prevent_destroy implementado" || echo -e "${YELLOW}⚠${NC} prevent_destroy no encontrado"
fi

if [ -f "lifecycle-ignore.tf" ]; then
    grep -q "ignore_changes" lifecycle-ignore.tf && check "ignore_changes implementado" || echo -e "${YELLOW}⚠${NC} ignore_changes no encontrado"
fi

if [ -f "lifecycle-replace.tf" ]; then
    grep -q "replace_triggered_by" lifecycle-replace.tf && check "replace_triggered_by implementado" || echo -e "${YELLOW}⚠${NC} replace_triggered_by no encontrado"
fi

# 6. Verificar dependencias
echo ""
echo "🔗 Verificando dependencias..."

if [ -f "implicit-dependencies.tf" ]; then
    grep -q "local_file\." implicit-dependencies.tf && check "Dependencias implícitas (referencias) encontradas" || echo -e "${YELLOW}⚠${NC} Referencias no encontradas"
fi

if [ -f "explicit-dependencies.tf" ]; then
    grep -q "depends_on" explicit-dependencies.tf && check "Dependencias explícitas (depends_on) encontradas" || echo -e "${YELLOW}⚠${NC} depends_on no encontrado"
fi

# 7. Verificar que se puede generar el grafo
echo ""
echo "📊 Verificando grafo de dependencias..."
if command -v terraform &> /dev/null && [ -d ".terraform" ]; then
    if terraform graph &> /dev/null; then
        check "Grafo de dependencias generado"
    else
        echo -e "${YELLOW}⚠${NC} No se pudo generar el grafo"
    fi
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
    echo "🏆 Has ganado el badge: Terraform Dependencies Master"
    echo ""
    echo "Conceptos dominados:"
    echo "  ✓ Dependencias implícitas y explícitas"
    echo "  ✓ Lifecycle: create_before_destroy"
    echo "  ✓ Lifecycle: prevent_destroy"
    echo "  ✓ Lifecycle: ignore_changes"
    echo "  ✓ Lifecycle: replace_triggered_by"
    echo "  ✓ Grafo de dependencias"
    echo ""
    echo "Siguiente: Lab 2 - Data Sources"
    exit 0
else
    echo -e "${YELLOW}⚠ Laboratorio incompleto${NC}"
    echo ""
    echo "Revisa los pasos del README.md"
    exit 1
fi

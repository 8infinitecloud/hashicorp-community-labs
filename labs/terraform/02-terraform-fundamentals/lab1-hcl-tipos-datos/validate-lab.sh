#!/bin/bash

echo "🔍 Validando Lab 1: HCL y Tipos de Datos"
echo "========================================"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0

validate() {
    local test_name=$1
    local command=$2
    
    echo -n "Validando: $test_name... "
    
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((FAILED++))
        return 1
    fi
}

# Buscar directorio
PROJECT_DIR=""
if [ -d "lab2-hcl" ]; then
    PROJECT_DIR="lab2-hcl"
else
    PROJECT_DIR=$(find . -maxdepth 2 -type d -name "*lab2*hcl*" -o -name "*hcl*" 2>/dev/null | head -1)
fi

if [ -z "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ No se encontró el directorio del proyecto${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Directorio encontrado: $PROJECT_DIR"
echo ""

# Validaciones
echo "📄 Verificando configuración"
echo "----------------------------"
validate "main.tf existe" "test -f $PROJECT_DIR/main.tf"

if [ -f "$PROJECT_DIR/main.tf" ]; then
    # Verificar tipos de variables
    for var_type in "string" "number" "bool" "list" "map" "object"; do
        if grep -q "type.*=.*$var_type" "$PROJECT_DIR/main.tf"; then
            echo -e "${GREEN}✅ PASS${NC} - Variable tipo $var_type encontrada"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠️  WARN${NC} - Variable tipo $var_type no encontrada"
        fi
    done
fi

echo ""
echo "🔧 Verificando locals"
echo "--------------------"
if [ -f "$PROJECT_DIR/main.tf" ]; then
    if grep -q "locals" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}✅ PASS${NC} - Locals definidos"
        ((PASSED++))
    fi
fi

echo ""
echo "📤 Verificando outputs"
echo "---------------------"
if [ -f "$PROJECT_DIR/terraform.tfstate" ]; then
    cd "$PROJECT_DIR"
    OUTPUT_COUNT=$(terraform output 2>/dev/null | grep -c "=")
    if [ "$OUTPUT_COUNT" -ge 3 ]; then
        echo -e "${GREEN}✅ PASS${NC} - $OUTPUT_COUNT outputs encontrados"
        ((PASSED++))
    fi
    cd - > /dev/null
fi

echo ""
echo "📊 RESULTADO FINAL"
echo "=================="
echo -e "Validaciones exitosas: ${GREEN}$PASSED${NC}"
echo -e "Validaciones fallidas: ${RED}$FAILED${NC}"
echo ""

if [ $PASSED -ge 8 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO!${NC}"
    echo "🏆 Badge obtenido: Terraform HCL Master"
    
    BADGE_FILE="../../../.badge-terraform-m2-lab1-earned"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$BADGE_FILE"
    
    echo ""
    echo "🚀 Próximo: Lab 2 - Providers"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO${NC}"
    exit 1
fi

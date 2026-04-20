#!/bin/bash

echo "🔍 Validando Lab 2: Providers"
echo "============================="
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASSED=0
FAILED=0

PROJECT_DIR=$(find . -maxdepth 2 -type d -name "*lab2*provider*" -o -name "*provider*" 2>/dev/null | head -1)

if [ -z "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ No se encontró el directorio del proyecto${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Directorio: $PROJECT_DIR"
echo ""

if [ -f "$PROJECT_DIR/main.tf" ]; then
    if grep -q "required_providers" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}✅ PASS${NC} - required_providers configurado"
        ((PASSED++))
    fi
    
    if grep -q "alias" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}✅ PASS${NC} - Provider con alias encontrado"
        ((PASSED++))
    fi
fi

if [ -f "$PROJECT_DIR/.terraform.lock.hcl" ]; then
    echo -e "${GREEN}✅ PASS${NC} - Lock file generado"
    ((PASSED++))
fi

echo ""
if [ $PASSED -ge 3 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO!${NC}"
    echo "🏆 Badge: Terraform Provider Expert"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-terraform-m2-lab2-earned"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO${NC}"
    exit 1
fi

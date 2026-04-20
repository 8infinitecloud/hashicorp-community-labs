#!/bin/bash

echo "🔍 Validando Lab 3: Terraform State"
echo "===================================="
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASSED=0
FAILED=0

PROJECT_DIR=$(find . -maxdepth 2 -type d -name "*lab2*state*" -o -name "*state*" 2>/dev/null | head -1)

if [ -z "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ No se encontró el directorio del proyecto${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Directorio: $PROJECT_DIR"
echo ""

if [ -f "$PROJECT_DIR/terraform.tfstate" ]; then
    echo -e "${GREEN}✅ PASS${NC} - State file existe"
    ((PASSED++))
    
    cd "$PROJECT_DIR"
    RESOURCES=$(terraform state list 2>/dev/null | wc -l)
    if [ "$RESOURCES" -gt 0 ]; then
        echo -e "${GREEN}✅ PASS${NC} - $RESOURCES recursos en el state"
        ((PASSED++))
    fi
    cd - > /dev/null
fi

if [ -f "$PROJECT_DIR/terraform.tfstate.backup" ]; then
    echo -e "${GREEN}✅ PASS${NC} - Backup del state existe"
    ((PASSED++))
fi

echo ""
if [ $PASSED -ge 3 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO!${NC}"
    echo "🏆 Badge: Terraform State Manager"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-terraform-m2-lab3-earned"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO${NC}"
    exit 1
fi

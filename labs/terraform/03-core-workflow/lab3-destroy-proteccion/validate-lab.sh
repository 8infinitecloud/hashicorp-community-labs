#!/bin/bash

echo "🔍 Validando Lab 3: Destroy y Protección"
echo "========================================="
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASSED=0

PROJECT_DIR=$(find . -maxdepth 2 -type d -name "*lab3*protect*" 2>/dev/null | head -1)

if [ -n "$PROJECT_DIR" ] && [ -f "$PROJECT_DIR/main.tf" ]; then
    echo -e "${GREEN}✅ PASS${NC} - Proyecto encontrado"
    ((PASSED++))
    
    # Verificar lifecycle.prevent_destroy
    if grep -q "prevent_destroy" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}✅ PASS${NC} - Lifecycle prevent_destroy encontrado"
        ((PASSED++))
    fi
fi

echo ""
if [ $PASSED -ge 2 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO!${NC}"
    echo "🏆 Badge: Terraform Protection Master"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-terraform-m3-lab3-earned"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO${NC}"
    exit 1
fi

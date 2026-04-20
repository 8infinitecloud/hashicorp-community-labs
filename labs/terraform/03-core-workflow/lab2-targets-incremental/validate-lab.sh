#!/bin/bash

echo "🔍 Validando Lab 2: Targets Incremental"
echo "========================================"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASSED=0

PROJECT_DIR=$(find . -maxdepth 2 -type d -name "*lab3*target*" 2>/dev/null | head -1)

if [ -n "$PROJECT_DIR" ] && [ -f "$PROJECT_DIR/main.tf" ]; then
    echo -e "${GREEN}✅ PASS${NC} - Proyecto encontrado"
    ((PASSED++))
    
    # Verificar múltiples recursos
    RESOURCE_COUNT=$(grep -c "^resource" "$PROJECT_DIR/main.tf")
    if [ "$RESOURCE_COUNT" -ge 3 ]; then
        echo -e "${GREEN}✅ PASS${NC} - Múltiples recursos definidos ($RESOURCE_COUNT)"
        ((PASSED++))
    fi
fi

echo ""
if [ $PASSED -ge 2 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO!${NC}"
    echo "🏆 Badge: Terraform Targeting Expert"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-terraform-m3-lab2-earned"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO${NC}"
    exit 1
fi

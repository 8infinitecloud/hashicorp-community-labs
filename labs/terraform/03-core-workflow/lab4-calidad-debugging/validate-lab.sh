#!/bin/bash

echo "🔍 Validando Lab 4: Calidad y Debugging"
echo "========================================"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASSED=0

PROJECT_DIR=$(find . -maxdepth 2 -type d -name "*lab3*quality*" 2>/dev/null | head -1)

if [ -n "$PROJECT_DIR" ] && [ -f "$PROJECT_DIR/main.tf" ]; then
    echo -e "${GREEN}✅ PASS${NC} - Proyecto encontrado"
    ((PASSED++))
    
    cd "$PROJECT_DIR"
    
    # Verificar formato
    if terraform fmt -check &> /dev/null; then
        echo -e "${GREEN}✅ PASS${NC} - Código formateado correctamente"
        ((PASSED++))
    fi
    
    # Verificar validación
    if terraform validate &> /dev/null; then
        echo -e "${GREEN}✅ PASS${NC} - Configuración válida"
        ((PASSED++))
    fi
    
    cd - > /dev/null
fi

echo ""
if [ $PASSED -ge 2 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO!${NC}"
    echo "🏆 Badge: Terraform Quality Expert"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-terraform-m3-lab4-earned"
    
    # Verificar si se completó todo el módulo 3
    if [ -f "../../../.badge-terraform-m3-lab1-earned" ] && \
       [ -f "../../../.badge-terraform-m3-lab2-earned" ] && \
       [ -f "../../../.badge-terraform-m3-lab3-earned" ] && \
       [ -f "../../../.badge-terraform-m3-lab4-earned" ]; then
        echo ""
        echo -e "${GREEN}🎖️  ¡MÓDULO 3 COMPLETADO!${NC}"
        echo "🏆 Badge: Core Workflow Complete"
        echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-terraform-module3-complete"
    fi
    
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO${NC}"
    exit 1
fi

#!/bin/bash

echo "🔍 Validando Lab 4: CLI Avanzado"
echo "================================="
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASSED=0

# Verificar que terraform está instalado
if command -v terraform &> /dev/null; then
    echo -e "${GREEN}✅ PASS${NC} - Terraform CLI disponible"
    ((PASSED++))
fi

# Verificar conocimiento de comandos básicos
echo ""
echo "Este lab es sobre práctica con comandos CLI."
echo "Si completaste los ejercicios, has dominado:"
echo "  • Comandos de validación y formato"
echo "  • Comandos de inspección"
echo "  • Workspaces"
echo "  • Debugging"
echo "  • Terraform console"
echo ""

if [ $PASSED -ge 1 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO!${NC}"
    echo "🏆 Badge: Terraform CLI Master"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-terraform-m2-lab4-earned"
    
    # Verificar si se completó todo el módulo 2
    if [ -f "../../../.badge-terraform-m2-lab1-earned" ] && \
       [ -f "../../../.badge-terraform-m2-lab2-earned" ] && \
       [ -f "../../../.badge-terraform-m2-lab3-earned" ] && \
       [ -f "../../../.badge-terraform-m2-lab4-earned" ]; then
        echo ""
        echo -e "${GREEN}🎖️  ¡MÓDULO 2 COMPLETADO!${NC}"
        echo "🏆 Badge: Terraform Fundamentals Complete"
        echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-terraform-module2-complete"
    fi
    
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO${NC}"
    exit 1
fi

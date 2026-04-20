#!/bin/bash

echo "🔍 Validando Lab 1: Workflow Completo"
echo "====================================="
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0

echo -e "${YELLOW}⚠️  Este lab requiere AWS CLI configurado${NC}"
echo ""

# Verificar AWS CLI
if command -v aws &> /dev/null; then
    echo -e "${GREEN}✅ PASS${NC} - AWS CLI instalado"
    ((PASSED++))
    
    # Verificar credenciales
    if aws sts get-caller-identity &> /dev/null; then
        echo -e "${GREEN}✅ PASS${NC} - Credenciales AWS configuradas"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️  WARN${NC} - Credenciales AWS no configuradas"
    fi
else
    echo -e "${RED}❌ FAIL${NC} - AWS CLI no instalado"
    ((FAILED++))
fi

# Buscar proyecto
PROJECT_DIR=$(find . -maxdepth 2 -type d -name "*lab3*workflow*" 2>/dev/null | head -1)

if [ -n "$PROJECT_DIR" ] && [ -f "$PROJECT_DIR/main.tf" ]; then
    echo -e "${GREEN}✅ PASS${NC} - Proyecto encontrado"
    ((PASSED++))
    
    # Verificar recursos en main.tf
    if grep -q "aws_security_group" "$PROJECT_DIR/main.tf" && \
       grep -q "aws_instance" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}✅ PASS${NC} - Recursos AWS definidos"
        ((PASSED++))
    fi
fi

echo ""
echo "📊 RESULTADO"
echo "============"
echo -e "Validaciones exitosas: ${GREEN}$PASSED${NC}"

if [ $PASSED -ge 3 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO!${NC}"
    echo "🏆 Badge: Terraform Workflow Master"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-terraform-m3-lab1-earned"
    exit 0
else
    echo -e "${YELLOW}⚠️  Lab completado parcialmente${NC}"
    echo "Nota: Este lab requiere AWS para completarse totalmente"
    exit 0
fi

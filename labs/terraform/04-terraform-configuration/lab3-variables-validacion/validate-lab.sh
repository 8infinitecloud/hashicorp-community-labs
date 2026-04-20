#!/bin/bash

# Lab 3: Variables con Validación - Script de Validación

set -e

echo "🧪 Validando Lab 3: Variables con Validación..."
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
if [ -d "lab3-variables" ]; then
    cd lab3-variables
    check "Directorio lab3-variables existe"
else
    echo -e "${RED}✗${NC} Directorio lab3-variables no encontrado"
    echo ""
    echo "Crea el directorio con: mkdir lab3-variables"
    exit 1
fi

# 2. Verificar archivos de configuración
echo ""
echo "📄 Verificando archivos de configuración..."

[ -f "variables.tf" ] && check "Archivo variables.tf existe" || echo -e "${YELLOW}⚠${NC} variables.tf no encontrado"
[ -f "main.tf" ] && check "Archivo main.tf existe" || echo -e "${YELLOW}⚠${NC} main.tf no encontrado"
[ -f "complex-variables.tf" ] && check "Archivo complex-variables.tf existe" || echo -e "${YELLOW}⚠${NC} complex-variables.tf no encontrado (opcional)"
[ -f "terraform.tfvars" ] && check "Archivo terraform.tfvars existe" || echo -e "${YELLOW}⚠${NC} terraform.tfvars no encontrado (opcional)"

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

# 5. Verificar validaciones en variables
echo ""
echo "🔍 Verificando validaciones..."

if [ -f "variables.tf" ]; then
    grep -q "validation {" variables.tf && check "Validaciones implementadas" || echo -e "${YELLOW}⚠${NC} Validaciones no encontradas"
    grep -q "error_message" variables.tf && check "Mensajes de error definidos" || echo -e "${YELLOW}⚠${NC} error_message no encontrado"
fi

# 6. Verificar tipos de variables
echo ""
echo "📊 Verificando tipos de variables..."

if [ -f "variables.tf" ] || [ -f "complex-variables.tf" ]; then
    grep -q "type.*=.*string" *.tf && check "Variables tipo string encontradas" || echo -e "${YELLOW}⚠${NC} Variables string no encontradas"
    grep -q "type.*=.*number" *.tf && check "Variables tipo number encontradas" || echo -e "${YELLOW}⚠${NC} Variables number no encontradas"
    grep -q "type.*=.*bool" *.tf && check "Variables tipo bool encontradas" || echo -e "${YELLOW}⚠${NC} Variables bool no encontradas"
fi

if [ -f "complex-variables.tf" ]; then
    grep -q "type.*=.*list" complex-variables.tf && check "Variables tipo list encontradas" || echo -e "${YELLOW}⚠${NC} Variables list no encontradas"
    grep -q "type.*=.*map" complex-variables.tf && check "Variables tipo map encontradas" || echo -e "${YELLOW}⚠${NC} Variables map no encontradas"
    grep -q "type.*=.*object" complex-variables.tf && check "Variables tipo object encontradas" || echo -e "${YELLOW}⚠${NC} Variables object no encontradas"
fi

# 7. Verificar variables sensibles
echo ""
echo "🔒 Verificando variables sensibles..."

if [ -f "variables.tf" ]; then
    grep -q "sensitive.*=.*true" variables.tf && check "Variables sensibles marcadas" || echo -e "${YELLOW}⚠${NC} Variables sensibles no encontradas"
fi

# 8. Verificar archivos tfvars
echo ""
echo "📝 Verificando archivos de valores..."

[ -f "dev.tfvars" ] && check "Archivo dev.tfvars existe" || echo -e "${YELLOW}⚠${NC} dev.tfvars no encontrado (opcional)"
[ -f "prod.tfvars" ] && check "Archivo prod.tfvars existe" || echo -e "${YELLOW}⚠${NC} prod.tfvars no encontrado (opcional)"

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
    echo "🏆 Has ganado el badge: Terraform Variables Master"
    echo ""
    echo "Conceptos dominados:"
    echo "  ✓ Variables con validación"
    echo "  ✓ Tipos primitivos y complejos"
    echo "  ✓ Variables sensibles"
    echo "  ✓ terraform.tfvars"
    echo "  ✓ Precedencia de variables"
    echo ""
    echo "Siguiente: Lab 4 - Outputs y Funciones"
    exit 0
else
    echo -e "${YELLOW}⚠ Laboratorio incompleto${NC}"
    echo ""
    echo "Revisa los pasos del README.md"
    exit 1
fi

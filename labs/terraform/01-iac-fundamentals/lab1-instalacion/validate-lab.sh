#!/bin/bash

echo "🔍 Validando Lab 1: Instalación de Terraform"
echo "============================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contador de validaciones
PASSED=0
FAILED=0

# Función para validar
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

# Validación 1: Terraform está instalado
echo "📦 Verificando instalación de Terraform"
echo "---------------------------------------"
validate "Terraform instalado" "command -v terraform"

if [ $? -eq 0 ]; then
    TERRAFORM_VERSION=$(terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    echo -e "${GREEN}   Versión instalada: $TERRAFORM_VERSION${NC}"
fi

echo ""

# Validación 2: Versión mínima
echo "🔢 Verificando versión de Terraform"
echo "-----------------------------------"
TERRAFORM_VERSION=$(terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

if [ -n "$TERRAFORM_VERSION" ]; then
    MAJOR_VERSION=$(echo $TERRAFORM_VERSION | cut -d'.' -f1)
    
    if [ "$MAJOR_VERSION" -ge 1 ]; then
        echo -e "${GREEN}✅ PASS${NC} - Versión $TERRAFORM_VERSION (>= 1.0)"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC} - Versión $TERRAFORM_VERSION es menor a 1.0"
        ((FAILED++))
    fi
else
    echo -e "${YELLOW}⚠️  WARN${NC} - No se pudo determinar la versión"
fi

echo ""

# Validación 3: Terraform en PATH
echo "🛣️  Verificando PATH"
echo "-------------------"
validate "Terraform en PATH" "which terraform"

if [ $? -eq 0 ]; then
    TERRAFORM_PATH=$(which terraform)
    echo -e "${GREEN}   Ubicación: $TERRAFORM_PATH${NC}"
fi

echo ""

# Validación 4: Comandos básicos funcionan
echo "⚙️  Verificando comandos básicos"
echo "-------------------------------"
validate "terraform -help" "terraform -help"
validate "terraform version" "terraform version"

echo ""

# Resultado final
echo "📊 RESULTADO FINAL"
echo "=================="
echo -e "Validaciones exitosas: ${GREEN}$PASSED${NC}"
echo -e "Validaciones fallidas: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO EXITOSAMENTE!${NC}"
    echo ""
    echo "✅ Terraform está correctamente instalado y configurado"
    echo "✅ Versión compatible detectada"
    echo "✅ Todos los comandos básicos funcionan"
    echo ""
    echo "🏆 Badge obtenido: Terraform Installation"
    echo ""
    
    # Generar badge
    BADGE_FILE="../../../.badge-terraform-lab1-earned"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$BADGE_FILE"
    echo "📝 Badge guardado en: $BADGE_FILE"
    echo ""
    
    echo "🚀 Próximo paso: Lab 2 - Tu Primer Archivo Terraform"
    echo "   cd ../02-primer-archivo"
    echo ""
    
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO${NC}"
    echo ""
    echo "Por favor revisa los errores arriba y:"
    echo "1. Verifica que Terraform esté instalado correctamente"
    echo "2. Asegúrate de que esté en tu PATH"
    echo "3. Verifica que la versión sea 1.0 o superior"
    echo ""
    echo "💡 Consulta el README.md para instrucciones de instalación"
    echo "💡 Revisa la sección de Troubleshooting si tienes problemas"
    echo ""
    
    exit 1
fi

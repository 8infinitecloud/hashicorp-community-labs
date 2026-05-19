#!/bin/bash

echo "🔍 Validando Lab 2: Tu Primer Archivo Terraform"
echo "==============================================="
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

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

# Buscar directorio del proyecto
PROJECT_DIR=""
if [ -d "mi-primer-terraform" ]; then
    PROJECT_DIR="mi-primer-terraform"
else
    echo -e "${YELLOW}⚠️  Buscando directorio del proyecto...${NC}"
    PROJECT_DIR=$(find . -maxdepth 2 -type d -name "*primer*terraform*" 2>/dev/null | head -1)
fi

if [ -z "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ No se encontró el directorio del proyecto${NC}"
    echo "Por favor crea el directorio 'mi-primer-terraform' y completa el lab"
    exit 1
fi

echo -e "${GREEN}✓${NC} Directorio encontrado: $PROJECT_DIR"
echo ""

# Validación 1: Archivo main.tf existe
echo "📄 Verificando archivos de configuración"
echo "----------------------------------------"
validate "main.tf existe" "test -f $PROJECT_DIR/main.tf"

if [ $? -ne 0 ]; then
    echo -e "${RED}   Por favor crea el archivo main.tf${NC}"
fi

echo ""

# Validación 2: Terraform inicializado
echo "🔧 Verificando inicialización"
echo "-----------------------------"
validate "Terraform inicializado" "test -d $PROJECT_DIR/.terraform || test -f $PROJECT_DIR/terraform.tfstate"

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}   Ejecuta: cd $PROJECT_DIR && terraform init${NC}"
fi

echo ""

# Validación 3: Configuración válida
echo "✓ Verificando configuración"
echo "---------------------------"
if [ -f "$PROJECT_DIR/main.tf" ]; then
    cd "$PROJECT_DIR"
    
    if terraform validate > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC} - Configuración válida"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC} - Configuración inválida"
        echo -e "${YELLOW}   Ejecuta: terraform validate${NC}"
        ((FAILED++))
    fi
    
    cd - > /dev/null
else
    echo -e "${RED}❌ FAIL${NC} - No se puede validar (main.tf no existe)"
    ((FAILED++))
fi

echo ""

# Validación 4: Estado generado
echo "💾 Verificando estado"
echo "--------------------"
validate "terraform.tfstate existe" "test -f $PROJECT_DIR/terraform.tfstate"

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}   Ejecuta: cd $PROJECT_DIR && terraform apply${NC}"
fi

echo ""

# Validación 5: Outputs configurados
echo "📤 Verificando outputs"
echo "---------------------"
if [ -f "$PROJECT_DIR/main.tf" ]; then
    if grep -q "output" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}✅ PASS${NC} - Outputs encontrados en main.tf"
        ((PASSED++))
        
        # Mostrar outputs si el estado existe
        if [ -f "$PROJECT_DIR/terraform.tfstate" ]; then
            echo ""
            echo -e "${GREEN}Outputs actuales:${NC}"
            cd "$PROJECT_DIR"
            terraform output 2>/dev/null | head -10
            cd - > /dev/null
        fi
    else
        echo -e "${RED}❌ FAIL${NC} - No se encontraron outputs"
        ((FAILED++))
    fi
else
    echo -e "${RED}❌ FAIL${NC} - No se puede verificar (main.tf no existe)"
    ((FAILED++))
fi

echo ""

# Validación 6: Locals configurados
echo "🔧 Verificando locals"
echo "--------------------"
if [ -f "$PROJECT_DIR/main.tf" ]; then
    if grep -q "locals" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}✅ PASS${NC} - Locals encontrados en main.tf"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️  WARN${NC} - No se encontraron locals (opcional)"
    fi
fi

echo ""

# Resultado final
echo "📊 RESULTADO FINAL"
echo "=================="
echo -e "Validaciones exitosas: ${GREEN}$PASSED${NC}"
echo -e "Validaciones fallidas: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ] && [ $PASSED -ge 5 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO EXITOSAMENTE!${NC}"
    echo ""
    echo "✅ Archivo main.tf creado correctamente"
    echo "✅ Terraform inicializado"
    echo "✅ Configuración válida"
    echo "✅ Estado generado"
    echo "✅ Outputs configurados"
    echo ""
    echo "🏆 Badge obtenido: Terraform First Configuration"
    echo ""
    
    # Generar badge
    BADGE_FILE="../../../.badge-terraform-lab2-earned"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$BADGE_FILE"
    echo "📝 Badge guardado en: $BADGE_FILE"
    echo ""
    
    echo "🎓 Conceptos aprendidos:"
    echo "   • Estructura de archivos Terraform"
    echo "   • Comandos básicos (init, validate, apply)"
    echo "   • Outputs y locals"
    echo "   • Archivo de estado"
    echo ""
    
    echo "🚀 Próximo paso: Lab 3 - Infraestructura Local"
    echo "   cd ../lab3-infraestructura-local"
    echo ""
    
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO${NC}"
    echo ""
    echo "Por favor completa los siguientes pasos:"
    echo "1. Crea el directorio: mkdir mi-primer-terraform"
    echo "2. Crea el archivo main.tf con la configuración"
    echo "3. Ejecuta: terraform init"
    echo "4. Ejecuta: terraform validate"
    echo "5. Ejecuta: terraform apply"
    echo ""
    echo "💡 Consulta el README.md para instrucciones detalladas"
    echo ""
    
    exit 1
fi

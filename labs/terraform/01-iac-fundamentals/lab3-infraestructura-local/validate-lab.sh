#!/bin/bash

echo "🔍 Validando Lab 3: Infraestructura Local con Terraform"
echo "======================================================="
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
if [ -d "lab3-iac-demo" ]; then
    PROJECT_DIR="lab3-iac-demo"
else
    echo -e "${YELLOW}⚠️  Buscando directorio del proyecto...${NC}"
    PROJECT_DIR=$(find . -maxdepth 2 -type d -name "*lab3*" -o -name "*iac-demo*" 2>/dev/null | head -1)
fi

if [ -z "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ No se encontró el directorio del proyecto${NC}"
    echo "Por favor crea el directorio 'lab3-iac-demo' y completa el lab"
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

# Validación 2: Variables definidas
echo "🔧 Verificando variables"
echo "-----------------------"
if [ -f "$PROJECT_DIR/main.tf" ]; then
    if grep -q "variable \"app_name\"" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}✅ PASS${NC} - Variable app_name encontrada"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC} - Variable app_name no encontrada"
        ((FAILED++))
    fi
    
    if grep -q "variable \"environment\"" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}✅ PASS${NC} - Variable environment encontrada"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC} - Variable environment no encontrada"
        ((FAILED++))
    fi
else
    echo -e "${RED}❌ FAIL${NC} - No se puede verificar (main.tf no existe)"
    ((FAILED+=2))
fi

echo ""

# Validación 3: Locals definidos
echo "📊 Verificando locals"
echo "--------------------"
if [ -f "$PROJECT_DIR/main.tf" ]; then
    if grep -q "locals" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}✅ PASS${NC} - Locals encontrados"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC} - Locals no encontrados"
        ((FAILED++))
    fi
fi

echo ""

# Validación 4: Recursos local_file definidos
echo "📦 Verificando recursos"
echo "----------------------"
if [ -f "$PROJECT_DIR/main.tf" ]; then
    RESOURCE_COUNT=$(grep -c "resource \"local_file\"" "$PROJECT_DIR/main.tf")
    
    if [ "$RESOURCE_COUNT" -ge 3 ]; then
        echo -e "${GREEN}✅ PASS${NC} - $RESOURCE_COUNT recursos local_file encontrados"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC} - Solo $RESOURCE_COUNT recursos encontrados (se esperan al menos 3)"
        ((FAILED++))
    fi
fi

echo ""

# Validación 5: Terraform aplicado
echo "🚀 Verificando aplicación"
echo "------------------------"
validate "Terraform inicializado" "test -d $PROJECT_DIR/.terraform"

if [ -f "$PROJECT_DIR/terraform.tfstate" ]; then
    echo -e "${GREEN}✅ PASS${NC} - Estado de Terraform existe"
    ((PASSED++))
    
    # Verificar que hay recursos en el estado
    cd "$PROJECT_DIR"
    RESOURCES=$(terraform state list 2>/dev/null | wc -l)
    if [ "$RESOURCES" -gt 0 ]; then
        echo -e "${GREEN}   $RESOURCES recursos en el estado${NC}"
    fi
    cd - > /dev/null
else
    echo -e "${RED}❌ FAIL${NC} - Estado no existe (ejecuta terraform apply)"
    ((FAILED++))
fi

echo ""

# Validación 6: Archivos generados
echo "📁 Verificando archivos generados"
echo "---------------------------------"
validate "config/app.conf existe" "test -f $PROJECT_DIR/config/app.conf"
validate "config/.env existe" "test -f $PROJECT_DIR/config/.env"
validate "scripts/deploy.sh existe" "test -f $PROJECT_DIR/scripts/deploy.sh"
validate "README.md generado" "test -f $PROJECT_DIR/README.md"

# Verificar permisos del script
if [ -f "$PROJECT_DIR/scripts/deploy.sh" ]; then
    if [ -x "$PROJECT_DIR/scripts/deploy.sh" ]; then
        echo -e "${GREEN}✅ PASS${NC} - deploy.sh es ejecutable"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️  WARN${NC} - deploy.sh no es ejecutable"
    fi
fi

echo ""

# Validación 7: Contenido de archivos
echo "📝 Verificando contenido"
echo "-----------------------"
if [ -f "$PROJECT_DIR/config/app.conf" ]; then
    if grep -q "application" "$PROJECT_DIR/config/app.conf"; then
        echo -e "${GREEN}✅ PASS${NC} - app.conf tiene configuración válida"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC} - app.conf no tiene el formato esperado"
        ((FAILED++))
    fi
fi

if [ -f "$PROJECT_DIR/config/.env" ]; then
    if grep -q "APP_NAME" "$PROJECT_DIR/config/.env"; then
        echo -e "${GREEN}✅ PASS${NC} - .env tiene variables de entorno"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC} - .env no tiene el formato esperado"
        ((FAILED++))
    fi
fi

echo ""

# Validación 8: Outputs
echo "📤 Verificando outputs"
echo "---------------------"
if [ -f "$PROJECT_DIR/main.tf" ]; then
    OUTPUT_COUNT=$(grep -c "^output" "$PROJECT_DIR/main.tf")
    
    if [ "$OUTPUT_COUNT" -ge 2 ]; then
        echo -e "${GREEN}✅ PASS${NC} - $OUTPUT_COUNT outputs encontrados"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC} - Solo $OUTPUT_COUNT outputs (se esperan al menos 2)"
        ((FAILED++))
    fi
fi

echo ""

# Mostrar ejemplo de configuración generada
if [ -f "$PROJECT_DIR/config/app.conf" ]; then
    echo "📋 Vista previa de app.conf:"
    echo "----------------------------"
    head -10 "$PROJECT_DIR/config/app.conf" | sed 's/^/   /'
    echo ""
fi

# Resultado final
echo "📊 RESULTADO FINAL"
echo "=================="
echo -e "Validaciones exitosas: ${GREEN}$PASSED${NC}"
echo -e "Validaciones fallidas: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ] && [ $PASSED -ge 10 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO EXITOSAMENTE!${NC}"
    echo ""
    echo "✅ Proyecto creado correctamente"
    echo "✅ Variables y locals configurados"
    echo "✅ Recursos local_file definidos"
    echo "✅ Terraform aplicado exitosamente"
    echo "✅ Archivos generados correctamente"
    echo "✅ Contenido válido en archivos"
    echo ""
    echo "🏆 Badge obtenido: Terraform IaC Fundamentals"
    echo ""
    
    # Generar badge
    BADGE_FILE="../../../.badge-terraform-lab3-earned"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$BADGE_FILE"
    echo "📝 Badge guardado en: $BADGE_FILE"
    echo ""
    
    echo "🎓 Conceptos dominados:"
    echo "   • Variables de entrada y locals"
    echo "   • Recursos y providers"
    echo "   • Interpolación de strings"
    echo "   • Condicionales en Terraform"
    echo "   • Outputs informativos"
    echo "   • Ciclo completo de IaC"
    echo ""
    
    echo "💡 Experimentos sugeridos:"
    echo "   1. Cambiar a producción: terraform apply -var=\"environment=produccion\""
    echo "   2. Crear terraform.tfvars con tus valores"
    echo "   3. Agregar más recursos (docker-compose, nginx.conf, etc.)"
    echo "   4. Usar count para recursos condicionales"
    echo ""
    
    echo "🚀 Próximo paso: Módulo 2 - Terraform Fundamentals"
    echo "   cd ../../02-terraform-fundamentals"
    echo ""
    
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO${NC}"
    echo ""
    echo "Por favor completa los siguientes pasos:"
    echo "1. Crea el directorio: mkdir lab3-iac-demo && cd lab3-iac-demo"
    echo "2. Crea el archivo main.tf con la configuración completa"
    echo "3. Ejecuta: terraform init"
    echo "4. Ejecuta: terraform apply"
    echo "5. Verifica los archivos generados"
    echo ""
    echo "💡 Consulta el README.md para el código completo"
    echo ""
    
    exit 1
fi

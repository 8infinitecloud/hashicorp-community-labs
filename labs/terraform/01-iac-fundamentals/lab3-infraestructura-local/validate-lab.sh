#!/bin/bash

echo "Validando Lab 3: Infraestructura Local con Terraform"
echo "====================================================="
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0

validate() {
    local test_name=$1
    local command=$2

    echo -n "Validando: $test_name... "

    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((FAILED++))
        return 1
    fi
}

# Buscar directorio del proyecto
PROJECT_DIR=""
if [ -d "lab3-iac-demo" ]; then
    PROJECT_DIR="lab3-iac-demo"
else
    echo -e "${YELLOW}Buscando directorio del proyecto...${NC}"
    PROJECT_DIR=$(find . -maxdepth 2 -type d \( -name "*lab3*" -o -name "*iac-demo*" \) 2>/dev/null | head -1)
fi

if [ -z "$PROJECT_DIR" ]; then
    echo -e "${RED}No se encontro el directorio del proyecto${NC}"
    echo "Crea el directorio 'lab3-iac-demo' y completa el lab"
    exit 1
fi

echo "Directorio encontrado: $PROJECT_DIR"
echo ""

# Verificar version de Terraform
echo "Verificando Terraform"
echo "---------------------"
TF_VERSION=$(terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
if [ -n "$TF_VERSION" ]; then
    echo -e "${GREEN}PASS${NC} - Terraform $TF_VERSION instalado"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC} - Terraform no encontrado"
    ((FAILED++))
fi
echo ""

# Archivos de configuracion
echo "Verificando archivos de configuracion"
echo "--------------------------------------"
validate "main.tf existe" "test -f $PROJECT_DIR/main.tf"
validate "Terraform inicializado" "test -d $PROJECT_DIR/.terraform || test -f $PROJECT_DIR/terraform.tfstate"
echo ""

# Variables en main.tf
echo "Verificando variables"
echo "---------------------"
if [ -f "$PROJECT_DIR/main.tf" ]; then
    if grep -q 'variable "app_name"' "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}PASS${NC} - Variable app_name encontrada"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - Variable app_name no encontrada"
        ((FAILED++))
    fi

    if grep -q 'variable "environment"' "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}PASS${NC} - Variable environment encontrada"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - Variable environment no encontrada"
        ((FAILED++))
    fi
else
    echo -e "${RED}FAIL${NC} - main.tf no existe, no se pueden verificar variables"
    ((FAILED+=2))
fi
echo ""

# Locals y recursos
echo "Verificando locals y recursos"
echo "-----------------------------"
if [ -f "$PROJECT_DIR/main.tf" ]; then
    if grep -q "locals" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}PASS${NC} - Bloque locals encontrado"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - Bloque locals no encontrado"
        ((FAILED++))
    fi

    RESOURCE_COUNT=$(grep -c 'resource "local_file"' "$PROJECT_DIR/main.tf" 2>/dev/null || echo 0)
    if [ "$RESOURCE_COUNT" -ge 3 ]; then
        echo -e "${GREEN}PASS${NC} - $RESOURCE_COUNT recursos local_file encontrados"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - Solo $RESOURCE_COUNT recursos local_file (se esperan al menos 3)"
        ((FAILED++))
    fi

    OUTPUT_COUNT=$(grep -c "^output" "$PROJECT_DIR/main.tf" 2>/dev/null || echo 0)
    if [ "$OUTPUT_COUNT" -ge 2 ]; then
        echo -e "${GREEN}PASS${NC} - $OUTPUT_COUNT outputs encontrados"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - Solo $OUTPUT_COUNT outputs (se esperan al menos 2)"
        ((FAILED++))
    fi
fi
echo ""

# Archivos generados
echo "Verificando archivos generados"
echo "------------------------------"
validate "config/app.conf existe" "test -f $PROJECT_DIR/config/app.conf"
validate "config/.env existe" "test -f $PROJECT_DIR/config/.env"
validate "scripts/deploy.sh existe" "test -f $PROJECT_DIR/scripts/deploy.sh"

if [ -f "$PROJECT_DIR/scripts/deploy.sh" ]; then
    if [ -x "$PROJECT_DIR/scripts/deploy.sh" ]; then
        echo -e "${GREEN}PASS${NC} - deploy.sh tiene permisos de ejecucion"
        ((PASSED++))
    else
        echo -e "${YELLOW}WARN${NC} - deploy.sh no es ejecutable (file_permission puede no haberse aplicado)"
    fi
fi
echo ""

# Contenido de archivos
echo "Verificando contenido"
echo "---------------------"
if [ -f "$PROJECT_DIR/config/app.conf" ]; then
    if grep -q "application" "$PROJECT_DIR/config/app.conf"; then
        echo -e "${GREEN}PASS${NC} - app.conf tiene la seccion [application]"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - app.conf no tiene el formato esperado"
        ((FAILED++))
    fi
fi

if [ -f "$PROJECT_DIR/config/.env" ]; then
    if grep -q "APP_NAME" "$PROJECT_DIR/config/.env"; then
        echo -e "${GREEN}PASS${NC} - .env tiene variables de entorno"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - .env no tiene el formato esperado"
        ((FAILED++))
    fi
fi
echo ""

# Resultado final
echo "RESULTADO FINAL"
echo "==============="
echo -e "Validaciones exitosas: ${GREEN}$PASSED${NC}"
echo -e "Validaciones fallidas: ${RED}$FAILED${NC}"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO EXITOSAMENTE${NC}"
    echo ""
    echo "Conceptos dominados:"
    echo "  - Variables de entrada y locals"
    echo "  - Condicionales en HCL"
    echo "  - Recursos local_file con file_permission"
    echo "  - Interpolacion de strings"
    echo "  - Outputs informativos"
    echo "  - Ciclo completo de IaC (init/plan/apply/destroy)"
    echo ""
    echo "Siguiente: Modulo 2 - Terraform Fundamentals"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO${NC}"
    echo ""
    echo "Pasos pendientes:"
    echo "  1. Crear el directorio: mkdir lab3-iac-demo"
    echo "  2. Crear main.tf con variables, locals y recursos local_file"
    echo "  3. Ejecutar: terraform init"
    echo "  4. Ejecutar: terraform apply -auto-approve"
    echo "  5. Verificar los archivos generados en config/ y scripts/"
    exit 1
fi

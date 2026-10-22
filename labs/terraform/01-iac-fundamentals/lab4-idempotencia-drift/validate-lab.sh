#!/bin/bash

echo "Validando Lab 4: Idempotencia, Drift y State"
echo "============================================="
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
if [ -d "lab4-drift-demo" ]; then
    PROJECT_DIR="lab4-drift-demo"
else
    echo -e "${YELLOW}Buscando directorio del proyecto...${NC}"
    PROJECT_DIR=$(find . -maxdepth 2 -type d \( -name "*lab4*" -o -name "*drift*" \) 2>/dev/null | head -1)
fi

if [ -z "$PROJECT_DIR" ]; then
    echo -e "${RED}No se encontro el directorio del proyecto${NC}"
    echo "Crea el directorio 'lab4-drift-demo' y completa el lab"
    exit 1
fi

echo "Directorio encontrado: $PROJECT_DIR"
echo ""

# Configuracion
echo "Verificando configuracion"
echo "-------------------------"
validate "main.tf existe" "test -f $PROJECT_DIR/main.tf"
validate "Terraform inicializado" "test -d $PROJECT_DIR/.terraform"
validate "Variable puerto declarada" "grep -q 'variable \"puerto\"' $PROJECT_DIR/main.tf"
validate "Puerto por defecto cambiado a 8081 (paso 9)" "grep -qE 'default[[:space:]]*=[[:space:]]*8081' $PROJECT_DIR/main.tf"
echo ""

# State
echo "Verificando state"
echo "-----------------"
validate "terraform.tfstate existe" "test -f $PROJECT_DIR/terraform.tfstate"
validate "terraform.tfstate.backup existe (varios applies)" "test -f $PROJECT_DIR/terraform.tfstate.backup"
validate "local_file.web_config en el state" "terraform -chdir=$PROJECT_DIR state list | grep -qx 'local_file.web_config'"
validate "local_file.inventario en el state" "terraform -chdir=$PROJECT_DIR state list | grep -qx 'local_file.inventario'"
echo ""

# Archivos generados
echo "Verificando archivos generados"
echo "------------------------------"
validate "servidor/web.conf existe" "test -f $PROJECT_DIR/servidor/web.conf"
validate "servidor/inventario.txt existe" "test -f $PROJECT_DIR/servidor/inventario.txt"
validate "web.conf usa el puerto 8081" "grep -qE 'puerto[[:space:]]*=[[:space:]]*8081' $PROJECT_DIR/servidor/web.conf"
validate "web.conf sin cambios manuales (sin puerto 9999)" "! grep -q '9999' $PROJECT_DIR/servidor/web.conf"
echo ""

# Drift
echo "Verificando drift"
echo "-----------------"
echo -n "Validando: plan sin cambios pendientes (exit code 0)... "
terraform -chdir=$PROJECT_DIR plan -detailed-exitcode -input=false -no-color > /dev/null 2>&1
PLAN_EXIT=$?
if [ "$PLAN_EXIT" -eq 0 ]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC} (exit code $PLAN_EXIT)"
    ((FAILED++))
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
    echo "  - Idempotencia: aplicar dos veces no cambia nada"
    echo "  - Deteccion y correccion de drift"
    echo "  - Inspeccion del state (state list / state show)"
    echo "  - Lectura del plan: + crear, -/+ reemplazar"
    echo "  - plan -detailed-exitcode para CI"
    echo ""
    echo "Siguiente: Modulo 2 - Terraform Fundamentals"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO${NC}"
    echo ""
    echo "Pasos pendientes:"
    echo "  1. Crear lab4-drift-demo/main.tf y ejecutar terraform init + apply"
    echo "  2. Provocar y corregir el drift (pasos 6 a 8)"
    echo "  3. Cambiar el puerto por defecto a 8081 y aplicar (paso 9)"
    echo "  4. Confirmar que terraform plan -detailed-exitcode devuelve 0"
    echo "  5. No ejecutes terraform destroy antes de validar"
    exit 1
fi

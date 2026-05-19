#!/bin/bash

echo "Validando Lab 1: HCL y Tipos de Datos"
echo "======================================="
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
if [ -d "lab1-hcl" ]; then
    PROJECT_DIR="lab1-hcl"
else
    echo -e "${YELLOW}Buscando directorio del proyecto...${NC}"
    PROJECT_DIR=$(find . -maxdepth 2 -type d -name "*lab1*hcl*" -o -name "*hcl*" 2>/dev/null | head -1)
fi

if [ -z "$PROJECT_DIR" ]; then
    echo -e "${RED}No se encontro el directorio del proyecto${NC}"
    echo "Crea el directorio 'lab1-hcl' y completa el lab"
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

# Tipos de variables
echo "Verificando tipos de variables en main.tf"
echo "------------------------------------------"
if [ -f "$PROJECT_DIR/main.tf" ]; then
    for var_type in "string" "number" "bool" "list" "map" "object"; do
        if grep -q "type.*=.*$var_type" "$PROJECT_DIR/main.tf"; then
            echo -e "${GREEN}PASS${NC} - Variable tipo $var_type encontrada"
            ((PASSED++))
        else
            echo -e "${YELLOW}WARN${NC} - Variable tipo $var_type no encontrada (recomendado)"
        fi
    done
else
    echo -e "${RED}FAIL${NC} - main.tf no existe"
    ((FAILED++))
fi
echo ""

# Locals
echo "Verificando locals"
echo "------------------"
if [ -f "$PROJECT_DIR/main.tf" ]; then
    if grep -q "locals" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}PASS${NC} - Bloque locals encontrado"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - Bloque locals no encontrado"
        ((FAILED++))
    fi

    OUTPUT_COUNT=$(grep -c "^output" "$PROJECT_DIR/main.tf" 2>/dev/null || echo 0)
    if [ "$OUTPUT_COUNT" -ge 3 ]; then
        echo -e "${GREEN}PASS${NC} - $OUTPUT_COUNT outputs encontrados"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - Solo $OUTPUT_COUNT outputs (se esperan al menos 3)"
        ((FAILED++))
    fi
fi
echo ""

# State y outputs aplicados
echo "Verificando ejecucion"
echo "---------------------"
if [ -f "$PROJECT_DIR/terraform.tfstate" ]; then
    echo -e "${GREEN}PASS${NC} - State file existe (terraform apply ejecutado)"
    ((PASSED++))

    cd "$PROJECT_DIR"
    OUTPUT_COUNT=$(terraform output 2>/dev/null | grep -c "=" || echo 0)
    if [ "$OUTPUT_COUNT" -ge 3 ]; then
        echo -e "${GREEN}PASS${NC} - $OUTPUT_COUNT outputs registrados en el state"
        ((PASSED++))
    else
        echo -e "${YELLOW}WARN${NC} - Pocos outputs en el state ($OUTPUT_COUNT)"
    fi
    cd - > /dev/null
else
    echo -e "${RED}FAIL${NC} - State file no existe (ejecuta terraform apply)"
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
    echo "  - Tipos primitivos: string, number, bool"
    echo "  - Tipos de coleccion: list, map"
    echo "  - Tipo estructural: object"
    echo "  - Locals y funciones built-in"
    echo "  - Expresiones condicionales (ternario)"
    echo "  - Terraform console interactivo"
    echo ""
    echo "Siguiente: Lab 2 - Providers"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO${NC}"
    echo ""
    echo "Pasos pendientes:"
    echo "  1. Crear el directorio: mkdir lab1-hcl"
    echo "  2. Crear main.tf con variables de todos los tipos"
    echo "  3. Agregar locals con funciones y condicionales"
    echo "  4. Ejecutar: terraform init"
    echo "  5. Ejecutar: terraform apply -auto-approve"
    exit 1
fi

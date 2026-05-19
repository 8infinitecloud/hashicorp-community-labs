#!/bin/bash

echo "Validando Lab 2: Providers y Versionado"
echo "========================================="
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
if [ -d "lab2-providers" ]; then
    PROJECT_DIR="lab2-providers"
else
    echo -e "${YELLOW}Buscando directorio del proyecto...${NC}"
    PROJECT_DIR=$(find . -maxdepth 2 -type d \( -name "*lab2*provider*" -o -name "*provider*" \) 2>/dev/null | head -1)
fi

if [ -z "$PROJECT_DIR" ]; then
    echo -e "${RED}No se encontro el directorio del proyecto${NC}"
    echo "Crea el directorio 'lab2-providers' y completa el lab"
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
validate "Lock file generado" "test -f $PROJECT_DIR/.terraform.lock.hcl"
echo ""

# Contenido de main.tf
echo "Verificando configuracion de providers"
echo "--------------------------------------"
if [ -f "$PROJECT_DIR/main.tf" ]; then
    if grep -q "required_providers" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}PASS${NC} - Bloque required_providers encontrado"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - Bloque required_providers no encontrado"
        ((FAILED++))
    fi

    if grep -q "required_version" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}PASS${NC} - required_version declarado"
        ((PASSED++))
    else
        echo -e "${YELLOW}WARN${NC} - required_version no declarado (recomendado)"
    fi

    if grep -q '"hashicorp/random"' "$PROJECT_DIR/main.tf" || grep -q "hashicorp/random" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}PASS${NC} - Provider random configurado"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - Provider random no encontrado"
        ((FAILED++))
    fi

    if grep -q '"hashicorp/local"' "$PROJECT_DIR/main.tf" || grep -q "hashicorp/local" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}PASS${NC} - Provider local configurado"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - Provider local no encontrado"
        ((FAILED++))
    fi

    if grep -q '~>' "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}PASS${NC} - Pessimistic constraint (~>) usado"
        ((PASSED++))
    else
        echo -e "${YELLOW}WARN${NC} - Pessimistic constraint (~>) no encontrado"
    fi
else
    echo -e "${RED}FAIL${NC} - main.tf no existe"
    ((FAILED+=4))
fi
echo ""

# Lock file content
echo "Verificando lock file"
echo "---------------------"
if [ -f "$PROJECT_DIR/.terraform.lock.hcl" ]; then
    if grep -q "provider" "$PROJECT_DIR/.terraform.lock.hcl"; then
        echo -e "${GREEN}PASS${NC} - Lock file contiene providers bloqueados"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - Lock file vacio o invalido"
        ((FAILED++))
    fi
fi
echo ""

# State y recursos aplicados
echo "Verificando ejecucion"
echo "---------------------"
if [ -f "$PROJECT_DIR/terraform.tfstate" ]; then
    echo -e "${GREEN}PASS${NC} - State file existe (terraform apply ejecutado)"
    ((PASSED++))

    cd "$PROJECT_DIR"
    RESOURCES=$(terraform state list 2>/dev/null | wc -l | tr -d ' ')
    if [ "$RESOURCES" -gt 0 ]; then
        echo -e "${GREEN}PASS${NC} - $RESOURCES recursos en el state"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - No hay recursos en el state"
        ((FAILED++))
    fi
    cd - > /dev/null
else
    echo -e "${RED}FAIL${NC} - State file no existe (ejecuta terraform apply)"
    ((FAILED++))
fi

validate "provider-info.txt generado" "test -f $PROJECT_DIR/provider-info.txt"
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
    echo "  - Declaracion de providers con required_providers"
    echo "  - Versionado semantico y pessimistic constraint (~>)"
    echo "  - Lock file para reproducibilidad"
    echo "  - Providers random y local"
    echo "  - terraform init, providers, version"
    echo ""
    echo "Siguiente: Lab 3 - Terraform State"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO${NC}"
    echo ""
    echo "Pasos pendientes:"
    echo "  1. Crear el directorio: mkdir lab2-providers"
    echo "  2. Crear main.tf con required_providers (random y local)"
    echo "  3. Ejecutar: terraform init"
    echo "  4. Verificar: cat .terraform.lock.hcl"
    echo "  5. Ejecutar: terraform apply -auto-approve"
    exit 1
fi

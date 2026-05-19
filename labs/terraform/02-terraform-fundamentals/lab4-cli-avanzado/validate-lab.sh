#!/bin/bash

echo "Validando Lab 4: Terraform CLI Avanzado"
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
if [ -d "lab4-cli" ]; then
    PROJECT_DIR="lab4-cli"
else
    echo -e "${YELLOW}Buscando directorio del proyecto...${NC}"
    PROJECT_DIR=$(find . -maxdepth 2 -type d \( -name "*lab4*cli*" -o -name "*lab4*" \) 2>/dev/null | grep -v ".terraform" | head -1)
fi

if [ -z "$PROJECT_DIR" ]; then
    echo -e "${RED}No se encontro el directorio del proyecto${NC}"
    echo "Crea el directorio 'lab4-cli' y completa el lab"
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
    echo -e "${RED}FAIL${NC} - Terraform no encontrado en PATH"
    ((FAILED++))
fi
echo ""

# Archivos de configuracion
echo "Verificando archivos de configuracion"
echo "--------------------------------------"
validate "main.tf existe" "test -f $PROJECT_DIR/main.tf"
validate "Terraform inicializado" "test -d $PROJECT_DIR/.terraform || test -f $PROJECT_DIR/terraform.tfstate"
echo ""

# Contenido de main.tf
echo "Verificando configuracion"
echo "-------------------------"
if [ -f "$PROJECT_DIR/main.tf" ]; then
    if grep -q "required_providers" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}PASS${NC} - required_providers declarado"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - required_providers no encontrado"
        ((FAILED++))
    fi

    if grep -q "^variable" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}PASS${NC} - Variables declaradas"
        ((PASSED++))
    else
        echo -e "${YELLOW}WARN${NC} - No se encontraron variables"
    fi

    if grep -q "^output" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}PASS${NC} - Outputs declarados"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - No se encontraron outputs"
        ((FAILED++))
    fi
else
    echo -e "${RED}FAIL${NC} - main.tf no existe"
    ((FAILED+=3))
fi
echo ""

# State y ejecucion
echo "Verificando ejecucion"
echo "---------------------"
validate "State file existe" "test -f $PROJECT_DIR/terraform.tfstate"

if [ -f "$PROJECT_DIR/terraform.tfstate" ]; then
    cd "$PROJECT_DIR"
    RESOURCES=$(terraform state list 2>/dev/null | wc -l | tr -d ' ')
    if [ "$RESOURCES" -gt 0 ]; then
        echo -e "${GREEN}PASS${NC} - $RESOURCES recursos en el state"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - No hay recursos en el state"
        ((FAILED++))
    fi

    OUTPUT_COUNT=$(terraform output 2>/dev/null | grep -c "=" || echo 0)
    if [ "$OUTPUT_COUNT" -ge 1 ]; then
        echo -e "${GREEN}PASS${NC} - Outputs disponibles ($OUTPUT_COUNT)"
        ((PASSED++))
    else
        echo -e "${YELLOW}WARN${NC} - No se encontraron outputs"
    fi
    cd - > /dev/null
fi
echo ""

# Cheatsheet generado
echo "Verificando cheatsheet"
echo "----------------------"
validate "terraform-cheatsheet.md generado" "test -f $PROJECT_DIR/terraform-cheatsheet.md"

if [ -f "$PROJECT_DIR/terraform-cheatsheet.md" ]; then
    if grep -q "terraform plan" "$PROJECT_DIR/terraform-cheatsheet.md"; then
        echo -e "${GREEN}PASS${NC} - Cheatsheet contiene comandos CLI"
        ((PASSED++))
    else
        echo -e "${YELLOW}WARN${NC} - Cheatsheet no contiene los comandos esperados"
    fi
fi
echo ""

# Workspaces
echo "Verificando workspaces"
echo "----------------------"
cd "$PROJECT_DIR" 2>/dev/null
WORKSPACE_COUNT=$(terraform workspace list 2>/dev/null | wc -l | tr -d ' ')
if [ "$WORKSPACE_COUNT" -ge 2 ]; then
    echo -e "${GREEN}PASS${NC} - $WORKSPACE_COUNT workspaces encontrados (al menos uno adicional a default)"
    ((PASSED++))
else
    echo -e "${YELLOW}WARN${NC} - Solo el workspace default encontrado (crea uno con: terraform workspace new staging)"
fi

CURRENT_WS=$(terraform workspace show 2>/dev/null)
if [ -n "$CURRENT_WS" ]; then
    echo -e "${GREEN}PASS${NC} - Workspace actual: $CURRENT_WS"
    ((PASSED++))
fi
cd - > /dev/null 2>&1
echo ""

# Terraform validate
echo "Verificando validate"
echo "--------------------"
if [ -f "$PROJECT_DIR/main.tf" ]; then
    cd "$PROJECT_DIR"
    if terraform validate > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC} - terraform validate exitoso"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - terraform validate fallo"
        ((FAILED++))
    fi
    cd - > /dev/null
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
    echo "  - terraform validate y fmt"
    echo "  - Plan guardado con -out y apply deterministico"
    echo "  - Inspeccion de state con state list y state show"
    echo "  - Workspaces para multiples ambientes"
    echo "  - Variables TF_VAR_* y TF_LOG"
    echo ""
    echo "Siguiente: Modulo 3 - Core Workflow"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO${NC}"
    echo ""
    echo "Pasos pendientes:"
    echo "  1. Crear el directorio: mkdir lab4-cli"
    echo "  2. Crear main.tf con variables y outputs"
    echo "  3. Ejecutar: terraform init"
    echo "  4. Ejecutar: terraform validate"
    echo "  5. Ejecutar: terraform fmt -diff"
    echo "  6. Ejecutar: terraform plan -out=tfplan"
    echo "  7. Ejecutar: terraform apply tfplan"
    echo "  8. Crear workspace: terraform workspace new staging"
    exit 1
fi

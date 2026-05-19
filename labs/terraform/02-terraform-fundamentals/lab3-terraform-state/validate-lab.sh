#!/bin/bash

echo "Validando Lab 3: Terraform State"
echo "================================="
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
if [ -d "lab3-state" ]; then
    PROJECT_DIR="lab3-state"
else
    echo -e "${YELLOW}Buscando directorio del proyecto...${NC}"
    PROJECT_DIR=$(find . -maxdepth 2 -type d \( -name "*lab3*state*" -o -name "*state*" \) 2>/dev/null | grep -v ".terraform" | head -1)
fi

if [ -z "$PROJECT_DIR" ]; then
    echo -e "${RED}No se encontro el directorio del proyecto${NC}"
    echo "Crea el directorio 'lab3-state' y completa el lab"
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

# Contenido de main.tf
echo "Verificando recursos declarados"
echo "--------------------------------"
if [ -f "$PROJECT_DIR/main.tf" ]; then
    if grep -q "random_pet" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}PASS${NC} - Recurso random_pet encontrado"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - Recurso random_pet no encontrado"
        ((FAILED++))
    fi

    if grep -q "random_password" "$PROJECT_DIR/main.tf"; then
        echo -e "${GREEN}PASS${NC} - Recurso random_password encontrado"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - Recurso random_password no encontrado"
        ((FAILED++))
    fi

    RESOURCE_COUNT=$(grep -c "^resource" "$PROJECT_DIR/main.tf" 2>/dev/null || echo 0)
    if [ "$RESOURCE_COUNT" -ge 4 ]; then
        echo -e "${GREEN}PASS${NC} - $RESOURCE_COUNT recursos declarados"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - Solo $RESOURCE_COUNT recursos (se esperan al menos 4)"
        ((FAILED++))
    fi
else
    echo -e "${RED}FAIL${NC} - main.tf no existe"
    ((FAILED+=3))
fi
echo ""

# State file
echo "Verificando state"
echo "-----------------"
validate "State file existe" "test -f $PROJECT_DIR/terraform.tfstate"

if [ -f "$PROJECT_DIR/terraform.tfstate" ]; then
    cd "$PROJECT_DIR"

    RESOURCES=$(terraform state list 2>/dev/null | wc -l | tr -d ' ')
    if [ "$RESOURCES" -ge 4 ]; then
        echo -e "${GREEN}PASS${NC} - $RESOURCES recursos en el state"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - Solo $RESOURCES recursos en el state (se esperan al menos 4)"
        ((FAILED++))
    fi

    if jq -e '.serial' terraform.tfstate > /dev/null 2>&1; then
        SERIAL=$(jq '.serial' terraform.tfstate)
        echo -e "${GREEN}PASS${NC} - State serial: $SERIAL"
        ((PASSED++))
    else
        echo -e "${YELLOW}WARN${NC} - No se pudo leer el serial (jq puede no estar instalado)"
    fi

    if jq -e '.lineage' terraform.tfstate > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC} - Lineage presente en el state"
        ((PASSED++))
    else
        echo -e "${YELLOW}WARN${NC} - No se pudo leer el lineage (jq puede no estar instalado)"
    fi

    cd - > /dev/null
fi
echo ""

# Backup del state
echo "Verificando backup"
echo "------------------"
if [ -f "$PROJECT_DIR/terraform.tfstate.backup" ]; then
    echo -e "${GREEN}PASS${NC} - Backup del state existe (apply ejecutado mas de una vez)"
    ((PASSED++))
else
    echo -e "${YELLOW}WARN${NC} - Backup no existe (ejecuta apply al menos dos veces para generarlo)"
fi
echo ""

# Archivos generados
echo "Verificando archivos generados"
echo "------------------------------"
validate "config/server.conf existe" "test -f $PROJECT_DIR/config/server.conf"
validate "state-guide.md existe" "test -f $PROJECT_DIR/state-guide.md"
echo ""

# Outputs
echo "Verificando outputs"
echo "-------------------"
if [ -f "$PROJECT_DIR/terraform.tfstate" ]; then
    cd "$PROJECT_DIR"
    OUTPUT_COUNT=$(terraform output 2>/dev/null | grep -c "=" || echo 0)
    if [ "$OUTPUT_COUNT" -ge 2 ]; then
        echo -e "${GREEN}PASS${NC} - $OUTPUT_COUNT outputs disponibles"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} - Pocos outputs ($OUTPUT_COUNT, se esperan al menos 2)"
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
    echo "  - Estructura del state file (version, serial, lineage)"
    echo "  - Comandos terraform state list, show, terraform show"
    echo "  - Drift detection con terraform plan"
    echo "  - Backup automatico del state"
    echo "  - Secretos en el state y necesidad de remote state"
    echo ""
    echo "Siguiente: Lab 4 - CLI Avanzado"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO${NC}"
    echo ""
    echo "Pasos pendientes:"
    echo "  1. Crear el directorio: mkdir lab3-state"
    echo "  2. Crear main.tf con recursos random y local_file"
    echo "  3. Ejecutar: terraform init"
    echo "  4. Ejecutar: terraform apply -auto-approve"
    echo "  5. Explorar: terraform state list"
    echo "  6. Explorar: terraform state show random_pet.server_name"
    exit 1
fi

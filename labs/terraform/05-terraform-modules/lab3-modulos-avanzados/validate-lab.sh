#!/bin/bash
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
PASSED=0; FAILED=0

PROJECT_DIR="${1:-/root/lab}"

validate() {
    echo -n "  $1... "
    if eval "$2" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"; ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} — $3"; ((FAILED++))
    fi
}

echo -e "${YELLOW}Validando Lab 3: Modulos Avanzados${NC}"
echo "================================================"

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "Modulo modules/servidor/ existe" \
    "[ -d '$PROJECT_DIR/modules/servidor' ]" \
    "Crea el modulo en modules/servidor/"

validate "Modulo servidor tiene main.tf" \
    "[ -f '$PROJECT_DIR/modules/servidor/main.tf' ]" \
    "Crea modules/servidor/main.tf"

validate "Modulo servidor tiene variables.tf" \
    "[ -f '$PROJECT_DIR/modules/servidor/variables.tf' ]" \
    "Crea modules/servidor/variables.tf"

validate "Modulo servidor tiene outputs.tf" \
    "[ -f '$PROJECT_DIR/modules/servidor/outputs.tf' ]" \
    "Crea modules/servidor/outputs.tf"

validate "Modulo usa for_each" \
    "grep -rq 'for_each' '$PROJECT_DIR/modules/servidor/' --include='*.tf'" \
    "El modulo debe usar for_each para crear recursos por servidor"

validate "Modulo tiene bloque validation" \
    "grep -rq 'validation' '$PROJECT_DIR/modules/servidor/' --include='*.tf'" \
    "Agrega un bloque validation en variables.tf del modulo"

validate "Terraform inicializado" \
    "test -d '$PROJECT_DIR/.terraform' || test -f '$PROJECT_DIR/terraform.tfstate'" \
    "Ejecuta: terraform init"

validate "Estado aplicado (terraform.tfstate)" \
    "[ -f '$PROJECT_DIR/terraform.tfstate' ]" \
    "Ejecuta: terraform apply -auto-approve"

validate "Multiples recursos del modulo en estado" \
    "terraform -chdir='$PROJECT_DIR' state list 2>/dev/null | grep -c 'module\.' | grep -qE '^[2-9]|^[0-9]{2}'" \
    "for_each debe crear multiples recursos bajo module.infra"

validate "Archivos de configuracion generados" \
    "find '$PROJECT_DIR/modules/servidor/output' -name '*.conf' 2>/dev/null | grep -q ." \
    "El modulo debe generar archivos .conf por servidor"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO! Badge: Terraform Advanced Modules${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "/root/.badge-tf-m5-lab3"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

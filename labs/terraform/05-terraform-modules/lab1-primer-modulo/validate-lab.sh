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

echo -e "${YELLOW}Validando Lab 1: Tu Primer Modulo${NC}"
echo "================================================"

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "Directorio modules/ existe" \
    "[ -d '$PROJECT_DIR/modules' ]" \
    "Crea el directorio modules/ con tu modulo"

validate "Modulo web-server existe" \
    "[ -d '$PROJECT_DIR/modules/web-server' ]" \
    "Crea el directorio modules/web-server/"

validate "Modulo tiene main.tf" \
    "[ -f '$PROJECT_DIR/modules/web-server/main.tf' ]" \
    "El modulo debe tener un main.tf"

validate "Modulo tiene variables.tf" \
    "[ -f '$PROJECT_DIR/modules/web-server/variables.tf' ]" \
    "Crea variables.tf dentro del modulo"

validate "Modulo tiene outputs.tf" \
    "[ -f '$PROJECT_DIR/modules/web-server/outputs.tf' ]" \
    "Crea outputs.tf dentro del modulo"

validate "main.tf raiz usa bloque module" \
    "grep -q 'module \"' '$PROJECT_DIR/main.tf'" \
    "Agrega: module \"nombre\" { source = \"./modules/...\" }"

validate "Terraform inicializado" \
    "test -d '$PROJECT_DIR/.terraform' || test -f '$PROJECT_DIR/terraform.tfstate'" \
    "Ejecuta: terraform init"

validate "Estado aplicado (terraform.tfstate)" \
    "[ -f '$PROJECT_DIR/terraform.tfstate' ]" \
    "Ejecuta: terraform apply -auto-approve"

validate "Estado contiene recursos del modulo" \
    "terraform -chdir='$PROJECT_DIR' state list 2>/dev/null | grep -q 'module\.'" \
    "El apply debe crear recursos via el modulo"

validate "Al menos un output definido en el modulo" \
    "grep -rq '^output ' '$PROJECT_DIR/modules/' --include='*.tf'" \
    "Define al menos un output en el modulo (outputs.tf)"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO! Badge: Terraform Modules Basico${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "/root/.badge-tf-m5-lab1"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

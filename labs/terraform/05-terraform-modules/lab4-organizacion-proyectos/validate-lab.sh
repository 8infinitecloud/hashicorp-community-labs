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

echo -e "${YELLOW}Validando Lab 4: Organizacion de Proyectos${NC}"
echo "================================================"

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "Modulo modules/red/ existe" \
    "[ -d '$PROJECT_DIR/modules/red' ]" \
    "Crea el modulo de red en modules/red/"

validate "Modulo modules/aplicacion/ existe" \
    "[ -d '$PROJECT_DIR/modules/aplicacion' ]" \
    "Crea el modulo de aplicacion en modules/aplicacion/"

validate "Modulo red tiene main.tf" \
    "[ -f '$PROJECT_DIR/modules/red/main.tf' ]" \
    "Crea modules/red/main.tf"

validate "Modulo aplicacion tiene main.tf" \
    "[ -f '$PROJECT_DIR/modules/aplicacion/main.tf' ]" \
    "Crea modules/aplicacion/main.tf"

validate "Entorno dev/ existe con main.tf" \
    "[ -f '$PROJECT_DIR/entornos/dev/main.tf' ]" \
    "Crea entornos/dev/main.tf con la configuracion del entorno de desarrollo"

validate "Entorno prod/ existe con main.tf" \
    "[ -f '$PROJECT_DIR/entornos/prod/main.tf' ]" \
    "Crea entornos/prod/main.tf con la configuracion del entorno de produccion"

validate "Dev inicializado" \
    "test -d '$PROJECT_DIR/entornos/dev/.terraform' || test -f '$PROJECT_DIR/entornos/dev/terraform.tfstate'" \
    "Ejecuta: terraform -chdir=entornos/dev init"

validate "Dev aplicado (terraform.tfstate)" \
    "[ -f '$PROJECT_DIR/entornos/dev/terraform.tfstate' ]" \
    "Ejecuta: terraform -chdir=entornos/dev apply -auto-approve"

validate "Prod inicializado" \
    "test -d '$PROJECT_DIR/entornos/prod/.terraform' || test -f '$PROJECT_DIR/entornos/prod/terraform.tfstate'" \
    "Ejecuta: terraform -chdir=entornos/prod init"

validate "Prod aplicado (terraform.tfstate)" \
    "[ -f '$PROJECT_DIR/entornos/prod/terraform.tfstate' ]" \
    "Ejecuta: terraform -chdir=entornos/prod apply -auto-approve"

validate "Archivos de red generados para ambos entornos" \
    "find '$PROJECT_DIR/modules/red/output' -name 'vpc-dev*' | grep -q . && find '$PROJECT_DIR/modules/red/output' -name 'vpc-prod*' | grep -q ." \
    "Aplica ambos entornos para generar los archivos de red"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO! Badge: Terraform Project Organization${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "/root/.badge-tf-m5-lab4"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

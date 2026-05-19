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

echo -e "${YELLOW}Validando Lab 2: Modulos del Registry${NC}"
echo "================================================"

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "Lock file generado (.terraform.lock.hcl)" \
    "[ -f '$PROJECT_DIR/.terraform.lock.hcl' ]" \
    "Ejecuta: terraform init (genera el lock file automaticamente)"

validate "Lock file contiene hashicorp/random" \
    "grep -q 'hashicorp/random' '$PROJECT_DIR/.terraform.lock.hcl'" \
    "Verifica que required_providers incluye hashicorp/random"

validate "Lock file contiene hashicorp/local" \
    "grep -q 'hashicorp/local' '$PROJECT_DIR/.terraform.lock.hcl'" \
    "Verifica que required_providers incluye hashicorp/local"

validate "Terraform inicializado" \
    "test -d '$PROJECT_DIR/.terraform' || test -f '$PROJECT_DIR/terraform.tfstate'" \
    "Ejecuta: terraform init"

validate "Estado aplicado (terraform.tfstate)" \
    "[ -f '$PROJECT_DIR/terraform.tfstate' ]" \
    "Ejecuta: terraform apply -auto-approve"

validate "Estado contiene random_id" \
    "terraform -chdir='$PROJECT_DIR' state list 2>/dev/null | grep -q 'random_id'" \
    "El apply debe crear un recurso random_id"

validate "Modulo local modules/identificador/ existe" \
    "[ -d '$PROJECT_DIR/modules/identificador' ]" \
    "Crea el directorio modules/identificador/ con su main.tf"

validate "Modulo identificador tiene main.tf" \
    "[ -f '$PROJECT_DIR/modules/identificador/main.tf' ]" \
    "Crea modules/identificador/main.tf con el modulo"

validate "main.tf usa el modulo dos veces" \
    "grep -c 'source.*modules/identificador' '$PROJECT_DIR/main.tf' | grep -qE '^[2-9]'" \
    "Usa el modulo al menos dos veces con parametros distintos"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO! Badge: Terraform Registry Expert${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "/root/.badge-tf-m5-lab2"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

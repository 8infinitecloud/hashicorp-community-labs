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

echo -e "${YELLOW}Validando Lab 1: Resources con Dependencias y Lifecycle${NC}"
echo "========================================================"

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "main.tf existe" \
    "[ -f '$PROJECT_DIR/main.tf' ]" \
    "Crea /root/lab/main.tf con los recursos base"

validate "depends-on.tf existe" \
    "[ -f '$PROJECT_DIR/depends-on.tf' ]" \
    "Crea /root/lab/depends-on.tf con depends_on"

validate "lifecycle.tf existe" \
    "[ -f '$PROJECT_DIR/lifecycle.tf' ]" \
    "Crea /root/lab/lifecycle.tf con las reglas de lifecycle"

validate "Dependencia implicita definida (referencia entre recursos)" \
    "grep -q 'local_file\.' '$PROJECT_DIR/main.tf'" \
    "Usa referencias entre recursos en main.tf"

validate "depends_on definido" \
    "grep -q 'depends_on' '$PROJECT_DIR/depends-on.tf'" \
    "Agrega depends_on en depends-on.tf"

validate "create_before_destroy definido" \
    "grep -q 'create_before_destroy' '$PROJECT_DIR/lifecycle.tf'" \
    "Agrega create_before_destroy en lifecycle.tf"

validate "ignore_changes definido" \
    "grep -q 'ignore_changes' '$PROJECT_DIR/lifecycle.tf'" \
    "Agrega ignore_changes en lifecycle.tf"

validate "replace_triggered_by definido" \
    "grep -q 'replace_triggered_by' '$PROJECT_DIR/lifecycle.tf'" \
    "Agrega replace_triggered_by en lifecycle.tf"

validate "Terraform inicializado" \
    "test -d '$PROJECT_DIR/.terraform' || test -f '$PROJECT_DIR/terraform.tfstate'" \
    "Ejecuta: terraform -chdir=/root/lab init"

validate "Configuracion valida" \
    "terraform -chdir='$PROJECT_DIR' validate" \
    "Ejecuta: terraform -chdir=/root/lab validate"

validate "Estado aplicado (terraform.tfstate)" \
    "[ -f '$PROJECT_DIR/terraform.tfstate' ]" \
    "Ejecuta: terraform -chdir=/root/lab apply -auto-approve"

validate "Recursos creados en estado" \
    "terraform -chdir='$PROJECT_DIR' state list 2>/dev/null | grep -q 'local_file\.'" \
    "El apply debe crear recursos local_file en el estado"

echo ""
echo "========================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO! Badge: Terraform Dependencies Master${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "/root/.badge-tf-m4-lab1"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

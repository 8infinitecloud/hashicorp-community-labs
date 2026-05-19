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

echo -e "${YELLOW}Validando Lab 3: Variables con Validacion${NC}"
echo "========================================================"

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "main.tf existe" \
    "[ -f '$PROJECT_DIR/main.tf' ]" \
    "Crea /root/lab/main.tf con los recursos que usan las variables"

validate "variables.tf existe" \
    "[ -f '$PROJECT_DIR/variables.tf' ]" \
    "Crea /root/lab/variables.tf con variables de tipos primitivos"

validate "complex-variables.tf existe" \
    "[ -f '$PROJECT_DIR/complex-variables.tf' ]" \
    "Crea /root/lab/complex-variables.tf con list, map y object"

validate "complex-resources.tf existe" \
    "[ -f '$PROJECT_DIR/complex-resources.tf' ]" \
    "Crea /root/lab/complex-resources.tf con recursos que usan las variables complejas"

validate "terraform.tfvars existe" \
    "[ -f '$PROJECT_DIR/terraform.tfvars' ]" \
    "Crea /root/lab/terraform.tfvars con valores de variables"

validate "prod.tfvars existe" \
    "[ -f '$PROJECT_DIR/prod.tfvars' ]" \
    "Crea /root/lab/prod.tfvars con valores de produccion"

validate "Bloque validation definido en variables.tf" \
    "grep -q 'validation {' '$PROJECT_DIR/variables.tf'" \
    "Agrega bloques validation con condition y error_message en variables.tf"

validate "error_message definido" \
    "grep -q 'error_message' '$PROJECT_DIR/variables.tf'" \
    "Agrega error_message dentro de cada bloque validation"

validate "Variable sensitive definida" \
    "grep -q 'sensitive.*=.*true' '$PROJECT_DIR/variables.tf'" \
    "Marca al menos una variable como sensitive = true"

validate "Tipo string definido" \
    "grep -q 'type.*=.*string' '$PROJECT_DIR/variables.tf'" \
    "Define al menos una variable de tipo string"

validate "Tipo number definido" \
    "grep -q 'type.*=.*number' '$PROJECT_DIR/variables.tf'" \
    "Define al menos una variable de tipo number"

validate "Tipo bool definido" \
    "grep -q 'type.*=.*bool' '$PROJECT_DIR/variables.tf'" \
    "Define al menos una variable de tipo bool"

validate "Tipo list definido en complex-variables.tf" \
    "grep -q 'type.*=.*list' '$PROJECT_DIR/complex-variables.tf'" \
    "Define una variable de tipo list en complex-variables.tf"

validate "Tipo map definido en complex-variables.tf" \
    "grep -q 'type.*=.*map' '$PROJECT_DIR/complex-variables.tf'" \
    "Define una variable de tipo map en complex-variables.tf"

validate "Tipo object definido en complex-variables.tf" \
    "grep -q 'type.*=.*object' '$PROJECT_DIR/complex-variables.tf'" \
    "Define una variable de tipo object en complex-variables.tf"

validate "Al menos un output definido" \
    "grep -rq '^output ' '$PROJECT_DIR/'*.tf" \
    "Define al menos un output en algun .tf del proyecto"

validate "Terraform inicializado" \
    "test -d '$PROJECT_DIR/.terraform' || test -f '$PROJECT_DIR/terraform.tfstate'" \
    "Ejecuta: terraform -chdir=/root/lab init"

validate "Configuracion valida" \
    "terraform -chdir='$PROJECT_DIR' validate" \
    "Ejecuta: terraform -chdir=/root/lab validate"

validate "Estado aplicado (terraform.tfstate)" \
    "[ -f '$PROJECT_DIR/terraform.tfstate' ]" \
    "Ejecuta: terraform -chdir=/root/lab apply -auto-approve"

echo ""
echo "========================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO! Badge: Terraform Variables Master${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "/root/.badge-tf-m4-lab3"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

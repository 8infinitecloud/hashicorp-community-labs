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

echo -e "${YELLOW}Validando Lab 4: Outputs y Funciones${NC}"
echo "========================================================"

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "main.tf existe" \
    "[ -f '$PROJECT_DIR/main.tf' ]" \
    "Crea /root/lab/main.tf con el bloque terraform y required_providers"

validate "string-functions.tf existe" \
    "[ -f '$PROJECT_DIR/string-functions.tf' ]" \
    "Crea /root/lab/string-functions.tf con funciones de cadena"

validate "collection-functions.tf existe" \
    "[ -f '$PROJECT_DIR/collection-functions.tf' ]" \
    "Crea /root/lab/collection-functions.tf con funciones de coleccion"

validate "numeric-functions.tf existe" \
    "[ -f '$PROJECT_DIR/numeric-functions.tf' ]" \
    "Crea /root/lab/numeric-functions.tf con funciones numericas y de fecha"

validate "network-functions.tf existe" \
    "[ -f '$PROJECT_DIR/network-functions.tf' ]" \
    "Crea /root/lab/network-functions.tf con funciones cidr*"

validate "for-expressions.tf existe" \
    "[ -f '$PROJECT_DIR/for-expressions.tf' ]" \
    "Crea /root/lab/for-expressions.tf con expresiones for"

validate "advanced-outputs.tf existe" \
    "[ -f '$PROJECT_DIR/advanced-outputs.tf' ]" \
    "Crea /root/lab/advanced-outputs.tf con outputs tipados y sensibles"

validate "Funciones de cadena usadas (upper o lower o join)" \
    "grep -qE 'upper|lower|join' '$PROJECT_DIR/string-functions.tf'" \
    "Usa upper(), lower() o join() en string-functions.tf"

validate "Funciones de coleccion usadas (distinct o merge o flatten)" \
    "grep -qE 'distinct|merge|flatten' '$PROJECT_DIR/collection-functions.tf'" \
    "Usa distinct(), merge() o flatten() en collection-functions.tf"

validate "Funciones de red usadas (cidrsubnet o cidrhost)" \
    "grep -qE 'cidrsubnet|cidrhost' '$PROJECT_DIR/network-functions.tf'" \
    "Usa cidrsubnet() o cidrhost() en network-functions.tf"

validate "For expression definida" \
    "grep -q 'for ' '$PROJECT_DIR/for-expressions.tf'" \
    "Usa al menos una expresion 'for' en for-expressions.tf"

validate "locals definidos" \
    "grep -rq '^locals {' '$PROJECT_DIR/'*.tf" \
    "Define al menos un bloque locals en algun .tf"

validate "output sensible definido" \
    "grep -rq 'sensitive.*=.*true' '$PROJECT_DIR/'*.tf" \
    "Marca al menos un output o variable como sensitive = true"

validate "Al menos un output definido" \
    "grep -rq '^output ' '$PROJECT_DIR/'*.tf" \
    "Define al menos un output en algun .tf"

validate "Terraform inicializado" \
    "test -d '$PROJECT_DIR/.terraform' || test -f '$PROJECT_DIR/terraform.tfstate'" \
    "Ejecuta: terraform -chdir=/root/lab init"

validate "Configuracion valida" \
    "terraform -chdir='$PROJECT_DIR' validate" \
    "Ejecuta: terraform -chdir=/root/lab validate"

validate "Estado aplicado (terraform.tfstate)" \
    "[ -f '$PROJECT_DIR/terraform.tfstate' ]" \
    "Ejecuta: terraform -chdir=/root/lab apply -auto-approve"

validate "Recursos local_file en el estado" \
    "terraform -chdir='$PROJECT_DIR' state list 2>/dev/null | grep -q 'local_file\.'" \
    "El apply debe crear recursos local_file en el estado"

validate "Archivo string-results.txt generado" \
    "[ -f '$PROJECT_DIR/output/string-results.txt' ]" \
    "El apply debe crear /root/lab/output/string-results.txt"

validate "Archivo network-results.txt generado" \
    "[ -f '$PROJECT_DIR/output/network-results.txt' ]" \
    "El apply debe crear /root/lab/output/network-results.txt"

echo ""
echo "========================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO! Badge: Terraform Functions Expert${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "/root/.badge-tf-m4-lab4"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

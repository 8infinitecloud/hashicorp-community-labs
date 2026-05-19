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

echo -e "${YELLOW}Validando Lab 2: Data Sources${NC}"
echo "========================================================"

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "main.tf existe" \
    "[ -f '$PROJECT_DIR/main.tf' ]" \
    "Crea /root/lab/main.tf con el bloque terraform y required_providers"

validate "resources.tf existe" \
    "[ -f '$PROJECT_DIR/resources.tf' ]" \
    "Crea /root/lab/resources.tf con los recursos local_file de origen"

validate "data-sources.tf existe" \
    "[ -f '$PROJECT_DIR/data-sources.tf' ]" \
    "Crea /root/lab/data-sources.tf con los bloques data"

validate "derived.tf existe" \
    "[ -f '$PROJECT_DIR/derived.tf' ]" \
    "Crea /root/lab/derived.tf con recursos que consumen los data sources"

validate "outputs.tf existe" \
    "[ -f '$PROJECT_DIR/outputs.tf' ]" \
    "Crea /root/lab/outputs.tf con al menos un output"

validate "Bloque data definido" \
    "grep -q '^data \"' '$PROJECT_DIR/data-sources.tf'" \
    "Agrega al menos un bloque: data \"local_file\" \"nombre\" { ... }"

validate "Data source local_file usado" \
    "grep -q 'data.local_file\.' '$PROJECT_DIR/derived.tf' || grep -q 'jsondecode' '$PROJECT_DIR/data-sources.tf'" \
    "Referencia el data source en derived.tf o usa jsondecode en data-sources.tf"

validate "jsondecode usado para parsear JSON" \
    "grep -rq 'jsondecode' '$PROJECT_DIR/'*.tf" \
    "Usa jsondecode() para convertir el contenido JSON leido en un objeto HCL"

validate "Al menos un output definido" \
    "grep -q '^output ' '$PROJECT_DIR/outputs.tf'" \
    "Define al menos un output en outputs.tf"

validate "Terraform inicializado" \
    "test -d '$PROJECT_DIR/.terraform' || test -f '$PROJECT_DIR/terraform.tfstate'" \
    "Ejecuta: terraform -chdir=/root/lab init"

validate "Configuracion valida" \
    "terraform -chdir='$PROJECT_DIR' validate" \
    "Ejecuta: terraform -chdir=/root/lab validate"

validate "Estado aplicado (terraform.tfstate)" \
    "[ -f '$PROJECT_DIR/terraform.tfstate' ]" \
    "Ejecuta: terraform -chdir=/root/lab apply -auto-approve"

validate "Data source registrado en el estado" \
    "terraform -chdir='$PROJECT_DIR' state list 2>/dev/null | grep -q '^data\.'" \
    "El apply debe registrar data sources en el estado"

validate "Archivo app-info.txt generado" \
    "[ -f '$PROJECT_DIR/output/app-info.txt' ]" \
    "El recurso derived debe crear /root/lab/output/app-info.txt"

echo ""
echo "========================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO! Badge: Terraform Data Sources Expert${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "/root/.badge-tf-m4-lab2"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

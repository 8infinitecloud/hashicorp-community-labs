#!/bin/bash
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
PASSED=0; FAILED=0
PROJECT_DIR="/root/lab"

validate() {
    echo -n "  $1... "
    if eval "$2" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"; ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} — $3"; ((FAILED++))
    fi
}

echo -e "${YELLOW}Validando Lab 1: HCP Terraform Setup${NC}"
echo "================================================"
echo ""

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "versions.tf existe" \
    "test -f $PROJECT_DIR/versions.tf" \
    "Crea versions.tf con el bloque terraform {} y provider local"

validate "versions.tf tiene bloque cloud comentado o activo" \
    "grep -q 'cloud' $PROJECT_DIR/versions.tf" \
    "versions.tf debe mostrar el bloque cloud {} (activo o comentado)"

validate "versions.tf referencia provider local" \
    "grep -q 'hashicorp/local' $PROJECT_DIR/versions.tf" \
    "versions.tf debe requerir el provider hashicorp/local"

validate "main.tf existe con recurso local_file" \
    "test -f $PROJECT_DIR/main.tf && grep -q 'local_file' $PROJECT_DIR/main.tf" \
    "Crea main.tf con al menos un recurso local_file"

validate "main.tf tiene variable entorno" \
    "grep -q 'variable' $PROJECT_DIR/main.tf" \
    "main.tf debe declarar al menos una variable"

validate "Terraform inicializado" \
    "test -d $PROJECT_DIR/.terraform || test -f $PROJECT_DIR/terraform.tfstate" \
    "Ejecuta: terraform init"

validate "State o archivo generado existe" \
    "test -f $PROJECT_DIR/terraform.tfstate || test -f $PROJECT_DIR/info-hcp.txt" \
    "Ejecuta: terraform apply -auto-approve"

validate "hcp-setup.md documentacion creada" \
    "test -f $PROJECT_DIR/hcp-setup.md" \
    "Crea hcp-setup.md documentando los conceptos de HCP Terraform"

validate "hcp-setup.md menciona modos de ejecucion" \
    "grep -qi 'remote\|local\|agent' $PROJECT_DIR/hcp-setup.md" \
    "hcp-setup.md debe documentar los modos Remote, Local y Agent"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 8 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO — Badge: HCP Terraform Setup${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m8-lab1"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

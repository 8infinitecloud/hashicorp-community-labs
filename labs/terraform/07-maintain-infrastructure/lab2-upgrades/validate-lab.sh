#!/bin/bash
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
PASSED=0; FAILED=0

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

validate() {
    echo -n "  $1... "
    if eval "$2" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"; ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} — $3"; ((FAILED++))
    fi
}

echo -e "${YELLOW}Validando Lab 2: Upgrades y Versiones${NC}"
echo "================================================"

validate "Terraform inicializado" \
    "test -d $PROJECT_DIR/.terraform || test -f $PROJECT_DIR/terraform.tfstate" \
    "Ejecuta: terraform init"

validate "versions.tf existe con required_version" \
    "test -f $PROJECT_DIR/versions.tf && grep -q 'required_version' $PROJECT_DIR/versions.tf" \
    "Crea versions.tf con: required_version = \">= 1.0, < 2.0\""

validate "required_providers con version constraints" \
    "grep -q 'required_providers' $PROJECT_DIR/versions.tf && grep -q 'version' $PROJECT_DIR/versions.tf" \
    "Define required_providers con version constraints en versions.tf"

validate "Lock file existe (.terraform.lock.hcl)" \
    "test -f $PROJECT_DIR/.terraform.lock.hcl" \
    "El lock file se genera automaticamente con terraform init"

validate "Lock file tiene hashes de integridad (h1:)" \
    "grep -q 'h1:' $PROJECT_DIR/.terraform.lock.hcl" \
    "El lock file debe contener hashes h1: — ejecuta terraform init"

validate "terraform validate sin errores" \
    "terraform -chdir=$PROJECT_DIR validate 2>/dev/null" \
    "Corrige errores de sintaxis: ejecuta terraform validate para ver detalles"

validate "Estado aplicado (terraform.tfstate)" \
    "test -f $PROJECT_DIR/terraform.tfstate" \
    "Ejecuta: terraform apply -auto-approve"

validate "Archivo notas-terraform-versions.txt creado" \
    "test -f $PROJECT_DIR/notas-terraform-versions.txt" \
    "Crea notas-terraform-versions.txt documentando el proceso de upgrade"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ "$FAILED" -eq 0 ] && [ "$PASSED" -ge 6 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO — Badge: Terraform Upgrades Expert${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$PROJECT_DIR/../../../.badge-tf-m7-lab2"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

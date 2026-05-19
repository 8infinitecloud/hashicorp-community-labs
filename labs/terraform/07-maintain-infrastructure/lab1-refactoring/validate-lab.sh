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

echo -e "${YELLOW}Validando Lab 1: Refactoring con moved blocks${NC}"
echo "================================================"

validate "Terraform inicializado" \
    "test -d $PROJECT_DIR/.terraform || test -f $PROJECT_DIR/terraform.tfstate" \
    "Ejecuta: terraform init"

validate "Estado aplicado (terraform.tfstate)" \
    "test -f $PROJECT_DIR/terraform.tfstate" \
    "Ejecuta: terraform apply -auto-approve"

validate "State NO contiene nombres genericos (f1/f2/f3)" \
    "! terraform -chdir=$PROJECT_DIR state list 2>/dev/null | grep -qE '\.(f[0-9]+)$'" \
    "Renombra los recursos usando moved blocks (f1 -> config, f2 -> credenciales, f3 -> inventario)"

validate "Modulo modulos/secretos extraido" \
    "test -f $PROJECT_DIR/modulos/secretos/main.tf" \
    "Crea el modulo en modulos/secretos/main.tf"

validate "State contiene recurso en el modulo secretos" \
    "terraform -chdir=$PROJECT_DIR state list 2>/dev/null | grep -q 'module.secretos'" \
    "Mueve local_file.credenciales al modulo con: moved { from = local_file.credenciales to = module.secretos.local_file.archivo }"

validate "Archivos fisicos existen en output/" \
    "test -f $PROJECT_DIR/output/config.json && test -f $PROJECT_DIR/output/secretos.txt && test -f $PROJECT_DIR/output/inventario.ini" \
    "Los archivos gestionados deben existir en output/"

validate "Plan sin cambios (refactoring sin destruccion)" \
    "terraform -chdir=$PROJECT_DIR plan -detailed-exitcode 2>/dev/null; test \$? -eq 0" \
    "El refactoring no debe requerir recrear recursos — verifica los moved blocks"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ "$FAILED" -eq 0 ] && [ "$PASSED" -ge 5 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO — Badge: Terraform Refactoring${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$PROJECT_DIR/../../../.badge-tf-m7-lab1"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

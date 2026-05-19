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

echo -e "${YELLOW}Validando Lab 3: Drift Detection${NC}"
echo "================================================"

validate "Terraform inicializado" \
    "test -d $PROJECT_DIR/.terraform || test -f $PROJECT_DIR/terraform.tfstate" \
    "Ejecuta: terraform init"

validate "Estado aplicado (terraform.tfstate)" \
    "test -f $PROJECT_DIR/terraform.tfstate" \
    "Ejecuta: terraform apply -auto-approve"

validate "Archivos de configuracion existen (config/app.conf)" \
    "test -f $PROJECT_DIR/config/app.conf" \
    "Ejecuta terraform apply — debe crear config/app.conf"

validate "lifecycle ignore_changes en main.tf" \
    "grep -q 'ignore_changes' $PROJECT_DIR/main.tf" \
    "Agrega lifecycle { ignore_changes = [content] } al recurso hosts"

validate "lifecycle block presente en main.tf" \
    "grep -q 'lifecycle' $PROJECT_DIR/main.tf" \
    "Usa lifecycle blocks para controlar el comportamiento ante drift"

validate "Archivo opciones-reconciliacion.md creado" \
    "test -f $PROJECT_DIR/opciones-reconciliacion.md" \
    "Crea opciones-reconciliacion.md con las tres opciones de reconciliacion"

validate "opciones-reconciliacion.md menciona terraform apply e ignore" \
    "grep -qi 'terraform apply' $PROJECT_DIR/opciones-reconciliacion.md && grep -qi 'ignore' $PROJECT_DIR/opciones-reconciliacion.md" \
    "El archivo debe mencionar las opciones: apply para revertir e ignore_changes"

validate "Plan sin cambios despues de reconciliar" \
    "terraform -chdir=$PROJECT_DIR plan -detailed-exitcode 2>/dev/null; test \$? -eq 0" \
    "Reconcilia el drift ejecutando terraform apply -auto-approve"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ "$FAILED" -eq 0 ] && [ "$PASSED" -ge 5 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO — Badge: Terraform Drift Detection${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$PROJECT_DIR/../../../.badge-tf-m7-lab3"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

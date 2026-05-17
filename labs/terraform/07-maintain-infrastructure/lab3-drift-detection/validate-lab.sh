#!/bin/bash
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
PASSED=0; FAILED=0

validate() {
    echo -n "  $1... "
    if eval "$2" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"; ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC} — $3"; ((FAILED++))
    fi
}

echo -e "${YELLOW}🧪 Validando Lab 3: Drift Detection${NC}"
echo "================================================"

validate "Terraform inicializado (.terraform/)" \
    "[ -d '.terraform' ]" \
    "Ejecuta: terraform init"

validate "Estado aplicado (terraform.tfstate)" \
    "[ -f 'terraform.tfstate' ]" \
    "Ejecuta: terraform apply -auto-approve"

validate "Archivo opciones-reconciliacion.md creado" \
    "[ -f 'opciones-reconciliacion.md' ] || [ -f 'reconciliacion.md' ] || [ -f 'drift-notas.md' ]" \
    "Crea opciones-reconciliacion.md documentando las opciones para manejar drift"

validate "opciones-reconciliacion.md menciona las opciones" \
    "grep -qi 'terraform apply\|ignore\|import\|reconcil' opciones-reconciliacion.md 2>/dev/null || grep -qi 'drift\|reconcil' reconciliacion.md 2>/dev/null || grep -qi 'drift\|reconcil' drift-notas.md 2>/dev/null" \
    "El archivo debe explicar las opciones: apply, import, ignore_changes"

validate "ignore_changes en main.tf" \
    "grep -q 'ignore_changes' main.tf" \
    "Agrega lifecycle { ignore_changes = [...] } para ignorar cambios manuales"

validate "Plan muestra No changes al final" \
    "terraform plan -detailed-exitcode 2>/dev/null; [ $? -eq 0 ]" \
    "Después de reconciliar, terraform plan no debe mostrar cambios"

validate "main.tf tiene bloque lifecycle" \
    "grep -q 'lifecycle' main.tf" \
    "Usa lifecycle blocks para controlar el comportamiento ante drift"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 5 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: Terraform Drift Detection${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m7-lab3"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

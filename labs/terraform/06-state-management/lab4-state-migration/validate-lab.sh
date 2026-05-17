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

echo -e "${YELLOW}🧪 Validando Lab 4: State Migration${NC}"
echo "================================================"

validate "Terraform inicializado (.terraform/)" \
    "[ -d '.terraform' ]" \
    "Ejecuta: terraform init"

validate "Estado aplicado (terraform.tfstate)" \
    "[ -f 'terraform.tfstate' ]" \
    "Ejecuta: terraform apply -auto-approve"

validate "Estado NO tiene recursos con nombres viejos (f1/f2/f3)" \
    "! terraform state list 2>/dev/null | grep -qE '\.f[123]$'" \
    "Renombra los recursos con terraform state mv o moved blocks"

validate "Módulo archivos en el estado" \
    "terraform state list 2>/dev/null | grep -q 'module\.archivos'" \
    "El estado debe mostrar module.archivos.* después de la migración"

validate "Bloque moved en main.tf o en moves.tf" \
    "grep -rq '^moved {' . --include='*.tf'" \
    "Documenta la migración con bloques moved { from = ... to = ... }"

validate "Plan muestra No changes después de migración" \
    "terraform plan -detailed-exitcode 2>/dev/null; [ $? -eq 0 ]" \
    "Después de migrar, terraform plan no debe mostrar cambios pendientes"

validate "local_file.config en el estado (nombre nuevo)" \
    "terraform state list 2>/dev/null | grep -q 'local_file.config\|module\.archivos'" \
    "El recurso config debe estar en el estado con su nuevo nombre"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 5 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: Terraform State Migration${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m6-lab4"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

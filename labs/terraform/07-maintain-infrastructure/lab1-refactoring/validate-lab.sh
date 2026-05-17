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

echo -e "${YELLOW}🧪 Validando Lab 1: Refactoring${NC}"
echo "================================================"

validate "Terraform inicializado (.terraform/)" \
    "[ -d '.terraform' ]" \
    "Ejecuta: terraform init"

validate "Estado aplicado (terraform.tfstate)" \
    "[ -f 'terraform.tfstate' ]" \
    "Ejecuta: terraform apply -auto-approve"

validate "Estado NO tiene nombres genéricos (f1/f2/f3/archivo1)" \
    "! terraform state list 2>/dev/null | grep -qiE '\.(f[0-9]+|archivo[0-9]+)$'" \
    "Renombra los recursos a nombres descriptivos usando moved blocks"

validate "Módulo modules/secretos/ extraído" \
    "[ -d 'modules/secretos' ] || [ -d 'modules/configs' ] || [ -d 'modules/archivos' ]" \
    "Extrae recursos en un módulo reutilizable"

validate "Plan muestra No changes (refactoring sin destrucción)" \
    "terraform plan -detailed-exitcode 2>/dev/null; [ $? -eq 0 ]" \
    "El refactoring no debe requerir recrear recursos — usa moved blocks"

validate "Bloque moved o terraform state mv documentado" \
    "grep -rq '^moved {' . --include='*.tf' || [ -f 'historial-migraciones.md' ] || [ -f 'refactoring.md' ]" \
    "Documenta los cambios con moved blocks o un archivo de notas"

validate "Código tiene variables descriptivas (no hardcoded)" \
    "grep -q 'variable ' main.tf || grep -rq 'variable ' modules/ --include='*.tf'" \
    "Usa variables en lugar de valores hardcodeados"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 5 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: Terraform Refactoring${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m7-lab1"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

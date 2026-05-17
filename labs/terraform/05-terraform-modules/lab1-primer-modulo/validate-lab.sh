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

echo -e "${YELLOW}🧪 Validando Lab 1: Tu Primer Módulo${NC}"
echo "================================================"

validate "Directorio modules/ existe" \
    "[ -d 'modules' ]" \
    "Crea el directorio modules/ con tu módulo"

validate "Módulo tiene main.tf" \
    "find modules/ -name 'main.tf' | grep -q ." \
    "El módulo debe tener un main.tf"

validate "Módulo tiene variables.tf" \
    "find modules/ -name 'variables.tf' | grep -q ." \
    "Crea variables.tf dentro del módulo"

validate "Módulo tiene outputs.tf" \
    "find modules/ -name 'outputs.tf' | grep -q ." \
    "Crea outputs.tf dentro del módulo"

validate "main.tf raíz usa bloque module" \
    "grep -q 'module \"' main.tf" \
    "Agrega: module \"nombre\" { source = \"./modules/...\" }"

validate "Terraform inicializado (.terraform/)" \
    "[ -d '.terraform' ]" \
    "Ejecuta: terraform init"

validate "Estado aplicado (terraform.tfstate)" \
    "[ -f 'terraform.tfstate' ]" \
    "Ejecuta: terraform apply -auto-approve"

validate "Estado contiene recursos del módulo" \
    "terraform state list 2>/dev/null | grep -q 'module\.'" \
    "El apply debe crear recursos vía el módulo"

validate "Al menos un output definido en el módulo" \
    "grep -rq '^output ' modules/ --include='*.tf'" \
    "Define al menos un output en el módulo (outputs.tf)"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 7 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: Terraform Modules Básico${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m5-lab1"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

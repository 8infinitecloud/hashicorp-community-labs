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

echo -e "${YELLOW}🧪 Validando Lab 3: Módulos Avanzados${NC}"
echo "================================================"

validate "Módulo modules/servidor/ existe" \
    "[ -d 'modules/servidor' ]" \
    "Crea el módulo en modules/servidor/"

validate "Módulo servidor tiene main.tf" \
    "[ -f 'modules/servidor/main.tf' ]" \
    "Crea modules/servidor/main.tf"

validate "Módulo servidor tiene variables.tf" \
    "[ -f 'modules/servidor/variables.tf' ]" \
    "Crea modules/servidor/variables.tf"

validate "Módulo servidor tiene outputs.tf" \
    "[ -f 'modules/servidor/outputs.tf' ]" \
    "Crea modules/servidor/outputs.tf"

validate "main.tf usa for_each con el módulo" \
    "grep -q 'for_each' main.tf" \
    "Usa for_each en el bloque module para crear múltiples instancias"

validate "Terraform inicializado" \
    "[ -d '.terraform' ]" \
    "Ejecuta: terraform init"

validate "Estado aplicado" \
    "[ -f 'terraform.tfstate' ]" \
    "Ejecuta: terraform apply -auto-approve"

validate "Múltiples instancias del módulo en estado" \
    "terraform state list 2>/dev/null | grep -c 'module\.' | grep -qE '^[2-9]|^[0-9]{2}'" \
    "for_each debe crear múltiples instancias del módulo"

validate "Archivos de output generados" \
    "find . -name '*.txt' -newer main.tf | grep -q ." \
    "El módulo debe generar archivos de configuración"

validate "Validation block en módulo" \
    "grep -rq 'validation' modules/ --include='*.tf'" \
    "Agrega un bloque validation en las variables del módulo"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 8 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: Terraform Advanced Modules${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m5-lab3"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

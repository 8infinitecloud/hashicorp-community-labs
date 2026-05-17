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

echo -e "${YELLOW}🧪 Validando Lab 3: Sentinel Policies${NC}"
echo "================================================"
echo -e "${YELLOW}ℹ️  Sentinel local no requiere HCP Terraform Plus${NC}"
echo ""

validate "Al menos una política .sentinel escrita" \
    "find . -name '*.sentinel' | grep -q ." \
    "Crea al menos un archivo .sentinel con tu política"

validate "Política usa import tfplan/v2" \
    "grep -rq 'import.*tfplan' . --include='*.sentinel'" \
    "La política debe importar tfplan/v2: import \"tfplan/v2\" as tfplan"

validate "Política tiene regla main" \
    "grep -rq 'main = rule' . --include='*.sentinel'" \
    "Toda política Sentinel debe tener: main = rule { ... }"

validate "Directorio mocks/ existe" \
    "[ -d 'mocks' ]" \
    "Crea el directorio mocks/ con datos de prueba"

validate "Mock data JSON existe en mocks/" \
    "find mocks/ -name '*.json' | grep -q ." \
    "Crea mocks/tfplan-v2.sentinel.json con datos de prueba del plan"

validate "sentinel.json de configuración existe" \
    "[ -f 'sentinel.json' ]" \
    "Crea sentinel.json apuntando al mock: { \"mock\": { \"tfplan/v2\": \"mocks/...\" } }"

validate "sentinel.json referencia el mock correcto" \
    "grep -q 'mocks/' sentinel.json" \
    "sentinel.json debe apuntar a la ruta del archivo mock"

validate "Archivo de niveles de enforcement documentado" \
    "[ -f 'niveles-enforcement.md' ] || grep -rq 'hard-mandatory\|soft-mandatory\|advisory' . --include='*.md' --include='*.sentinel'" \
    "Documenta los niveles: hard-mandatory, soft-mandatory, advisory"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 6 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: HCP Terraform Sentinel Policies${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m8-lab3"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    echo -e "${YELLOW}💡 Prueba localmente: sentinel apply -config sentinel.json tu-politica.sentinel${NC}"
    exit 1
fi

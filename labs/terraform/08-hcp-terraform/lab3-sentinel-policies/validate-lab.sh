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

echo -e "${YELLOW}Validando Lab 3: Sentinel Policies${NC}"
echo "================================================"
echo ""

validate "Al menos una politica .sentinel escrita" \
    "find $PROJECT_DIR -maxdepth 1 -name '*.sentinel' | grep -q ." \
    "Crea al menos un archivo .sentinel con tu politica"

validate "Politica importa tfplan/v2" \
    "grep -rq 'import.*tfplan' $PROJECT_DIR --include='*.sentinel'" \
    "La politica debe importar: import \"tfplan/v2\" as tfplan"

validate "Politica tiene regla main" \
    "grep -rq 'main = rule' $PROJECT_DIR --include='*.sentinel'" \
    "Toda politica Sentinel debe terminar con: main = rule { ... }"

validate "Politica usa filter o all" \
    "grep -rq 'filter\|all ' $PROJECT_DIR --include='*.sentinel'" \
    "La politica debe usar filter para seleccionar recursos y all para evaluarlos"

validate "Directorio mocks/ existe" \
    "test -d $PROJECT_DIR/mocks" \
    "Crea el directorio mocks/ con: mkdir -p mocks"

validate "Mock data JSON existe en mocks/" \
    "find $PROJECT_DIR/mocks -name '*.json' | grep -q ." \
    "Crea al menos un archivo JSON en mocks/ con datos de prueba del plan"

validate "Mock JSON tiene resource_changes" \
    "grep -rq 'resource_changes' $PROJECT_DIR/mocks --include='*.json'" \
    "El mock JSON debe tener la clave resource_changes con los recursos del plan"

validate "sentinel.json de configuracion existe" \
    "test -f $PROJECT_DIR/sentinel.json" \
    "Crea sentinel.json apuntando al mock: { \"mock\": { \"tfplan/v2\": \"mocks/...\" } }"

validate "sentinel.json referencia el directorio mocks/" \
    "grep -q 'mocks/' $PROJECT_DIR/sentinel.json" \
    "sentinel.json debe apuntar a la ruta del archivo mock dentro de mocks/"

validate "sentinel.hcl con configuracion del Policy Set existe" \
    "test -f $PROJECT_DIR/sentinel.hcl" \
    "Crea sentinel.hcl con los bloques policy { enforcement_level = ... }"

validate "sentinel.hcl define enforcement_level" \
    "grep -q 'enforcement_level' $PROJECT_DIR/sentinel.hcl" \
    "sentinel.hcl debe definir enforcement_level para cada politica"

validate "niveles-enforcement.md documenta los tres niveles" \
    "test -f $PROJECT_DIR/niveles-enforcement.md && grep -qi 'hard-mandatory' $PROJECT_DIR/niveles-enforcement.md && grep -qi 'soft-mandatory' $PROJECT_DIR/niveles-enforcement.md && grep -qi 'advisory' $PROJECT_DIR/niveles-enforcement.md" \
    "Crea niveles-enforcement.md documentando hard-mandatory, soft-mandatory y advisory"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 10 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO — Badge: HCP Terraform Sentinel Policies${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m8-lab3"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

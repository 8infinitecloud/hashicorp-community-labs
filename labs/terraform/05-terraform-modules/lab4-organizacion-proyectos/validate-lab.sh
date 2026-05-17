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

echo -e "${YELLOW}🧪 Validando Lab 4: Organización de Proyectos${NC}"
echo "================================================"

validate "Módulo modules/red/ existe" \
    "[ -d 'modules/red' ]" \
    "Crea el módulo de red en modules/red/"

validate "Módulo modules/aplicacion/ existe" \
    "[ -d 'modules/aplicacion' ]" \
    "Crea el módulo de aplicación en modules/aplicacion/"

validate "Entorno dev/ existe" \
    "[ -d 'entornos/dev' ] || [ -d 'dev' ]" \
    "Crea el directorio para el entorno de desarrollo"

validate "Entorno prod/ existe" \
    "[ -d 'entornos/prod' ] || [ -d 'prod' ]" \
    "Crea el directorio para el entorno de producción"

validate "Dev tiene main.tf" \
    "find . -path '*/dev/main.tf' | grep -q ." \
    "El entorno dev debe tener su propio main.tf"

validate "Dev inicializado (.terraform/)" \
    "find . -path '*/dev/.terraform' -type d | grep -q ." \
    "Ejecuta: cd entornos/dev && terraform init"

validate "Dev aplicado (terraform.tfstate)" \
    "find . -path '*/dev/terraform.tfstate' | grep -q ." \
    "Ejecuta: cd entornos/dev && terraform apply -auto-approve"

validate "Prod tiene main.tf" \
    "find . -path '*/prod/main.tf' | grep -q ." \
    "El entorno prod debe tener su propio main.tf"

validate "Prod inicializado (.terraform/)" \
    "find . -path '*/prod/.terraform' -type d | grep -q ." \
    "Ejecuta: cd entornos/prod && terraform init"

validate "Cada entorno tiene variables distintas" \
    "find . -path '*/dev/terraform.tfvars' | grep -q . || find . -path '*/dev/*.auto.tfvars' | grep -q ." \
    "Usa terraform.tfvars o variables distintas por entorno"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 8 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: Terraform Project Organization${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m5-lab4"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

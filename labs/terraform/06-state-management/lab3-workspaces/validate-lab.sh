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

echo -e "${YELLOW}🧪 Validando Lab 3: Workspaces${NC}"
echo "================================================"

validate "Terraform inicializado (.terraform/)" \
    "[ -d '.terraform' ]" \
    "Ejecuta: terraform init"

validate "Estado default existe" \
    "[ -f 'terraform.tfstate' ] || [ -f 'terraform.tfstate.d/default/terraform.tfstate' ]" \
    "Ejecuta: terraform apply -auto-approve en el workspace default"

validate "Workspace dev fue creado" \
    "[ -d 'terraform.tfstate.d/dev' ]" \
    "Ejecuta: terraform workspace new dev && terraform apply -auto-approve"

validate "Estado del workspace dev existe" \
    "[ -f 'terraform.tfstate.d/dev/terraform.tfstate' ]" \
    "Aplica en el workspace dev: terraform workspace select dev && terraform apply"

validate "Workspace prod fue creado" \
    "[ -d 'terraform.tfstate.d/prod' ]" \
    "Ejecuta: terraform workspace new prod && terraform apply -auto-approve"

validate "Estado del workspace prod existe" \
    "[ -f 'terraform.tfstate.d/prod/terraform.tfstate' ]" \
    "Aplica en el workspace prod: terraform workspace select prod && terraform apply"

validate "main.tf usa terraform.workspace" \
    "grep -q 'terraform.workspace' main.tf" \
    "Usa terraform.workspace en main.tf para diferenciar entornos"

validate "Archivos de deploy generados para dev" \
    "find . -name '*dev*' -name '*.conf' -o -name '*dev*' -name '*.txt' | grep -q ." \
    "El apply en workspace dev debe generar archivos con 'dev' en el nombre"

validate "Archivos de deploy generados para prod" \
    "find . -name '*prod*' -name '*.conf' -o -name '*prod*' -name '*.txt' | grep -q ." \
    "El apply en workspace prod debe generar archivos con 'prod' en el nombre"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 7 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: Terraform Workspaces${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m6-lab3"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

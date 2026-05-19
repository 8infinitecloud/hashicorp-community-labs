#!/bin/bash
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
PASSED=0; FAILED=0

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

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

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "Terraform inicializado" \
    "test -d '$PROJECT_DIR/.terraform' || test -f '$PROJECT_DIR/terraform.tfstate'" \
    "Ejecuta: terraform init"

validate "Estado default existe" \
    "[ -f '$PROJECT_DIR/terraform.tfstate' ] || [ -f '$PROJECT_DIR/terraform.tfstate.d/default/terraform.tfstate' ]" \
    "Ejecuta: terraform apply -auto-approve en el workspace default"

validate "Workspace dev fue creado" \
    "[ -d '$PROJECT_DIR/terraform.tfstate.d/dev' ]" \
    "Ejecuta: terraform workspace new dev && terraform apply -auto-approve"

validate "Estado del workspace dev existe" \
    "[ -f '$PROJECT_DIR/terraform.tfstate.d/dev/terraform.tfstate' ]" \
    "Aplica en workspace dev: terraform workspace select dev && terraform apply -auto-approve"

validate "Workspace prod fue creado" \
    "[ -d '$PROJECT_DIR/terraform.tfstate.d/prod' ]" \
    "Ejecuta: terraform workspace new prod && terraform apply -auto-approve"

validate "Estado del workspace prod existe" \
    "[ -f '$PROJECT_DIR/terraform.tfstate.d/prod/terraform.tfstate' ]" \
    "Aplica en workspace prod: terraform workspace select prod && terraform apply -auto-approve"

validate "main.tf usa terraform.workspace" \
    "grep -q 'terraform.workspace' '$PROJECT_DIR/main.tf' 2>/dev/null" \
    "Usa terraform.workspace en main.tf para diferenciar entornos"

validate "Archivo deploy-dev.conf generado" \
    "[ -f '$PROJECT_DIR/deploy-dev.conf' ]" \
    "El apply en workspace dev debe generar deploy-dev.conf"

validate "Archivo deploy-prod.conf generado" \
    "[ -f '$PROJECT_DIR/deploy-prod.conf' ]" \
    "El apply en workspace prod debe generar deploy-prod.conf"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 8 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: Terraform Workspaces${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$PROJECT_DIR/../../../.badge-tf-m6-lab3"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

#!/bin/bash
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
PASSED=0; FAILED=0

PROJECT_DIR="${1:-/root/lab}"

validate() {
    echo -n "  $1... "
    if eval "$2" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"; ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} -- $3"; ((FAILED++))
    fi
}

echo -e "${YELLOW}Validando Lab 3: Workspaces${NC}"
echo "================================================"

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "Mock AWS server responde en localhost:4566" \
    "curl -sf http://localhost:4566/ > /dev/null" \
    "Espera a que el servidor mock arranque: curl -sf http://localhost:4566/ && echo OK"

validate "Bucket tf-state-lab3 existe (backend)" \
    "aws --endpoint-url http://localhost:4566 s3 ls 2>/dev/null | grep -q 'tf-state-lab3'" \
    "Crea el bucket de backend: aws --endpoint-url http://localhost:4566 s3 mb s3://tf-state-lab3"

validate "providers.tf contiene backend s3" \
    "grep -q 'backend.*\"s3\"' '$PROJECT_DIR/providers.tf' 2>/dev/null" \
    "Crea providers.tf con el bloque backend s3 del README"

validate "main.tf usa terraform.workspace" \
    "grep -q 'terraform\.workspace' '$PROJECT_DIR/main.tf' 2>/dev/null" \
    "Usa terraform.workspace en main.tf para diferenciar recursos por entorno"

validate "Terraform inicializado (.terraform/ presente)" \
    "test -d '$PROJECT_DIR/.terraform'" \
    "Ejecuta: terraform init"

validate "State del workspace dev existe en S3" \
    "aws --endpoint-url http://localhost:4566 s3 ls s3://tf-state-lab3/env:/dev/workspaces/terraform.tfstate 2>/dev/null | grep -q 'terraform.tfstate'" \
    "Ejecuta: terraform workspace new dev && terraform apply -auto-approve"

validate "State del workspace prod existe en S3" \
    "aws --endpoint-url http://localhost:4566 s3 ls s3://tf-state-lab3/env:/prod/workspaces/terraform.tfstate 2>/dev/null | grep -q 'terraform.tfstate'" \
    "Ejecuta: terraform workspace new prod && terraform apply -auto-approve"

validate "Bucket mi-bucket-dev-lab3 creado en LocalStack" \
    "aws --endpoint-url http://localhost:4566 s3 ls 2>/dev/null | grep -q 'mi-bucket-dev-lab3'" \
    "Aplica en workspace dev: terraform workspace select dev && terraform apply -auto-approve"

validate "Bucket mi-bucket-prod-lab3 creado en LocalStack" \
    "aws --endpoint-url http://localhost:4566 s3 ls 2>/dev/null | grep -q 'mi-bucket-prod-lab3'" \
    "Aplica en workspace prod: terraform workspace select prod && terraform apply -auto-approve"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO. Badge: Terraform Workspaces${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$PROJECT_DIR/../../../.badge-tf-m6-lab3"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO -- revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

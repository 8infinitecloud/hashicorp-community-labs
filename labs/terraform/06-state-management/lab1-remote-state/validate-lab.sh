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

echo -e "${YELLOW}Validando Lab 1: Remote State${NC}"
echo "================================================"

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "Mock AWS server responde en localhost:4566" \
    "curl -sf http://localhost:4566/ > /dev/null" \
    "Espera a que el servidor mock arranque: curl -sf http://localhost:4566/ && echo OK"

validate "Bucket tf-state-lab1 existe en LocalStack" \
    "aws --endpoint-url http://localhost:4566 s3 ls 2>/dev/null | grep -q 'tf-state-lab1'" \
    "Crea el bucket: aws --endpoint-url http://localhost:4566 s3 mb s3://tf-state-lab1"

validate "providers.tf contiene bloque backend s3" \
    "grep -q 'backend.*\"s3\"' '$PROJECT_DIR/providers.tf' 2>/dev/null" \
    "Crea providers.tf con el bloque backend s3 del README"

validate "providers.tf contiene force_path_style" \
    "grep -q 'force_path_style' '$PROJECT_DIR/providers.tf' 2>/dev/null" \
    "El backend s3 debe incluir force_path_style = true para LocalStack"

validate "Terraform inicializado (.terraform/ presente)" \
    "test -d '$PROJECT_DIR/.terraform'" \
    "Ejecuta: terraform init"

validate "State file existe en S3" \
    "aws --endpoint-url http://localhost:4566 s3 ls s3://tf-state-lab1/lab1/terraform.tfstate 2>/dev/null | grep -q 'terraform.tfstate'" \
    "Ejecuta: terraform apply -auto-approve"

validate "terraform state list muestra aws_s3_bucket.app" \
    "terraform -chdir='$PROJECT_DIR' state list 2>/dev/null | grep -q 'aws_s3_bucket\.app'" \
    "Ejecuta: terraform apply -auto-approve en el directorio del lab"

validate "No hay terraform.tfstate local (state en S3)" \
    "[ ! -f '$PROJECT_DIR/terraform.tfstate' ]" \
    "El state debe estar en S3, no en disco local"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO. Badge: Terraform Remote State${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$PROJECT_DIR/../../../.badge-tf-m6-lab1"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO -- revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

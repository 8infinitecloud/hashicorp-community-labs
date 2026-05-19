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

echo -e "${YELLOW}Validando Lab 4: State Migration${NC}"
echo "================================================"

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "Mock AWS server responde en localhost:4566" \
    "curl -sf http://localhost:4566/ > /dev/null" \
    "Espera a que el servidor mock arranque: curl -sf http://localhost:4566/ && echo OK"

validate "Bucket tf-state-lab4 existe" \
    "aws --endpoint-url http://localhost:4566 s3 ls 2>/dev/null | grep -q 'tf-state-lab4'" \
    "Crea el bucket de destino: aws --endpoint-url http://localhost:4566 s3 mb s3://tf-state-lab4"

validate "backend.tf contiene bloque backend s3" \
    "grep -q 'backend.*\"s3\"' '$PROJECT_DIR/backend.tf' 2>/dev/null" \
    "Crea backend.tf con el bloque backend s3 del README"

validate "Terraform inicializado con backend S3 (.terraform/ presente)" \
    "test -d '$PROJECT_DIR/.terraform'" \
    "Ejecuta: terraform init -migrate-state -force-copy"

validate "No hay terraform.tfstate local con estado (migrado a S3)" \
    "[ ! -s '$PROJECT_DIR/terraform.tfstate' ]" \
    "La migracion no se completo -- ejecuta: terraform init -migrate-state -force-copy"

validate "State file existe en S3" \
    "aws --endpoint-url http://localhost:4566 s3 ls s3://tf-state-lab4/lab4/terraform.tfstate 2>/dev/null | grep -q 'terraform.tfstate'" \
    "Ejecuta terraform init -migrate-state y verifica con: aws --endpoint-url http://localhost:4566 s3 ls s3://tf-state-lab4/lab4/"

validate "terraform state list muestra aws_s3_bucket.app" \
    "terraform -chdir='$PROJECT_DIR' state list 2>/dev/null | grep -q 'aws_s3_bucket\.app'" \
    "El state remoto debe contener aws_s3_bucket.app tras la migracion"

validate "terraform plan sin cambios (infraestructura integra)" \
    "terraform -chdir='$PROJECT_DIR' plan -detailed-exitcode 2>/dev/null; [ \$? -eq 0 ]" \
    "Despues de la migracion, terraform plan debe mostrar No changes"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO. Badge: Terraform State Migration${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$PROJECT_DIR/../../../.badge-tf-m6-lab4"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO -- revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

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

echo -e "${YELLOW}Validando Lab 2: State Locking${NC}"
echo "================================================"

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "Mock AWS server responde en localhost:4566" \
    "curl -sf http://localhost:4566/ > /dev/null" \
    "Espera a que el servidor mock arranque: curl -sf http://localhost:4566/ && echo OK"

validate "Bucket tf-state-lab2 existe" \
    "aws --endpoint-url http://localhost:4566 s3 ls 2>/dev/null | grep -q 'tf-state-lab2'" \
    "Crea el bucket: aws --endpoint-url http://localhost:4566 s3 mb s3://tf-state-lab2"

validate "Tabla DynamoDB tf-lock existe" \
    "aws --endpoint-url http://localhost:4566 dynamodb describe-table --table-name tf-lock 2>/dev/null | grep -q 'TableName'" \
    "Crea la tabla: aws --endpoint-url http://localhost:4566 dynamodb create-table --table-name tf-lock --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST"

validate "providers.tf contiene dynamodb_table" \
    "grep -q 'dynamodb_table' '$PROJECT_DIR/providers.tf' 2>/dev/null" \
    "Agrega dynamodb_table = \"tf-lock\" al bloque backend s3 en providers.tf"

validate "Terraform inicializado (.terraform/ presente)" \
    "test -d '$PROJECT_DIR/.terraform'" \
    "Ejecuta: terraform init"

validate "State file existe en S3" \
    "aws --endpoint-url http://localhost:4566 s3 ls s3://tf-state-lab2/lab2/terraform.tfstate 2>/dev/null | grep -q 'terraform.tfstate'" \
    "Ejecuta: terraform apply -auto-approve"

validate "terraform state list muestra aws_s3_bucket.app" \
    "terraform -chdir='$PROJECT_DIR' state list 2>/dev/null | grep -q 'aws_s3_bucket\.app'" \
    "Ejecuta: terraform apply -auto-approve"

validate "terraform state list muestra aws_dynamodb_table.datos" \
    "terraform -chdir='$PROJECT_DIR' state list 2>/dev/null | grep -q 'aws_dynamodb_table\.datos'" \
    "Ejecuta: terraform apply -auto-approve con el main.tf completo"

validate "No hay locks activos en tf-lock" \
    "aws --endpoint-url http://localhost:4566 dynamodb scan --table-name tf-lock 2>/dev/null | python3 -c \"import sys,json; d=json.load(sys.stdin); sys.exit(0 if d.get('Count',1)==0 else 1)\"" \
    "Hay un lock activo en DynamoDB -- espera a que termine el apply o ejecuta: terraform force-unlock <LOCK_ID>"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO. Badge: Terraform State Locking${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$PROJECT_DIR/../../../.badge-tf-m6-lab2"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO -- revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

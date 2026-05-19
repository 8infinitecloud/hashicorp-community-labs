#!/bin/bash
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
PASSED=0; FAILED=0

PROJECT_DIR="${1:-/root/lab}"

validate() {
    echo -n "  $1... "
    if eval "$2" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"; ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} — $3"; ((FAILED++))
    fi
}

echo -e "${YELLOW}Validando Lab 4: Troubleshooting — Import y Debug${NC}"
echo "================================================"

validate "LocalStack responde (aws --endpoint-url http://localhost:4566 s3 ls)" \
    "aws --endpoint-url http://localhost:4566 s3 ls" \
    "Verifica que el servidor mock este corriendo: curl -sf http://localhost:4566/ && echo OK"

validate "Bucket bucket-legado existe en LocalStack" \
    "aws --endpoint-url http://localhost:4566 s3 ls | grep -q 'bucket-legado'" \
    "Ejecuta: aws --endpoint-url http://localhost:4566 s3 mb s3://bucket-legado --region us-east-1"

validate "Terraform inicializado (.terraform existe)" \
    "test -d $PROJECT_DIR/.terraform" \
    "Ejecuta: terraform init"

validate "Estado aplicado (terraform.tfstate)" \
    "test -f $PROJECT_DIR/terraform.tfstate" \
    "Ejecuta: terraform import aws_s3_bucket.legado bucket-legado y luego terraform apply -auto-approve"

validate "State contiene aws_s3_bucket.legado" \
    "terraform -chdir=$PROJECT_DIR state list 2>/dev/null | grep -q 'aws_s3_bucket.legado'" \
    "Importa el recurso: terraform import aws_s3_bucket.legado bucket-legado"

validate "Plan sin cambios despues del import y apply" \
    "terraform -chdir=$PROJECT_DIR plan -detailed-exitcode 2>/dev/null; test \$? -eq 0" \
    "Reconcilia ejecutando: terraform apply -auto-approve"

validate "Log de debug generado (terraform-debug.log)" \
    "test -s $PROJECT_DIR/terraform-debug.log" \
    "Genera el log: export TF_LOG=DEBUG && export TF_LOG_PATH=/root/lab/terraform-debug.log && terraform plan"

validate "main.tf contiene resource aws_s3_bucket legado con bucket-legado" \
    "grep -q 'bucket-legado' $PROJECT_DIR/main.tf && grep -q 'aws_s3_bucket' $PROJECT_DIR/main.tf" \
    "El main.tf debe describir el recurso con bucket = \"bucket-legado\""

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO — Badge: Terraform Troubleshooting Expert${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$PROJECT_DIR/../../../.badge-tf-m7-lab4"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

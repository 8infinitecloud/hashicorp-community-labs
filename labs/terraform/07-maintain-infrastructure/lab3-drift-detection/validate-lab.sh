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

echo -e "${YELLOW}Validando Lab 3: Drift Detection${NC}"
echo "================================================"

validate "LocalStack responde (awslocal s3 ls)" \
    "awslocal s3 ls" \
    "Verifica que LocalStack este corriendo: curl -s http://localhost:4566/_localstack/health | jq .services.s3"

validate "Bucket app-bucket-drift-lab existe en LocalStack" \
    "awslocal s3 ls | grep -q 'app-bucket-drift-lab'" \
    "Ejecuta: terraform apply -auto-approve"

validate "Terraform inicializado (.terraform existe)" \
    "test -d $PROJECT_DIR/.terraform" \
    "Ejecuta: terraform init"

validate "Estado aplicado (terraform.tfstate)" \
    "test -f $PROJECT_DIR/terraform.tfstate" \
    "Ejecuta: terraform apply -auto-approve"

validate "State contiene aws_s3_bucket.app" \
    "terraform -chdir=$PROJECT_DIR state list 2>/dev/null | grep -q 'aws_s3_bucket.app'" \
    "El bucket debe estar en el state — ejecuta terraform apply -auto-approve"

validate "Plan sin cambios despues de reconciliar" \
    "terraform -chdir=$PROJECT_DIR plan -detailed-exitcode 2>/dev/null; test \$? -eq 0" \
    "Reconcilia el drift ejecutando: terraform apply -auto-approve"

validate "main.tf contiene ignore_changes" \
    "grep -q 'ignore_changes' $PROJECT_DIR/main.tf" \
    "Agrega lifecycle { ignore_changes = [tags] } al recurso aws_s3_bucket.app"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO — Badge: Terraform Drift Detection${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$PROJECT_DIR/../../../.badge-tf-m7-lab3"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

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

echo -e "${YELLOW}🧪 Validando Lab 2: State Locking${NC}"
echo "================================================"

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "Terraform inicializado" \
    "test -d '$PROJECT_DIR/.terraform' || test -f '$PROJECT_DIR/terraform.tfstate'" \
    "Ejecuta: terraform init"

validate "Estado aplicado (terraform.tfstate)" \
    "[ -f '$PROJECT_DIR/terraform.tfstate' ]" \
    "Ejecuta: terraform apply -auto-approve"

validate "Estado contiene recursos" \
    "terraform -chdir='$PROJECT_DIR' state list 2>/dev/null | grep -q ." \
    "El apply debe haber creado recursos en el estado"

validate "main.tf usa local_file" \
    "grep -q 'local_file' '$PROJECT_DIR/main.tf' 2>/dev/null" \
    "Usa local_file en main.tf"

validate "flujo-locking.md creado" \
    "[ -f '$PROJECT_DIR/flujo-locking.md' ]" \
    "Crea flujo-locking.md con el comando cat > del README"

validate "flujo-locking.md explica el concepto de lock" \
    "grep -qi 'lock' '$PROJECT_DIR/flujo-locking.md' 2>/dev/null" \
    "El archivo debe explicar que es el state locking"

validate "Referencia de backend con locking existe" \
    "[ -f '$PROJECT_DIR/backend-con-locking.tf.referencia' ] && grep -q 'dynamodb' '$PROJECT_DIR/backend-con-locking.tf.referencia'" \
    "Crea backend-con-locking.tf.referencia con dynamodb_table"

validate "No hay lock activo (.terraform.tfstate.lock.info ausente)" \
    "[ ! -f '$PROJECT_DIR/.terraform.tfstate.lock.info' ]" \
    "El lock simulado debe estar liberado — ejecuta: rm .terraform.tfstate.lock.info"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 7 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: Terraform State Locking${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$PROJECT_DIR/../../../.badge-tf-m6-lab2"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

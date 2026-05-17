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

echo -e "${YELLOW}🧪 Validando Lab 2: State Locking${NC}"
echo "================================================"

validate "Terraform inicializado (.terraform/)" \
    "[ -d '.terraform' ]" \
    "Ejecuta: terraform init"

validate "Estado aplicado (terraform.tfstate)" \
    "[ -f 'terraform.tfstate' ]" \
    "Ejecuta: terraform apply -auto-approve"

validate "Archivo flujo-locking.md creado" \
    "[ -f 'flujo-locking.md' ]" \
    "Crea flujo-locking.md documentando el proceso de locking"

validate "flujo-locking.md explica el concepto" \
    "grep -qi 'lock' flujo-locking.md" \
    "El archivo debe explicar qué es el state locking"

validate "Referencia de backend con locking existe" \
    "[ -f 'backend-con-locking.tf.referencia' ] || [ -f 'backend-locking-referencia.tf' ] || grep -rq 'dynamodb' . --include='*.tf' --include='*.referencia' 2>/dev/null" \
    "Crea backend-con-locking.tf.referencia con la config de DynamoDB"

validate "main.tf usa local_file" \
    "grep -q 'local_file' main.tf" \
    "Usa local_file resources en main.tf"

validate "Estado contiene recursos" \
    "terraform state list 2>/dev/null | grep -q ." \
    "El apply debe haber creado recursos en el estado"

validate "terraform.tfstate sin .terraform.tfstate.lock.info activo" \
    "[ ! -f '.terraform.tfstate.lock.info' ]" \
    "No debe quedar un lock activo — verifica que apply terminó correctamente"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 6 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: Terraform State Locking${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m6-lab2"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

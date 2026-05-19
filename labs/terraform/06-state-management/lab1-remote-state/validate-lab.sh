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

echo -e "${YELLOW}🧪 Validando Lab 1: Remote State${NC}"
echo "================================================"

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "Terraform inicializado" \
    "test -d '$PROJECT_DIR/.terraform' || test -f '$PROJECT_DIR/terraform.tfstate'" \
    "Ejecuta: terraform init"

validate "Estado local existe (terraform.tfstate)" \
    "[ -f '$PROJECT_DIR/terraform.tfstate' ]" \
    "Ejecuta: terraform apply -auto-approve"

validate "Estado tiene serial > 0" \
    "python3 -c \"import json,sys; d=json.load(open('$PROJECT_DIR/terraform.tfstate')); sys.exit(0 if d.get('serial',0)>0 else 1)\" 2>/dev/null" \
    "El state debe tener serial > 0 — ejecuta terraform apply"

validate "Estado contiene al menos 2 recursos" \
    "terraform -chdir='$PROJECT_DIR' state list 2>/dev/null | wc -l | awk '\$1>=2{exit 0} \$1<2{exit 1}'" \
    "El apply debe crear al menos 2 recursos local_file"

validate "Archivo notas-problema.txt creado" \
    "[ -f '$PROJECT_DIR/notas-problema.txt' ]" \
    "Crea notas-problema.txt con el comando cat > notas-problema.txt del README"

validate "backend-referencia.tf creado" \
    "[ -f '$PROJECT_DIR/backend-referencia.tf' ]" \
    "Crea backend-referencia.tf con la config de S3 backend"

validate "backend-referencia.tf contiene bloque backend" \
    "grep -q 'backend' '$PROJECT_DIR/backend-referencia.tf' 2>/dev/null" \
    "El archivo de referencia debe contener la palabra 'backend'"

validate "main.tf usa provider local" \
    "grep -q 'local_file\|hashicorp/local' '$PROJECT_DIR/main.tf' 2>/dev/null" \
    "Usa el provider local en main.tf"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 7 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: Terraform Remote State${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$PROJECT_DIR/../../../.badge-tf-m6-lab1"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

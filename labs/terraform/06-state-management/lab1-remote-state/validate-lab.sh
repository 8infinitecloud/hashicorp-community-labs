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

echo -e "${YELLOW}🧪 Validando Lab 1: Remote State${NC}"
echo "================================================"

validate "Terraform inicializado (.terraform/)" \
    "[ -d '.terraform' ]" \
    "Ejecuta: terraform init"

validate "Estado local existe (terraform.tfstate)" \
    "[ -f 'terraform.tfstate' ]" \
    "Ejecuta: terraform apply -auto-approve"

validate "Estado contiene al menos 2 recursos" \
    "terraform state list 2>/dev/null | wc -l | grep -qE '^[2-9]|^[0-9]{2}'" \
    "El apply debe crear al menos 2 recursos local_file"

validate "Archivo notas-problema.txt generado" \
    "[ -f 'notas-problema.txt' ]" \
    "El apply debe generar notas-problema.txt via local_file"

validate "Archivo backend-referencia.tf creado" \
    "[ -f 'backend-referencia.tf' ] || [ -f 'backend-s3-referencia.tf' ]" \
    "Crea backend-referencia.tf con la config de S3 backend (como referencia)"

validate "backend-referencia.tf contiene bloque backend" \
    "grep -q 'backend' backend-referencia.tf 2>/dev/null || grep -q 'backend' backend-s3-referencia.tf 2>/dev/null" \
    "El archivo de referencia debe mostrar la sintaxis del backend"

validate "terraform.tfstate contiene serial > 0" \
    "grep -q '\"serial\"' terraform.tfstate && python3 -c \"import json,sys; d=json.load(open('terraform.tfstate')); sys.exit(0 if d.get('serial',0)>0 else 1)\" 2>/dev/null" \
    "El estado debe tener serial > 0 (indica que fue aplicado)"

validate "main.tf usa provider local" \
    "grep -q 'hashicorp/local' main.tf || grep -q 'local_file' main.tf" \
    "Usa el provider local en main.tf"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 6 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: Terraform State Expert${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m6-lab1"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

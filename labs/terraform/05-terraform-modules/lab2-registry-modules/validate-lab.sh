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

echo -e "${YELLOW}🧪 Validando Lab 2: Módulos del Registry${NC}"
echo "================================================"

validate "hashicorp/random descargado del Registry" \
    "find .terraform/providers -type d -name 'random' 2>/dev/null | grep -q ." \
    "Ejecuta: terraform init (descarga providers del Registry)"

validate "Lock file generado (.terraform.lock.hcl)" \
    "[ -f '.terraform.lock.hcl' ]" \
    "terraform init genera el lock file automáticamente"

validate "Lock file contiene hashicorp/random" \
    "grep -q 'hashicorp/random' .terraform.lock.hcl" \
    "Verifica que required_providers incluye hashicorp/random"

validate "Lock file contiene hashicorp/local" \
    "grep -q 'hashicorp/local' .terraform.lock.hcl" \
    "Verifica que required_providers incluye hashicorp/local"

validate "Archivo config-generada.txt creado" \
    "[ -f 'config-generada.txt' ]" \
    "Ejecuta: terraform apply -auto-approve"

validate "Estado aplicado (terraform.tfstate)" \
    "[ -f 'terraform.tfstate' ]" \
    "Ejecuta: terraform apply -auto-approve"

validate "Estado contiene random_id" \
    "terraform state list 2>/dev/null | grep -q 'random_id'" \
    "El apply debe crear un recurso random_id"

validate "Módulo local modules/identificador/ existe" \
    "[ -d 'modules/identificador' ]" \
    "Crea el directorio modules/identificador/ con su main.tf"

validate "Módulo identificador tiene main.tf" \
    "[ -f 'modules/identificador/main.tf' ]" \
    "Crea modules/identificador/main.tf con el módulo"

validate "main.tf usa el módulo dos veces" \
    "grep -c 'source.*modules/identificador' main.tf | grep -qE '^[2-9]'" \
    "Usa el módulo al menos dos veces con parámetros distintos"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 8 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: Terraform Registry Expert${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m5-lab2"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

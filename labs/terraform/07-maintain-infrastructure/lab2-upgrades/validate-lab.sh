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

echo -e "${YELLOW}🧪 Validando Lab 2: Upgrades y Versiones${NC}"
echo "================================================"

validate "Terraform inicializado (.terraform/)" \
    "[ -d '.terraform' ]" \
    "Ejecuta: terraform init"

validate "Lock file existe (.terraform.lock.hcl)" \
    "[ -f '.terraform.lock.hcl' ]" \
    "El lock file debe existir después de terraform init"

validate "versions.tf existe con required_version" \
    "[ -f 'versions.tf' ] && grep -q 'required_version' versions.tf" \
    "Crea versions.tf con required_version = \">= 1.0\""

validate "required_providers con versiones fijas en versions.tf" \
    "grep -q 'required_providers' versions.tf && grep -q 'version' versions.tf" \
    "Define required_providers con version constraints en versions.tf"

validate "terraform validate pasa sin errores" \
    "terraform validate 2>/dev/null" \
    "Corrige errores de sintaxis: ejecuta terraform validate para ver detalles"

validate "Estado aplicado (terraform.tfstate)" \
    "[ -f 'terraform.tfstate' ]" \
    "Ejecuta: terraform apply -auto-approve"

validate "Archivo notas-terraform-versions.txt creado" \
    "[ -f 'notas-terraform-versions.txt' ] || [ -f 'notas-versiones.txt' ] || [ -f 'upgrade-notes.txt' ]" \
    "Crea un archivo documentando las versiones usadas y el proceso de upgrade"

validate "Lock file tiene versión fija (h1: hash presente)" \
    "grep -q 'h1:' .terraform.lock.hcl" \
    "El lock file debe contener hashes de integridad (h1:)"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 6 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: Terraform Upgrades Expert${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m7-lab2"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

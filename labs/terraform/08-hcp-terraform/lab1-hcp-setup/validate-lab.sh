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

echo -e "${YELLOW}🧪 Validando Lab 1: HCP Terraform Setup${NC}"
echo "================================================"
echo -e "${YELLOW}ℹ️  Este lab requiere una cuenta HCP Terraform (gratuita)${NC}"
echo ""

validate "versions.tf existe" \
    "[ -f 'versions.tf' ]" \
    "Crea versions.tf con el bloque terraform { cloud { ... } }"

validate "versions.tf tiene bloque cloud" \
    "grep -q 'cloud {' versions.tf" \
    "Agrega el bloque cloud {} dentro de terraform {} en versions.tf"

validate "versions.tf tiene organización configurada" \
    "grep -q 'organization' versions.tf" \
    "Configura organization = \"tu-org\" en el bloque cloud"

validate "Credenciales HCP Terraform configuradas" \
    "[ -f ~/.terraform.d/credentials.tfrc.json ] || [ -n \"\$TF_TOKEN_app_terraform_io\" ]" \
    "Ejecuta: terraform login    (requiere cuenta en app.terraform.io)"

validate "Terraform inicializado con cloud backend" \
    "[ -d '.terraform' ] && grep -q 'app.terraform.io\|terraform.io' .terraform/environment 2>/dev/null || [ -f '.terraform/terraform.tfstate' ]" \
    "Ejecuta: terraform init    (debe conectar con HCP Terraform)"

validate "main.tf usa provider local" \
    "[ -f 'main.tf' ] && grep -q 'local_file\|hashicorp/local' main.tf" \
    "Crea main.tf con al menos un recurso local_file para probar"

validate "Archivo notas-hcp.txt o similar documentado" \
    "[ -f 'notas-hcp.txt' ] || [ -f 'hcp-setup.md' ] || [ -f 'notas-setup.md' ]" \
    "Crea un archivo documentando los pasos realizados en HCP Terraform"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 5 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: HCP Terraform Setup${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m8-lab1"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    echo -e "${YELLOW}💡 Recuerda: este lab requiere cuenta gratuita en app.terraform.io${NC}"
    exit 1
fi

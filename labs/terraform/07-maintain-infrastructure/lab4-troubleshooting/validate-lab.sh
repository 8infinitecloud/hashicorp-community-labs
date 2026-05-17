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

echo -e "${YELLOW}🧪 Validando Lab 4: Troubleshooting${NC}"
echo "================================================"

validate "Terraform inicializado (.terraform/)" \
    "[ -d '.terraform' ]" \
    "Ejecuta: terraform init"

validate "terraform validate pasa sin errores" \
    "terraform validate 2>/dev/null" \
    "Corrige los errores de sintaxis — usa: terraform validate para detalles"

validate "main.tf NO usa atributo 'permisos' inválido" \
    "! grep -q '\"permisos\"' main.tf && ! grep -q 'permisos =' main.tf" \
    "Reemplaza 'permisos' con el atributo correcto: file_permission"

validate "main.tf usa file_permission correctamente" \
    "grep -q 'file_permission' main.tf" \
    "Usa file_permission = \"0644\" en lugar del atributo incorrecto"

validate "Estado aplicado (terraform.tfstate)" \
    "[ -f 'terraform.tfstate' ]" \
    "Ejecuta: terraform apply -auto-approve"

validate "Archivo errores-comunes.md creado" \
    "[ -f 'errores-comunes.md' ] || [ -f 'troubleshooting-notas.md' ]" \
    "Crea errores-comunes.md documentando los errores encontrados y sus soluciones"

validate "errores-comunes.md tiene contenido sustancial" \
    "wc -l < errores-comunes.md 2>/dev/null | grep -qE '^[5-9]$|^[0-9]{2}' || wc -l < troubleshooting-notas.md 2>/dev/null | grep -qE '^[5-9]$|^[0-9]{2}'" \
    "El archivo debe tener al menos 5 líneas documentando los errores"

validate "Archivo terraform-debug.log generado" \
    "[ -f 'terraform-debug.log' ] || ls TF_LOG* 2>/dev/null | grep -q ." \
    "Genera un log de debug: TF_LOG=DEBUG terraform plan > terraform-debug.log 2>&1"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 6 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: Terraform Troubleshooting Expert${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m7-lab4"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

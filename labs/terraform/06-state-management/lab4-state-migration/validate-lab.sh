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

echo -e "${YELLOW}🧪 Validando Lab 4: State Migration${NC}"
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

validate "Estado NO tiene recursos con nombres viejo" \
    "! terraform -chdir='$PROJECT_DIR' state list 2>/dev/null | grep -q '_viejo'" \
    "Renombra los recursos con: terraform state mv local_file.archivo_viejo local_file.config"

validate "Estado contiene local_file.config" \
    "terraform -chdir='$PROJECT_DIR' state list 2>/dev/null | grep -q 'local_file\.config'" \
    "El state debe mostrar local_file.config despues del state mv"

validate "Modulo archivos en el estado" \
    "terraform -chdir='$PROJECT_DIR' state list 2>/dev/null | grep -q 'module\.archivos'" \
    "El state debe mostrar module.archivos.* — ejecuta terraform state mv local_file.log module.archivos.local_file.log"

validate "Plan muestra No changes" \
    "terraform -chdir='$PROJECT_DIR' plan -detailed-exitcode 2>/dev/null; [ \$? -eq 0 ]" \
    "Despues de state mv y actualizar main.tf, terraform plan no debe mostrar cambios"

validate "migracion-backend.md creado" \
    "[ -f '$PROJECT_DIR/migracion-backend.md' ]" \
    "Crea migracion-backend.md con el comando cat > del README"

validate "State respaldado (terraform.tfstate.pre-migracion)" \
    "[ -f '$PROJECT_DIR/terraform.tfstate.pre-migracion' ]" \
    "Ejecuta: cp terraform.tfstate terraform.tfstate.pre-migracion"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 7 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: Terraform State Migration${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$PROJECT_DIR/../../../.badge-tf-m6-lab4"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

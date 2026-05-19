#!/bin/bash
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
PASSED=0; FAILED=0

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

validate() {
    echo -n "  $1... "
    if eval "$2" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"; ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} — $3"; ((FAILED++))
    fi
}

echo -e "${YELLOW}Validando Lab 4: Troubleshooting${NC}"
echo "================================================"

validate "Terraform inicializado" \
    "test -d $PROJECT_DIR/.terraform || test -f $PROJECT_DIR/terraform.tfstate" \
    "Ejecuta: terraform init"

validate "main.tf no usa atributo invalido 'permisos'" \
    "test -f $PROJECT_DIR/main.tf && ! grep -qE '^\s*permisos\s*=' $PROJECT_DIR/main.tf" \
    "Reemplaza 'permisos' con el atributo correcto: file_permission"

validate "main.tf usa file_permission correctamente" \
    "grep -q 'file_permission' $PROJECT_DIR/main.tf" \
    "Agrega file_permission = \"0644\" al recurso local_file.config"

validate "main.tf no tiene referencias a recursos inexistentes" \
    "! grep -q 'local_file.no_existe' $PROJECT_DIR/main.tf" \
    "Corrige la referencia: usa local_file.config.filename en lugar de local_file.no_existe.filename"

validate "terraform validate sin errores" \
    "terraform -chdir=$PROJECT_DIR validate 2>/dev/null" \
    "Corrige los errores de sintaxis — ejecuta terraform validate para ver detalles"

validate "Estado aplicado (terraform.tfstate)" \
    "test -f $PROJECT_DIR/terraform.tfstate" \
    "Ejecuta: terraform apply -auto-approve"

validate "Log de debug generado (terraform-debug.log)" \
    "test -f $PROJECT_DIR/terraform-debug.log" \
    "Genera el log: TF_LOG=DEBUG TF_LOG_PATH=/root/lab/terraform-debug.log terraform plan"

validate "Archivo errores-comunes.md creado con contenido" \
    "test -f $PROJECT_DIR/errores-comunes.md && test \$(wc -l < $PROJECT_DIR/errores-comunes.md) -ge 5" \
    "Crea errores-comunes.md con al menos 5 lineas documentando los errores"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ "$FAILED" -eq 0 ] && [ "$PASSED" -ge 6 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO — Badge: Terraform Troubleshooting Expert${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "$PROJECT_DIR/../../../.badge-tf-m7-lab4"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

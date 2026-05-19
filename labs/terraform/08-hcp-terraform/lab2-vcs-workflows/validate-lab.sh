#!/bin/bash
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
PASSED=0; FAILED=0
PROJECT_DIR="/root/lab"

validate() {
    echo -n "  $1... "
    if eval "$2" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"; ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} — $3"; ((FAILED++))
    fi
}

echo -e "${YELLOW}Validando Lab 2: VCS Workflows${NC}"
echo "================================================"
echo ""

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "Repositorio git inicializado" \
    "test -d $PROJECT_DIR/.git" \
    "Ejecuta: git init"

validate "main.tf existe con bloque terraform" \
    "test -f $PROJECT_DIR/main.tf && grep -q 'terraform {' $PROJECT_DIR/main.tf" \
    "Crea main.tf con el bloque terraform {} y recursos"

validate "main.tf usa provider local" \
    "grep -q 'hashicorp/local' $PROJECT_DIR/main.tf" \
    "main.tf debe requerir el provider hashicorp/local"

validate "main.tf tiene variable version_app" \
    "grep -q 'variable' $PROJECT_DIR/main.tf" \
    "main.tf debe declarar al menos una variable"

validate "Al menos dos commits en el repositorio" \
    "git -C $PROJECT_DIR log --oneline 2>/dev/null | wc -l | grep -qE '^[2-9]|^[0-9]{2,}'" \
    "Ejecuta al menos dos commits: configuracion inicial + notas VCS"

validate ".gitignore existe y excluye .terraform" \
    "test -f $PROJECT_DIR/.gitignore && grep -q '.terraform' $PROJECT_DIR/.gitignore" \
    "Crea .gitignore con al menos la entrada .terraform/"

validate "vcs-workflow-notas.md existe" \
    "test -f $PROJECT_DIR/vcs-workflow-notas.md" \
    "Crea vcs-workflow-notas.md documentando el flujo VCS"

validate "notas mencionan speculative plan o VCS" \
    "grep -qi 'speculative\|vcs\|github\|trigger\|auto.apply' $PROJECT_DIR/vcs-workflow-notas.md" \
    "Las notas deben mencionar speculative plans, VCS o trigger patterns"

validate "Terraform inicializado o aplicado" \
    "test -d $PROJECT_DIR/.terraform || test -f $PROJECT_DIR/terraform.tfstate" \
    "Ejecuta: terraform init"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 8 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO — Badge: HCP Terraform VCS Workflows${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m8-lab2"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

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

echo -e "${YELLOW}🧪 Validando Lab 2: VCS Workflows${NC}"
echo "================================================"
echo -e "${YELLOW}ℹ️  Este lab requiere HCP Terraform + cuenta GitHub${NC}"
echo ""

validate "Repositorio git inicializado" \
    "[ -d '.git' ]" \
    "Ejecuta: git init    (o clona un repo existente)"

validate "main.tf existe con configuración Terraform" \
    "[ -f 'main.tf' ] && grep -q 'terraform {' main.tf" \
    "Crea main.tf con el bloque terraform {} y recursos"

validate "Al menos un commit en el repositorio" \
    "git log --oneline 2>/dev/null | grep -q ." \
    "Ejecuta: git add . && git commit -m 'feat: configuración inicial'"

validate "Remote origin configurado (GitHub)" \
    "git remote get-url origin 2>/dev/null | grep -q 'github.com'" \
    "Configura el remote: git remote add origin https://github.com/usuario/repo.git"

validate "Archivo vcs-workflow-notas.md documentado" \
    "[ -f 'vcs-workflow-notas.md' ] || [ -f 'notas-vcs.md' ] || [ -f 'hcp-vcs.md' ]" \
    "Documenta el flujo VCS configurado en HCP Terraform"

validate "Código Terraform válido" \
    "terraform validate 2>/dev/null || [ ! -d '.terraform' ]" \
    "Verifica la sintaxis: terraform validate"

validate "Documentación del workspace VCS en notas" \
    "grep -qi 'workspace\|vcs\|github\|trigger' vcs-workflow-notas.md 2>/dev/null || grep -qi 'workspace\|vcs\|github' notas-vcs.md 2>/dev/null || grep -qi 'workspace\|vcs\|github' hcp-vcs.md 2>/dev/null" \
    "Las notas deben mencionar la configuración del workspace en HCP Terraform"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 5 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: HCP Terraform VCS Workflows${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m8-lab2"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    echo -e "${YELLOW}💡 Recuerda: este lab requiere HCP Terraform con VCS provider conectado${NC}"
    exit 1
fi

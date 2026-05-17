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

echo -e "${YELLOW}🧪 Validando Lab 4: Team Collaboration${NC}"
echo "================================================"
echo -e "${YELLOW}ℹ️  Este lab documenta la configuración de HCP Terraform${NC}"
echo ""

validate "modelo-permisos.md creado" \
    "[ -f 'modelo-permisos.md' ]" \
    "Crea modelo-permisos.md documentando los niveles de acceso en HCP Terraform"

validate "modelo-permisos.md describe niveles de acceso" \
    "grep -qi 'owner\|admin\|write\|read\|plan' modelo-permisos.md" \
    "Documenta los roles: Owner, Admin, Write, Plan, Read"

validate "run-triggers.md creado" \
    "[ -f 'run-triggers.md' ]" \
    "Crea run-triggers.md explicando las dependencias entre workspaces"

validate "run-triggers.md explica el concepto" \
    "grep -qi 'trigger\|workspace\|depend' run-triggers.md" \
    "El archivo debe explicar cómo funciona el trigger entre workspaces"

validate "notificaciones.md creado" \
    "[ -f 'notificaciones.md' ]" \
    "Crea notificaciones.md documentando los tipos de notificación disponibles"

validate "notificaciones.md menciona canales" \
    "grep -qi 'slack\|email\|webhook\|teams' notificaciones.md" \
    "Documenta los canales: Slack, Email, Microsoft Teams, Webhook"

validate "Documentación de al menos 2 equipos" \
    "grep -qi 'developers\|ops\|security\|team' modelo-permisos.md" \
    "Documenta los equipos creados: developers, ops-team, security"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 5 ]; then
    echo -e "${GREEN}🎉 ¡LABORATORIO COMPLETADO! Badge: HCP Terraform Team Collaboration${NC}"
    echo -e "${GREEN}🎓 ¡BOOTCAMP TERRAFORM ASSOCIATE 004 COMPLETADO!${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m8-lab4"
    exit 0
else
    echo -e "${RED}❌ LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    echo -e "${YELLOW}💡 Este lab es principalmente documentación de la configuración en HCP Terraform UI${NC}"
    exit 1
fi

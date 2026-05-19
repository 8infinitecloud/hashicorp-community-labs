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

echo -e "${YELLOW}Validando Lab 4: Team Collaboration${NC}"
echo "================================================"
echo ""

validate "Terraform instalado" \
    "terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -q ." \
    "Instala Terraform >= 1.0"

validate "main.tf existe con bloque terraform" \
    "test -f $PROJECT_DIR/main.tf && grep -q 'terraform {' $PROJECT_DIR/main.tf" \
    "Crea main.tf con el bloque terraform {} y recursos local_file"

validate "Terraform inicializado" \
    "test -d $PROJECT_DIR/.terraform || test -f $PROJECT_DIR/terraform.tfstate" \
    "Ejecuta: terraform init"

validate "terraform apply ejecutado" \
    "test -f $PROJECT_DIR/terraform.tfstate || test -f $PROJECT_DIR/politica-acceso.txt" \
    "Ejecuta: terraform apply -auto-approve"

validate "modelo-permisos.md creado" \
    "test -f $PROJECT_DIR/modelo-permisos.md" \
    "Crea modelo-permisos.md documentando los niveles de acceso en HCP Terraform"

validate "modelo-permisos.md describe roles de workspace" \
    "grep -qi 'write\|read\|plan\|admin' $PROJECT_DIR/modelo-permisos.md" \
    "Documenta los roles de workspace: Read, Plan, Write, Admin"

validate "modelo-permisos.md menciona equipos" \
    "grep -qi 'developer\|ops\|security\|team' $PROJECT_DIR/modelo-permisos.md" \
    "Documenta al menos dos equipos: developers, ops-team, security"

validate "run-triggers.md creado" \
    "test -f $PROJECT_DIR/run-triggers.md" \
    "Crea run-triggers.md explicando las dependencias entre workspaces"

validate "run-triggers.md explica el flujo de trigger" \
    "grep -qi 'trigger\|workspace\|depend\|fuente\|destino' $PROJECT_DIR/run-triggers.md" \
    "run-triggers.md debe explicar workspace fuente, workspace destino y cuando se dispara"

validate "notificaciones.md creado" \
    "test -f $PROJECT_DIR/notificaciones.md" \
    "Crea notificaciones.md documentando los tipos de notificacion disponibles"

validate "notificaciones.md menciona canales de notificacion" \
    "grep -qi 'slack\|email\|webhook\|teams' $PROJECT_DIR/notificaciones.md" \
    "Documenta los canales: Slack, Email, Microsoft Teams, Generic Webhook"

validate "notificaciones.md menciona eventos" \
    "grep -qi 'errored\|completed\|needs.attention\|planning' $PROJECT_DIR/notificaciones.md" \
    "Documenta los eventos que disparan notificaciones"

echo ""
echo "================================================"
echo -e "Resultados: ${GREEN}${PASSED} PASS${NC} | ${RED}${FAILED} FAIL${NC}"

if [ $FAILED -eq 0 ] && [ $PASSED -ge 10 ]; then
    echo -e "${GREEN}LABORATORIO COMPLETADO — Badge: HCP Terraform Team Collaboration${NC}"
    echo -e "${GREEN}BOOTCAMP TERRAFORM ASSOCIATE 004 COMPLETADO${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "../../../.badge-tf-m8-lab4"
    exit 0
else
    echo -e "${RED}LABORATORIO INCOMPLETO — revisa los puntos fallidos arriba.${NC}"
    exit 1
fi

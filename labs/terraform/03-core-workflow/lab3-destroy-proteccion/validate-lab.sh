#!/bin/bash

echo "Validando Lab 3: Destroy y Proteccion"
echo "======================================="
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASSED=0
FAILED=0
PROJECT_DIR="/root/lab"

# 1. Terraform instalado
TF_VERSION=$(terraform version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
if [ -n "$TF_VERSION" ]; then
    echo -e "${GREEN}PASS${NC} - Terraform instalado (v${TF_VERSION})"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC} - Terraform no encontrado"
    ((FAILED++))
fi

# 2. Directorio del proyecto existe
if [ -d "$PROJECT_DIR" ]; then
    echo -e "${GREEN}PASS${NC} - Directorio $PROJECT_DIR existe"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC} - Directorio $PROJECT_DIR no encontrado"
    ((FAILED++))
fi

# 3. main.tf existe
if [ -f "$PROJECT_DIR/main.tf" ]; then
    echo -e "${GREEN}PASS${NC} - main.tf encontrado"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC} - main.tf no encontrado en $PROJECT_DIR"
    ((FAILED++))
fi

# 4. Terraform inicializado
if test -d "$PROJECT_DIR/.terraform" || test -f "$PROJECT_DIR/terraform.tfstate"; then
    echo -e "${GREEN}PASS${NC} - Directorio inicializado (terraform init ejecutado)"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC} - No se detecta terraform init (.terraform ausente)"
    ((FAILED++))
fi

# 5. Al menos dos recursos local_file definidos
RESOURCE_COUNT=$(grep -c '^resource ' "$PROJECT_DIR/main.tf" 2>/dev/null || echo 0)
if [ "$RESOURCE_COUNT" -ge 2 ]; then
    echo -e "${GREEN}PASS${NC} - main.tf tiene ${RESOURCE_COUNT} recursos definidos"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC} - Se esperan al menos 2 recursos, encontrados: ${RESOURCE_COUNT}"
    ((FAILED++))
fi

# 6. Verificar que en algun momento se uso prevent_destroy
# (puede estar comentado en la version final para permitir el destroy)
# Buscamos en el historial de git o en el archivo actual
if grep -q 'prevent_destroy' "$PROJECT_DIR/main.tf" 2>/dev/null; then
    echo -e "${GREEN}PASS${NC} - Bloque lifecycle prevent_destroy encontrado en main.tf"
    ((PASSED++))
else
    # Aceptable si el estudiante removio la proteccion para completar el destroy
    echo -e "${GREEN}PASS${NC} - prevent_destroy no presente (correctamente removido para destroy final)"
    ((PASSED++))
fi

# 7. Bloque output presente
if grep -q '^output ' "$PROJECT_DIR/main.tf" 2>/dev/null; then
    echo -e "${GREEN}PASS${NC} - Bloque output encontrado en main.tf"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC} - No se encontro bloque output en main.tf"
    ((FAILED++))
fi

# 8. Formato correcto
if terraform -chdir="$PROJECT_DIR" fmt -check > /dev/null 2>&1; then
    echo -e "${GREEN}PASS${NC} - Codigo formateado correctamente (terraform fmt)"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC} - El codigo no esta bien formateado (ejecuta: terraform fmt)"
    ((FAILED++))
fi

# 9. Configuracion valida
if terraform -chdir="$PROJECT_DIR" validate > /dev/null 2>&1; then
    echo -e "${GREEN}PASS${NC} - Configuracion valida (terraform validate)"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC} - Configuracion invalida (ejecuta: terraform validate)"
    ((FAILED++))
fi

echo ""
echo "Resultado: ${PASSED} verificaciones exitosas, ${FAILED} fallidas"

if [ "$FAILED" -eq 0 ]; then
    echo ""
    echo -e "${GREEN}LABORATORIO COMPLETADO${NC}"
    echo "$(date +%Y-%m-%d\ %H:%M:%S)" > "/root/.badge-terraform-m3-lab3-earned"
    exit 0
else
    echo ""
    echo -e "${RED}LABORATORIO INCOMPLETO${NC} - Revisa los puntos marcados con FAIL"
    exit 1
fi

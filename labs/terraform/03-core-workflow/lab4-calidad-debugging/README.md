# Lab 4: Calidad de Código y Debugging

![Terraform](https://img.shields.io/badge/Terraform-Quality-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Dominar las herramientas de calidad de código y debugging de Terraform.

## ⏱️ Duración
30 minutos

## 📋 Prerrequisitos
- ✅ Lab 3 completado
- Terraform instalado

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear Archivo con Errores

```bash
mkdir lab3-quality
cd lab3-quality

# Crear archivo mal formateado con errores
cat > main.tf << 'EOF'
terraform{
required_version=">= 1.0"
required_providers{
local={
source="hashicorp/local"
version="~> 2.4"
}}}

# Error: referencia a recurso inexistente
resource "local_file" "app" {
name="app.txt"
content="App config"
depends_on=[local_file.nonexistent]
}

# Error: argumento inválido
resource "local_file" "data" {
invalid_argument="value"
}

# Error: tipo de variable incorrecto
variable "count" {
type=number
default="tres"
}

output "file"{
value=local_file.app.filename
}
EOF
```

### Paso 2: Intentar Inicializar

```bash
# Inicializar (puede funcionar)
terraform init
```

### Paso 3: Formatear Código

```bash
# Formatear automáticamente
terraform fmt

# Ver el archivo formateado
cat main.tf

# Ahora está bien formateado pero aún tiene errores lógicos
```

### Paso 4: Validar y Ver Errores

```bash
# Validar configuración
terraform validate

# Output: Múltiples errores
# - Reference to undeclared resource
# - Unsupported argument
# - Invalid default value for variable
```

### Paso 5: Corregir Errores

```bash
# Crear archivo correcto
cat > main.tf << 'EOF'
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# Recurso base
resource "random_id" "server" {
  byte_length = 4
}

# Archivo de aplicación
resource "local_file" "app" {
  filename = "app-${random_id.server.hex}.txt"
  content  = "App config for server ${random_id.server.hex}"
}

# Archivo de datos
resource "local_file" "data" {
  filename = "data.txt"
  content  = "Data file"
}

# Variable correcta
variable "instance_count" {
  type    = number
  default = 3
}

output "app_file" {
  value = local_file.app.filename
}

output "server_id" {
  value = random_id.server.hex
}
EOF
```

### Paso 6: Validar Código Corregido

```bash
# Formatear
terraform fmt

# Validar
terraform validate
# Output: Success! The configuration is valid.

# Verificar formato
terraform fmt -check
# (vacío si todo está bien)
```

### Paso 7: Habilitar Debugging

```bash
# Nivel DEBUG
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Aplicar con logs
terraform apply -auto-approve

# Ver logs
tail -20 terraform.log
```

### Paso 8: Diferentes Niveles de Log

```bash
# TRACE - Más detallado
export TF_LOG=TRACE
terraform plan

# INFO - Información general
export TF_LOG=INFO
terraform plan

# ERROR - Solo errores
export TF_LOG=ERROR
terraform plan

# Deshabilitar logs
unset TF_LOG
unset TF_LOG_PATH
```

### Paso 9: Usar Terraform Console

```bash
# Abrir consola interactiva
terraform console

# Dentro de la consola, prueba:
> random_id.server.hex
> local_file.app.filename
> var.instance_count
> upper("hello terraform")
> length([1, 2, 3, 4, 5])
> join(", ", ["Peru", "Chile", "Colombia"])
> format("Server: %s", random_id.server.hex)
> timestamp()
> formatdate("YYYY-MM-DD", timestamp())
> exit
```

### Paso 10: Crear Script de Validación

```bash
# Crear script para CI/CD
cat > validate.sh << 'EOF'
#!/bin/bash

echo "🔍 Verificando formato..."
if ! terraform fmt -check -recursive; then
  echo "❌ Código no está formateado"
  echo "Ejecuta: terraform fmt -recursive"
  exit 1
fi
echo "✅ Formato correcto"

echo "🔍 Validando configuración..."
if ! terraform validate; then
  echo "❌ Configuración inválida"
  exit 1
fi
echo "✅ Configuración válida"

echo "🔍 Generando plan..."
terraform plan -out=tfplan
echo "✅ Plan generado"

echo "✅ Todas las verificaciones pasaron"
EOF

chmod +x validate.sh

# Ejecutar script
./validate.sh
```

### Paso 11: Limpiar

```bash
terraform destroy -auto-approve
```

### Paso 12: Ejecutar Validación

```bash
cd ..
./validate-lab.sh
```

## 📚 Comandos de Calidad

### Formateo

```bash
# Formatear directorio actual
terraform fmt

# Formatear recursivamente
terraform fmt -recursive

# Solo verificar (no modificar)
terraform fmt -check

# Mostrar diferencias
terraform fmt -diff
```

### Validación

```bash
# Validar configuración
terraform validate

# Validar con output JSON
terraform validate -json
```

### Debugging

```bash
# Niveles de log
export TF_LOG=TRACE   # Más detallado
export TF_LOG=DEBUG   # Debug detallado
export TF_LOG=INFO    # Información general
export TF_LOG=WARN    # Solo warnings
export TF_LOG=ERROR   # Solo errores

# Guardar logs en archivo
export TF_LOG_PATH=terraform.log

# Deshabilitar
unset TF_LOG
unset TF_LOG_PATH
```

### Console Interactivo

```bash
# Abrir console
terraform console

# Probar expresiones
> var.instance_count
> local.server_name
> upper("hello")
> length([1, 2, 3])
```

## 💡 Integración CI/CD

### GitHub Actions

```yaml
name: Terraform Quality

on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      
      - name: Terraform Format
        run: terraform fmt -check -recursive
      
      - name: Terraform Init
        run: terraform init
      
      - name: Terraform Validate
        run: terraform validate
      
      - name: Terraform Plan
        run: terraform plan
```

### Pre-commit Hook

```bash
# .git/hooks/pre-commit
#!/bin/bash

echo "🔍 Running Terraform checks..."

# Format check
if ! terraform fmt -check -recursive; then
  echo "❌ Code is not formatted"
  echo "Run: terraform fmt -recursive"
  exit 1
fi

# Validate
if ! terraform validate; then
  echo "❌ Configuration is invalid"
  exit 1
fi

echo "✅ All checks passed"
```

### Makefile

```makefile
.PHONY: fmt validate plan apply destroy

fmt:
	terraform fmt -recursive

validate:
	terraform validate

plan:
	terraform plan

apply:
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve

check: fmt validate
	@echo "✅ Quality checks passed"
```

## 🔧 Herramientas Complementarias

### TFLint

```bash
# Instalar
brew install tflint

# Ejecutar
tflint

# Con configuración
tflint --config=.tflint.hcl
```

### Checkov (Security Scanner)

```bash
# Instalar
pip install checkov

# Escanear
checkov -d .

# Solo errores críticos
checkov -d . --compact
```

### terraform-docs

```bash
# Instalar
brew install terraform-docs

# Generar documentación
terraform-docs markdown . > README.md
```

## ✅ Criterios de Validación

1. ✅ Código mal formateado corregido con `fmt`
2. ✅ Errores de validación identificados y corregidos
3. ✅ Debugging con logs habilitado
4. ✅ Terraform console explorado
5. ✅ Script de validación creado

## 🎓 Conceptos Aprendidos

- ✅ Formateo automático con `terraform fmt`
- ✅ Validación con `terraform validate`
- ✅ Niveles de logging para debugging
- ✅ Terraform console para testing
- ✅ Integración con CI/CD
- ✅ Pre-commit hooks

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Quality Expert Badge**

---

**Anterior:** [Lab 3 - Protección](../lab3-destroy-proteccion/)  
**Siguiente:** [Módulo 4 - Configuration](../../04-terraform-configuration/)

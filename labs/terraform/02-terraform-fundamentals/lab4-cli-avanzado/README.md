# Lab 4: Terraform CLI Avanzado

![Terraform](https://img.shields.io/badge/Terraform-CLI%20Master-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Dominar los comandos esenciales y avanzados de Terraform CLI para ser más productivo.

## ⏱️ Duración
25 minutos

## 📋 Prerrequisitos
- ✅ Lab 3 completado
- Terraform instalado
- Proyecto del Lab 3 disponible

## 🚀 Instrucciones Paso a Paso

### Paso 1: Usar el Proyecto del Lab 3

```bash
# Ir al proyecto del lab anterior
cd lab2-state

# O crear uno nuevo si lo prefieres
# mkdir lab2-cli && cd lab2-cli
```

### Paso 2: Comandos de Validación y Formato

```bash
# 1. VALIDAR SINTAXIS (sin acceder a providers)
terraform validate

# Output: Success! The configuration is valid.

# 2. FORMATEAR CÓDIGO AUTOMÁTICAMENTE
terraform fmt

# 3. FORMATEAR Y MOSTRAR DIFERENCIAS
terraform fmt -diff

# 4. VERIFICAR SI EL CÓDIGO ESTÁ FORMATEADO
terraform fmt -check

# Si devuelve archivos, necesitan formato
# Si no devuelve nada, todo está bien

# 5. FORMATEAR RECURSIVAMENTE (todos los subdirectorios)
terraform fmt -recursive
```

### Paso 3: Comandos de Plan y Apply

```bash
# 1. PLAN BÁSICO
terraform plan

# 2. PLAN CON SALIDA DETALLADA (guardar en archivo)
terraform plan -out=tfplan

# 3. APLICAR PLAN GUARDADO (sin confirmación)
terraform apply tfplan

# 4. APPLY CON AUTO-APROBACIÓN
terraform apply -auto-approve

# 5. APPLY CON VARIABLE INLINE
terraform apply -var="length=3"

# 6. APPLY CON ARCHIVO DE VARIABLES
# Primero crear terraform.tfvars
echo 'length = 3' > terraform.tfvars
terraform apply -var-file="terraform.tfvars"

# 7. VER PLAN GUARDADO
terraform show tfplan
```

### Paso 4: Comandos de Inspección

```bash
# 1. VER STATE COMPLETO
terraform show

# 2. LISTAR RECURSOS
terraform state list

# 3. VER RECURSO ESPECÍFICO
terraform state show random_pet.server_name

# 4. VER OUTPUTS
terraform output

# 5. VER OUTPUT ESPECÍFICO
terraform output server_info

# 6. OUTPUT EN JSON
terraform output -json

# 7. OUTPUT EN JSON CON JQ
terraform output -json | jq .
```

### Paso 5: Comandos de Refresh

```bash
# 1. ACTUALIZAR STATE SIN MODIFICAR RECURSOS
terraform refresh

# 2. VER QUÉ CAMBIARÍA UN REFRESH
terraform plan -refresh-only

# 3. APLICAR SOLO REFRESH
terraform apply -refresh-only
```

### Paso 6: Comandos de Destroy

```bash
# 1. DESTRUIR TODO (con confirmación)
terraform destroy

# 2. DESTRUIR CON AUTO-APROBACIÓN
terraform destroy -auto-approve

# 3. DESTRUIR RECURSO ESPECÍFICO
terraform destroy -target=random_pet.server_name

# 4. PLAN DE DESTRUCCIÓN
terraform plan -destroy
```

### Paso 7: Workspaces (Múltiples Ambientes)

```bash
# 1. LISTAR WORKSPACES
terraform workspace list

# Output:
# * default

# 2. CREAR WORKSPACE
terraform workspace new desarrollo
terraform workspace new produccion

# 3. CAMBIAR WORKSPACE
terraform workspace select desarrollo

# 4. VER WORKSPACE ACTUAL
terraform workspace show

# 5. APLICAR EN WORKSPACE ESPECÍFICO
terraform workspace select produccion
terraform apply

# Cada workspace tiene su propio state!
```

### Paso 8: Debugging y Logs

```bash
# 1. HABILITAR LOGS DETALLADOS
export TF_LOG=DEBUG
terraform plan

# Niveles: TRACE, DEBUG, INFO, WARN, ERROR

# 2. GUARDAR LOGS EN ARCHIVO
export TF_LOG_PATH=terraform.log
terraform apply

# Ver logs
cat terraform.log

# 3. DESHABILITAR LOGS
unset TF_LOG
unset TF_LOG_PATH

# 4. LOGS SOLO DE UN COMPONENTE
export TF_LOG_CORE=DEBUG
export TF_LOG_PROVIDER=TRACE
```

### Paso 9: Terraform Console (Interactivo)

```bash
# Abrir consola interactiva
terraform console

# Dentro de la consola, prueba:
> random_pet.server_name.id
> random_integer.port.result
> upper("hello terraform")
> length([1, 2, 3, 4, 5])
> join(", ", ["Peru", "Chile", "Colombia"])
> format("Server: %s on port %d", "web", 8080)
> timestamp()
> formatdate("YYYY-MM-DD", timestamp())

# Salir
> exit
```

### Paso 10: Terraform Graph

```bash
# 1. GENERAR GRAFO DE DEPENDENCIAS
terraform graph

# 2. GENERAR GRAFO Y VISUALIZAR CON GRAPHVIZ
# (requiere instalar graphviz: brew install graphviz)
terraform graph | dot -Tpng > graph.png

# Abrir imagen
open graph.png  # macOS
xdg-open graph.png  # Linux

# 3. GRAFO EN FORMATO SVG
terraform graph | dot -Tsvg > graph.svg
```

### Paso 11: Comandos de Providers

```bash
# 1. LISTAR PROVIDERS USADOS
terraform providers

# Output:
# Providers required by configuration:
# .
# ├── provider[registry.terraform.io/hashicorp/random] ~> 3.5
# └── provider[registry.terraform.io/hashicorp/local] ~> 2.4

# 2. VER SCHEMA DE PROVIDERS
terraform providers schema -json | jq .

# 3. VER SCHEMA DE UN PROVIDER ESPECÍFICO
terraform providers schema -json | jq '.provider_schemas["registry.terraform.io/hashicorp/random"]'
```

### Paso 12: Variables de Entorno

```bash
# 1. VARIABLES DE TERRAFORM
export TF_LOG=DEBUG              # Nivel de logging
export TF_LOG_PATH=terraform.log # Archivo de log
export TF_INPUT=false            # Deshabilitar input interactivo
export TF_CLI_ARGS_plan="-compact-warnings"  # Args para plan

# 2. VARIABLES DE INPUT (prefijo TF_VAR_)
export TF_VAR_region=us-west-2
export TF_VAR_instance_count=5

# En tu código:
variable "region" {}
variable "instance_count" {}
# Terraform usa automáticamente TF_VAR_region y TF_VAR_instance_count

# 3. LIMPIAR VARIABLES
unset TF_LOG
unset TF_LOG_PATH
unset TF_VAR_region
```

### Paso 13: Crear Cheatsheet

Crea un archivo `terraform-cheatsheet.md`:

```markdown
# Terraform CLI Cheatsheet

## Workflow Básico

\`\`\`bash
terraform init      # Inicializar directorio
terraform validate  # Validar sintaxis
terraform fmt       # Formatear código
terraform plan      # Ver cambios
terraform apply     # Aplicar cambios
terraform destroy   # Destruir todo
\`\`\`

## Inspección

\`\`\`bash
terraform show              # Ver state completo
terraform state list        # Listar recursos
terraform state show RES    # Ver recurso específico
terraform output            # Ver outputs
terraform providers         # Ver providers
\`\`\`

## Debugging

\`\`\`bash
terraform console           # Consola interactiva
terraform graph             # Grafo de dependencias
export TF_LOG=DEBUG         # Logs detallados
terraform validate          # Validar configuración
\`\`\`

## Gestión de State

\`\`\`bash
terraform refresh           # Actualizar state
terraform state mv SRC DST  # Mover recurso
terraform state rm RES      # Remover del state
terraform import ADDR ID    # Importar recurso existente
\`\`\`

## Workspaces

\`\`\`bash
terraform workspace list    # Listar workspaces
terraform workspace new DEV # Crear workspace
terraform workspace select  # Cambiar workspace
terraform workspace show    # Ver actual
\`\`\`

## Flags Útiles

\`\`\`bash
-auto-approve              # Sin confirmación
-var="key=value"           # Variable inline
-var-file="file.tfvars"    # Archivo de variables
-out=tfplan                # Guardar plan
-target=resource           # Recurso específico
-refresh-only              # Solo refresh
-json                      # Output en JSON
-compact-warnings          # Warnings compactos
\`\`\`

## Variables de Entorno

\`\`\`bash
TF_LOG=DEBUG               # Nivel de log
TF_LOG_PATH=file.log       # Archivo de log
TF_VAR_name=value          # Variable de input
TF_INPUT=false             # Sin input interactivo
\`\`\`

## Alias Útiles

\`\`\`bash
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfd="terraform destroy"
alias tfo="terraform output"
alias tfs="terraform state list"
\`\`\`
```

### Paso 14: Ejecutar Validación

```bash
cd ..
./validate-lab.sh
```

## 📚 Comandos por Categoría

### Inicialización

| Comando | Descripción |
|---------|-------------|
| `terraform init` | Inicializar directorio |
| `terraform init -upgrade` | Actualizar providers |
| `terraform init -reconfigure` | Reconfigurar backend |

### Validación

| Comando | Descripción |
|---------|-------------|
| `terraform validate` | Validar sintaxis |
| `terraform fmt` | Formatear código |
| `terraform fmt -check` | Verificar formato |

### Planificación

| Comando | Descripción |
|---------|-------------|
| `terraform plan` | Ver cambios |
| `terraform plan -out=file` | Guardar plan |
| `terraform plan -destroy` | Plan de destrucción |

### Aplicación

| Comando | Descripción |
|---------|-------------|
| `terraform apply` | Aplicar cambios |
| `terraform apply -auto-approve` | Sin confirmación |
| `terraform apply tfplan` | Aplicar plan guardado |

### Destrucción

| Comando | Descripción |
|---------|-------------|
| `terraform destroy` | Destruir todo |
| `terraform destroy -target=RES` | Destruir recurso |
| `terraform destroy -auto-approve` | Sin confirmación |

### Inspección

| Comando | Descripción |
|---------|-------------|
| `terraform show` | Ver state |
| `terraform state list` | Listar recursos |
| `terraform state show RES` | Ver recurso |
| `terraform output` | Ver outputs |

### Debugging

| Comando | Descripción |
|---------|-------------|
| `terraform console` | Consola interactiva |
| `terraform graph` | Grafo de dependencias |
| `TF_LOG=DEBUG` | Logs detallados |

## 💡 Tips y Trucos

### 1. Alias para Productividad

```bash
# Agregar a ~/.bashrc o ~/.zshrc
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply -auto-approve"
alias tfd="terraform destroy -auto-approve"
alias tfo="terraform output"
alias tfs="terraform state list"
alias tfc="terraform console"
```

### 2. Autocompletado

```bash
# Instalar una sola vez
terraform -install-autocomplete

# Reiniciar shell
source ~/.bashrc  # o ~/.zshrc
```

### 3. Pre-commit Hook

```bash
# .git/hooks/pre-commit
#!/bin/bash
terraform fmt -check
terraform validate
```

### 4. Makefile para Comandos Comunes

```makefile
.PHONY: init plan apply destroy

init:
	terraform init

plan:
	terraform plan

apply:
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve

fmt:
	terraform fmt -recursive

validate:
	terraform validate
```

## ✅ Criterios de Validación

1. ✅ Comandos de validación ejecutados
2. ✅ Comandos de inspección probados
3. ✅ Workspaces creados y usados
4. ✅ Debugging con logs habilitado
5. ✅ Terraform console explorado
6. ✅ Cheatsheet creado

## 🎓 Conceptos Aprendidos

- ✅ Comandos esenciales de Terraform
- ✅ Flags útiles para cada comando
- ✅ Workspaces para múltiples ambientes
- ✅ Debugging con TF_LOG
- ✅ Terraform console interactivo
- ✅ Variables de entorno
- ✅ Productividad con alias

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform CLI Master Badge**

---

**Anterior:** [Lab 3 - State](../lab3-terraform-state/)  
**Siguiente:** [Módulo 3 - Core Workflow](../../03-core-workflow/)

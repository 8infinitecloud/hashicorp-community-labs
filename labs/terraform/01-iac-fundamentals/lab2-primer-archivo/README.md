# Lab 2: Tu Primer Archivo Terraform

![Terraform](https://img.shields.io/badge/Terraform-First%20File-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Crear tu primer archivo de configuración Terraform y ejecutar los comandos básicos del workflow de Terraform.

## ⏱️ Duración
20 minutos

## 📋 Prerrequisitos
- ✅ Lab 1 completado (Terraform instalado)
- Terminal/línea de comandos
- Editor de texto (VS Code, Sublime, nano, vim, etc.)

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear el Directorio del Proyecto

```bash
# Crear directorio para el proyecto
mkdir mi-primer-terraform
cd mi-primer-terraform

# Verificar que estás en el directorio correcto
pwd
```

### Paso 2: Crear el Archivo main.tf

Crea un archivo llamado `main.tf` con el siguiente contenido:

```hcl
# main.tf
terraform {
  required_version = ">= 1.0"
}

# Output simple
output "hello_world" {
  value = "¡Hola desde Terraform!"
}

# Output con información del workspace
output "workspace_info" {
  value = "Workspace actual: ${terraform.workspace}"
}

# Variable local
locals {
  project_name = "Mi Primer Proyecto"
  environment  = "desarrollo"
  created_by   = "Peru HUG"
  timestamp    = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
}

output "project_info" {
  value = "${local.project_name} - ${local.environment}"
}

output "metadata" {
  value = {
    project     = local.project_name
    environment = local.environment
    created_by  = local.created_by
    created_at  = local.timestamp
  }
}
```

### Paso 3: Inicializar Terraform

```bash
# Inicializar el directorio de trabajo
terraform init

# Salida esperada:
# Terraform has been successfully initialized!
```

**¿Qué hace `terraform init`?**
- Descarga providers necesarios
- Inicializa el backend
- Prepara el directorio de trabajo
- Crea el directorio `.terraform/`

### Paso 4: Validar la Configuración

```bash
# Validar sintaxis y configuración
terraform validate

# Salida esperada:
# Success! The configuration is valid.
```

### Paso 5: Formatear el Código

```bash
# Formatear el código según estándares de Terraform
terraform fmt

# Ver diferencias sin aplicar cambios
terraform fmt -check
```

### Paso 6: Ver el Plan de Ejecución

```bash
# Ver qué hará Terraform (sin aplicar cambios)
terraform plan

# Salida esperada:
# No changes. Your infrastructure matches the configuration.
```

### Paso 7: Aplicar la Configuración

```bash
# Aplicar la configuración
terraform apply

# Terraform te pedirá confirmación, escribe: yes

# O aplicar sin confirmación
terraform apply -auto-approve
```

**Salida esperada:**
```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

hello_world = "¡Hola desde Terraform!"
metadata = {
  "created_at" = "2026-04-14 23:05:30"
  "created_by" = "Peru HUG"
  "environment" = "desarrollo"
  "project" = "Mi Primer Proyecto"
}
project_info = "Mi Primer Proyecto - desarrollo"
workspace_info = "Workspace actual: default"
```

### Paso 8: Ver los Outputs

```bash
# Ver todos los outputs
terraform output

# Ver un output específico
terraform output hello_world
terraform output project_info

# Ver output en formato JSON
terraform output -json
```

### Paso 9: Inspeccionar el Estado

```bash
# Ver el estado actual
terraform show

# Listar recursos en el estado
terraform state list

# Ver el archivo de estado (no recomendado editarlo manualmente)
cat terraform.tfstate
```

### Paso 10: Ejecutar el Script de Validación

```bash
# Volver al directorio del lab
cd ..

# Ejecutar validación
./validate-lab.sh
```

## 🧪 Experimentos Adicionales

### Experimento 1: Modificar Variables Locales

Modifica el archivo `main.tf` y cambia los valores de `locals`:

```hcl
locals {
  project_name = "Mi Proyecto Modificado"
  environment  = "produccion"
  created_by   = "Tu Nombre"
}
```

Luego ejecuta:
```bash
terraform apply -auto-approve
```

Observa cómo cambian los outputs.

### Experimento 2: Agregar Más Outputs

Agrega nuevos outputs al archivo:

```hcl
output "welcome_message" {
  value = "Bienvenido a ${local.project_name}!"
}

output "environment_info" {
  value = "Estás en el ambiente de ${local.environment}"
}
```

Aplica los cambios:
```bash
terraform apply -auto-approve
```

### Experimento 3: Usar Variables de Entrada

Crea un archivo `variables.tf`:

```hcl
variable "user_name" {
  description = "Nombre del usuario"
  type        = string
  default     = "Desarrollador"
}

variable "app_version" {
  description = "Versión de la aplicación"
  type        = string
  default     = "1.0.0"
}
```

Actualiza `main.tf` para usar las variables:

```hcl
output "user_greeting" {
  value = "Hola ${var.user_name}, versión ${var.app_version}"
}
```

Aplica con valores personalizados:
```bash
terraform apply -var="user_name=Juan" -var="app_version=2.0.0" -auto-approve
```

## ✅ Criterios de Validación

Para completar exitosamente este laboratorio:

1. ✅ Archivo `main.tf` creado correctamente
2. ✅ `terraform init` ejecutado sin errores
3. ✅ `terraform validate` pasa exitosamente
4. ✅ `terraform apply` ejecutado y outputs visibles
5. ✅ Archivo `terraform.tfstate` generado

## 🔧 Troubleshooting

### Error: "Terraform not initialized"

```bash
# Solución: Ejecutar init primero
terraform init
```

### Error: "Invalid syntax"

```bash
# Verificar sintaxis
terraform validate

# Ver detalles del error
terraform fmt -check
```

### Error: "No configuration files"

```bash
# Verificar que estás en el directorio correcto
ls -la

# Debe existir main.tf
```

## 📚 Conceptos Aprendidos

- ✅ Estructura básica de un archivo Terraform
- ✅ Bloque `terraform` para configuración
- ✅ Variables locales con `locals`
- ✅ Outputs para mostrar información
- ✅ Comandos básicos: `init`, `validate`, `fmt`, `plan`, `apply`
- ✅ Archivo de estado `terraform.tfstate`

## 🎓 Comandos Terraform Aprendidos

| Comando | Descripción |
|---------|-------------|
| `terraform init` | Inicializa el directorio de trabajo |
| `terraform validate` | Valida la sintaxis y configuración |
| `terraform fmt` | Formatea el código |
| `terraform plan` | Muestra qué cambios se aplicarán |
| `terraform apply` | Aplica los cambios |
| `terraform output` | Muestra los outputs |
| `terraform show` | Muestra el estado actual |
| `terraform state list` | Lista recursos en el estado |

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform First Configuration Badge**

---

**Anterior:** [Lab 1 - Instalación](../lab1-instalacion/)  
**Siguiente:** [Lab 3 - Infraestructura Local](../lab3-infraestructura-local/)

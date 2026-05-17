# Lab 4: State Migration

![Terraform](https://img.shields.io/badge/Terraform-State_Migration-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Mover y renombrar recursos dentro del state usando `state mv`, y entender cómo migrar el state entre backends sin recrear infraestructura.

## ⏱️ Duración
30 minutos

## 📋 Prerrequisitos
- ✅ Labs 1, 2 y 3 del módulo 06 completados
- Terraform instalado

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear el Proyecto

```bash
mkdir lab4-state-migration
cd lab4-state-migration
```

Crea `main.tf`:

```hcl
terraform {
  required_version = ">= 1.0"
}

# Recursos con nombres "incorrectos" que vamos a refactorizar
resource "local_file" "archivo_viejo" {
  filename = "${path.module}/config.txt"
  content  = "version=1.0\nentorno=dev\n"
}

resource "local_file" "datos_viejo" {
  filename = "${path.module}/datos.txt"
  content  = "usuario=admin\nrol=superuser\n"
}

resource "local_file" "log_viejo" {
  filename = "${path.module}/app.log"
  content  = "INFO: aplicación iniciada\n"
}
```

```bash
terraform init
terraform apply -auto-approve
terraform state list
```

### Paso 2: Renombrar Recursos con state mv

```bash
# PROBLEMA: Los recursos tienen nombres "_viejo" — queremos renombrarlos
# sin destruir y recrear los archivos físicos

# Ver el estado actual
terraform state list
# local_file.archivo_viejo
# local_file.datos_viejo
# local_file.log_viejo

# Mover (renombrar) en el state
terraform state mv local_file.archivo_viejo local_file.config
terraform state mv local_file.datos_viejo   local_file.datos
terraform state mv local_file.log_viejo     local_file.log

# Verificar que los nombres cambiaron
terraform state list
# local_file.config
# local_file.datos
# local_file.log
```

### Paso 3: Actualizar el Código para que Coincida

Actualiza `main.tf` con los nombres nuevos:

```hcl
terraform {
  required_version = ">= 1.0"
}

resource "local_file" "config" {
  filename = "${path.module}/config.txt"
  content  = "version=1.0\nentorno=dev\n"
}

resource "local_file" "datos" {
  filename = "${path.module}/datos.txt"
  content  = "usuario=admin\nrol=superuser\n"
}

resource "local_file" "log" {
  filename = "${path.module}/app.log"
  content  = "INFO: aplicación iniciada\n"
}
```

```bash
# Plan debe mostrar: No changes
# Si hay cambios, el state mv fue incorrecto
terraform plan

# Si no hay cambios, aplicar para confirmar
terraform apply -auto-approve
```

### Paso 4: Mover un Recurso a un Módulo

Crea `modulos/archivos/main.tf`:

```bash
mkdir -p modulos/archivos
```

```hcl
# modulos/archivos/main.tf
variable "prefix" { type = string }

resource "local_file" "log" {
  filename = "${path.module}/output/${var.prefix}-app.log"
  content  = "INFO: log gestionado por módulo\n"
}
```

Actualiza el root `main.tf` para usar el módulo:

```hcl
terraform {
  required_version = ">= 1.0"
}

resource "local_file" "config" {
  filename = "${path.module}/config.txt"
  content  = "version=1.0\nentorno=dev\n"
}

resource "local_file" "datos" {
  filename = "${path.module}/datos.txt"
  content  = "usuario=admin\nrol=superuser\n"
}

module "archivos" {
  source = "./modulos/archivos"
  prefix = "dev"
}
```

```bash
mkdir -p modulos/archivos/output
terraform init   # re-init por nuevo módulo

# Mover el recurso local al módulo en el state
terraform state mv local_file.log module.archivos.local_file.log

# Verificar
terraform state list

# Plan debe ser: No changes (o crear el archivo en nueva ubicación)
terraform plan
terraform apply -auto-approve
```

### Paso 5: Simular Migración de Backend

```bash
# Paso 5a: Respaldar el state actual
cp terraform.tfstate terraform.tfstate.pre-migracion
echo "State respaldado"

# Paso 5b: En un escenario real, cambiarías backend.tf
# y ejecutarías: terraform init -migrate-state
# Terraform pregunta: "Do you want to copy existing state to the new backend?"

# Para simular la pregunta:
echo "En migración real ejecutarías:"
echo "  terraform init -migrate-state"
echo "  > Do you want to copy existing state to the new backend? (yes/no)"
echo "  > yes"
echo "  Terraform copia el state al nuevo backend y borra el local"

# Paso 5c: Verificar integridad post-migración
terraform plan   # debe mostrar: No changes
```

### Paso 6: Ejecutar Validación

```bash
./validate-lab.sh
```

## ✅ Criterios de Validación

1. ✅ `state mv` ejecutado para renombrar recursos
2. ✅ `terraform plan` muestra "No changes" después del mv
3. ✅ Recurso movido al módulo en el state
4. ✅ State respaldado antes de la migración
5. ✅ Integridad del state verificada con `terraform plan`

## 🔧 Troubleshooting

### Error: "Source address not found in state"

```bash
# Verifica el nombre exacto del recurso
terraform state list
# Usa el nombre exacto que aparece ahí
```

### Plan muestra recreación después de state mv

```bash
# El código y el state no coinciden
# Verifica que main.tf usa el nombre nuevo
terraform state show local_file.config
# Compara con el resource en main.tf
```

## 🎓 Conceptos Aprendidos

- ✅ `terraform state mv` para renombrar sin recrear
- ✅ `terraform state mv` para mover recursos a módulos
- ✅ Proceso de migración de backend (`init -migrate-state`)
- ✅ Validar integridad con `terraform plan` (No changes)
- ✅ Importancia de respaldar el state antes de operaciones

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform State Migration Badge**

---

**Anterior:** [Lab 3 - Workspaces](../lab3-workspaces/)
**Siguiente:** [Módulo 07 - Maintain Infrastructure](../../07-maintain-infrastructure/)

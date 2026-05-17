# Lab 1: Refactoring con moved blocks

![Terraform](https://img.shields.io/badge/Terraform-Refactoring-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Refactorizar configuraciones Terraform usando `moved` blocks para renombrar y mover recursos sin recrearlos.

## ⏱️ Duración
30 minutos

## 📋 Prerrequisitos
- ✅ Módulo 06 completado
- Terraform >= 1.1 instalado (para `moved` blocks)

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear la Configuración Original

```bash
mkdir lab1-refactoring
cd lab1-refactoring
```

Crea `main.tf` — configuración inicial "antes del refactor":

```hcl
terraform {
  required_version = ">= 1.1"
}

# Nombres "malos" que queremos mejorar
resource "local_file" "f1" {
  filename = "${path.module}/output/config.json"
  content  = jsonencode({ entorno = "dev", version = "1.0" })
}

resource "local_file" "f2" {
  filename = "${path.module}/output/secretos.txt"
  content  = "db_host=localhost\ndb_port=5432\n"
}

resource "local_file" "f3" {
  filename = "${path.module}/output/inventario.ini"
  content  = "[servidores]\nweb1 ansible_host=10.0.1.1\n"
}
```

```bash
mkdir -p output
terraform init
terraform apply -auto-approve
terraform state list
# local_file.f1
# local_file.f2
# local_file.f3
```

### Paso 2: Refactorizar con moved blocks

Actualiza `main.tf` con los nombres nuevos Y los `moved` blocks:

```hcl
terraform {
  required_version = ">= 1.1"
}

# moved blocks: indican a Terraform que el recurso se renombró
# NO hay que ejecutar terraform state mv manualmente
moved {
  from = local_file.f1
  to   = local_file.config
}

moved {
  from = local_file.f2
  to   = local_file.credenciales
}

moved {
  from = local_file.f3
  to   = local_file.inventario
}

# Recursos con nombres descriptivos
resource "local_file" "config" {
  filename = "${path.module}/output/config.json"
  content  = jsonencode({ entorno = "dev", version = "1.0" })
}

resource "local_file" "credenciales" {
  filename = "${path.module}/output/secretos.txt"
  content  = "db_host=localhost\ndb_port=5432\n"
}

resource "local_file" "inventario" {
  filename = "${path.module}/output/inventario.ini"
  content  = "[servidores]\nweb1 ansible_host=10.0.1.1\n"
}
```

```bash
# Plan DEBE mostrar solo los moved, NO recreaciones
terraform plan

# Si el plan dice "No changes" o solo "moved", está bien
# Si dice "will be destroyed" y "will be created", algo está mal
terraform apply -auto-approve

# Verificar que los archivos siguen existiendo
ls output/
terraform state list
# local_file.config
# local_file.credenciales
# local_file.inventario
```

### Paso 3: Mover un Recurso a un Módulo con moved

Crea `modulos/secretos/main.tf`:

```bash
mkdir -p modulos/secretos
```

```hcl
# modulos/secretos/main.tf
variable "contenido" { type = string }
variable "ruta"      { type = string }

resource "local_file" "archivo" {
  filename = var.ruta
  content  = var.contenido
}
```

Actualiza `main.tf` moviendo `credenciales` al módulo:

```hcl
terraform {
  required_version = ">= 1.1"
}

# moved: mover recurso al módulo
moved {
  from = local_file.credenciales
  to   = module.secretos.local_file.archivo
}

resource "local_file" "config" {
  filename = "${path.module}/output/config.json"
  content  = jsonencode({ entorno = "dev", version = "1.0" })
}

resource "local_file" "inventario" {
  filename = "${path.module}/output/inventario.ini"
  content  = "[servidores]\nweb1 ansible_host=10.0.1.1\n"
}

module "secretos" {
  source    = "./modulos/secretos"
  contenido = "db_host=localhost\ndb_port=5432\n"
  ruta      = "${path.module}/output/secretos.txt"
}
```

```bash
terraform init   # re-init por nuevo módulo
terraform plan   # NO debe recrear el archivo

terraform apply -auto-approve
terraform state list
# local_file.config
# local_file.inventario
# module.secretos.local_file.archivo
```

### Paso 4: Limpiar moved blocks

Una vez que todos los colaboradores del equipo han ejecutado el apply, los `moved` blocks pueden eliminarse:

```bash
# Edita main.tf y elimina todos los bloques moved { ... }
# El state ya tiene los recursos en la ubicación correcta
terraform plan   # debe seguir sin cambios
terraform apply -auto-approve
```

### Paso 5: Ejecutar Validación

```bash
./validate-lab.sh
```

## ✅ Criterios de Validación

1. ✅ `moved` blocks usados para renombrar recursos
2. ✅ `terraform plan` no muestra recreaciones
3. ✅ Archivos físicos intactos después del refactor
4. ✅ Recurso movido a módulo sin recreación
5. ✅ `moved` blocks eliminados al final

## 💡 moved vs state mv

| `moved` block | `terraform state mv` |
|---------------|----------------------|
| Declarativo — en el código | Imperativo — comando manual |
| Se versiona en Git | No deja registro en código |
| Compañeros ejecutan `apply` y migran | Requiere que cada persona ejecute el comando |
| Recomendado para refactors en equipo | Para migraciones urgentes de una sola vez |

## 🎓 Conceptos Aprendidos

- ✅ `moved` blocks para renombrar recursos sin recrear
- ✅ `moved` para mover recursos a módulos
- ✅ Diferencia entre `moved` y `terraform state mv`
- ✅ Cuándo eliminar los `moved` blocks
- ✅ Validar refactors con `terraform plan`

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Refactoring Badge**

---

**Anterior:** [Módulo 06 - State Management](../../06-state-management/)
**Siguiente:** [Lab 2 - Upgrades](../lab2-upgrades/)

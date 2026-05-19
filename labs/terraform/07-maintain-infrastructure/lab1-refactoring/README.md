# Lab 1: Refactoring con moved blocks

![Terraform](https://img.shields.io/badge/Terraform-Refactoring-7B42BC?style=flat&logo=terraform)

## Objetivo
Refactorizar configuraciones Terraform usando `moved` blocks para renombrar y mover recursos sin recrearlos.

## Duracion
30 minutos

## Prerrequisitos
- Modulo 06 completado
- Terraform >= 1.1 instalado (para `moved` blocks)

## Instrucciones Paso a Paso

### Paso 1: Preparar el directorio de trabajo

```bash
mkdir -p /root/lab
cd /root/lab
```

Crea el directorio de salida donde se escribiran los archivos gestionados.

```bash
mkdir -p output
```

Los archivos gestionados por Terraform se guardan en `output/` para mantener el directorio raiz limpio.

### Paso 2: Crear la configuracion inicial (nombres genericos)

```bash
touch main.tf
```

```bash
cat > main.tf <<'EOF'
terraform {
  required_version = ">= 1.1"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
  }
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
EOF
```

Define tres recursos `local_file` con nombres cortos poco descriptivos (`f1`, `f2`, `f3`). Este es el estado inicial "antes del refactor" que vamos a mejorar.

```bash
terraform init
```

```bash
terraform apply -auto-approve
```

```bash
terraform state list
```

`terraform state list` muestra los tres recursos con sus nombres actuales. El objetivo del lab es renombrarlos sin destruir y recrear los archivos.

### Paso 3: Agregar moved blocks y renombrar los recursos

```bash
cat > main.tf <<'EOF'
terraform {
  required_version = ">= 1.1"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
  }
}

# moved blocks: indican a Terraform que el recurso se renombro en el codigo.
# Terraform actualiza el state sin destruir ni recrear el recurso.
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
EOF
```

Cada bloque `moved { from = ... to = ... }` le dice a Terraform que el recurso fue renombrado en el codigo. Terraform actualiza el state internamente sin tocar los archivos fisicos.

```bash
terraform plan
```

El plan debe mostrar solo los `moved` y cero destrucciones. Si ves `will be destroyed` + `will be created`, algo esta mal en los nombres.

```bash
terraform apply -auto-approve
```

```bash
terraform state list
```

Despues del apply el state muestra `local_file.config`, `local_file.credenciales` e `local_file.inventario`. Los archivos fisicos en `output/` no fueron tocados.

### Paso 4: Mover un recurso a un modulo con moved

```bash
mkdir -p modulos/secretos
```

```bash
touch modulos/secretos/main.tf
```

```bash
cat > modulos/secretos/main.tf <<'EOF'
variable "contenido" {
  type        = string
  description = "Contenido del archivo de credenciales"
}

variable "ruta" {
  type        = string
  description = "Ruta absoluta donde se escribe el archivo"
}

resource "local_file" "archivo" {
  filename = var.ruta
  content  = var.contenido
}
EOF
```

El modulo `secretos` encapsula la logica de crear un archivo de credenciales. Al extraerlo a un modulo, otros proyectos pueden reutilizarlo.

```bash
cat > main.tf <<'EOF'
terraform {
  required_version = ">= 1.1"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
  }
}

# moved: mueve el recurso existente al modulo sin recrearlo
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
EOF
```

El bloque `moved` con `to = module.secretos.local_file.archivo` mueve la entrada del state al namespace del modulo. Terraform no eliminara ni recreara el archivo fisico en disco.

```bash
terraform init
```

```bash
terraform plan
```

```bash
terraform apply -auto-approve
```

```bash
terraform state list
```

El state ahora muestra `module.secretos.local_file.archivo` en lugar de `local_file.credenciales`. El archivo `output/secretos.txt` permanece intacto.

### Paso 5: Eliminar los moved blocks (limpieza)

Una vez que todos los colaboradores han ejecutado el apply, los `moved` blocks se pueden eliminar del codigo sin efecto en el state.

```bash
cat > main.tf <<'EOF'
terraform {
  required_version = ">= 1.1"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
  }
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
EOF
```

```bash
terraform plan
```

El plan debe mostrar `No changes`. Los `moved` blocks solo son necesarios durante la transicion; una vez que el state refleja la nueva ubicacion, son redundantes.

```bash
terraform apply -auto-approve
```

### Paso 6: Ejecutar validacion

```bash
cd /root/lab
```

```bash
bash validate-lab.sh
```

## Criterios de Validacion

1. `moved` blocks usados para renombrar recursos
2. `terraform plan` no muestra recreaciones
3. Archivos fisicos intactos despues del refactor
4. Recurso movido a modulo sin recreacion
5. `moved` blocks eliminados al final

## moved vs terraform state mv

| `moved` block | `terraform state mv` |
|---|---|
| Declarativo — en el codigo | Imperativo — comando manual |
| Se versiona en Git | No deja registro en codigo |
| Compañeros ejecutan `apply` y migran automaticamente | Requiere que cada persona ejecute el comando |
| Recomendado para refactors en equipo | Para migraciones urgentes de una sola vez |

## Conceptos Aprendidos

- `moved` blocks para renombrar recursos sin recrear
- `moved` para mover recursos a modulos
- Diferencia entre `moved` y `terraform state mv`
- Cuando eliminar los `moved` blocks
- Validar refactors con `terraform plan`

---

**Anterior:** [Modulo 06 - State Management](../../06-state-management/)
**Siguiente:** [Lab 2 - Upgrades](../lab2-upgrades/)

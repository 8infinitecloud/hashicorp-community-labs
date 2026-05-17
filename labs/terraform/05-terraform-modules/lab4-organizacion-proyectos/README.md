# Lab 4: Organización de Proyectos

![Terraform](https://img.shields.io/badge/Terraform-Project_Structure-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Estructurar proyectos Terraform escalables con múltiples módulos y entornos separados (dev/staging/prod).

## ⏱️ Duración
30 minutos

## 📋 Prerrequisitos
- ✅ Labs 1, 2 y 3 del módulo 05 completados
- Terraform instalado

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear la Estructura Multi-Entorno

```bash
mkdir lab4-organizacion-proyectos
cd lab4-organizacion-proyectos

# Estructura de módulos
mkdir -p modules/red
mkdir -p modules/aplicacion
mkdir -p modules/base-datos

# Estructura de entornos
mkdir -p entornos/dev
mkdir -p entornos/staging
mkdir -p entornos/prod
```

### Paso 2: Módulo de Red

Crea `modules/red/main.tf`:

```hcl
# modules/red/main.tf

variable "entorno"  { type = string }
variable "vpc_cidr" { type = string }

locals {
  nombre_red = "vpc-${var.entorno}"
  subnets    = [
    cidrsubnet(var.vpc_cidr, 8, 0),
    cidrsubnet(var.vpc_cidr, 8, 1),
  ]
}

resource "local_file" "vpc" {
  filename = "${path.module}/output/vpc-${var.entorno}.tf.json"
  content  = jsonencode({
    vpc    = local.nombre_red
    cidr   = var.vpc_cidr
    subnets = local.subnets
  })
}

output "vpc_id"   { value = local.nombre_red }
output "subnets"  { value = local.subnets }
```

### Paso 3: Módulo de Aplicación

Crea `modules/aplicacion/main.tf`:

```hcl
# modules/aplicacion/main.tf

variable "entorno"   { type = string }
variable "vpc_id"    { type = string }
variable "subnets"   { type = list(string) }
variable "instancias" {
  type    = number
  default = 1
}

resource "local_file" "app" {
  filename = "${path.module}/output/app-${var.entorno}.conf"
  content  = <<-EOT
    entorno   = ${var.entorno}
    vpc       = ${var.vpc_id}
    instancias = ${var.instancias}
    subnets   = ${join(", ", var.subnets)}
  EOT
}

output "app_endpoint" {
  value = "https://app-${var.entorno}.peru-hug.local"
}
```

### Paso 4: Configuración del Entorno Dev

Crea `entornos/dev/main.tf`:

```hcl
# entornos/dev/main.tf

terraform {
  required_version = ">= 1.0"
}

locals {
  entorno = "dev"
}

module "red" {
  source   = "../../modules/red"
  entorno  = local.entorno
  vpc_cidr = "10.0.0.0/16"
}

module "aplicacion" {
  source     = "../../modules/aplicacion"
  entorno    = local.entorno
  vpc_id     = module.red.vpc_id
  subnets    = module.red.subnets
  instancias = 1
}

output "endpoint" {
  value = module.aplicacion.app_endpoint
}
```

### Paso 5: Configuración del Entorno Prod

Crea `entornos/prod/main.tf`:

```hcl
# entornos/prod/main.tf

terraform {
  required_version = ">= 1.0"
}

locals {
  entorno = "prod"
}

module "red" {
  source   = "../../modules/red"
  entorno  = local.entorno
  vpc_cidr = "10.1.0.0/16"
}

module "aplicacion" {
  source     = "../../modules/aplicacion"
  entorno    = local.entorno
  vpc_id     = module.red.vpc_id
  subnets    = module.red.subnets
  instancias = 3
}

output "endpoint" {
  value = module.aplicacion.app_endpoint
}
```

### Paso 6: Crear Directorios de Output y Aplicar por Entorno

```bash
mkdir -p modules/red/output modules/aplicacion/output

# --- Entorno Dev ---
cd entornos/dev
terraform init
terraform apply -auto-approve
terraform output endpoint

# --- Entorno Prod ---
cd ../prod
terraform init
terraform apply -auto-approve
terraform output endpoint

# Volver a la raíz
cd ../..
```

### Paso 7: Comparar los Entornos

```bash
# Ver configuraciones generadas
cat modules/red/output/vpc-dev.tf.json
cat modules/red/output/vpc-prod.tf.json

cat modules/aplicacion/output/app-dev.conf
cat modules/aplicacion/output/app-prod.conf
```

Observa cómo el mismo módulo genera configuraciones distintas según el entorno.

### Paso 8: Ejecutar Validación

```bash
./validate-lab.sh
```

## ✅ Criterios de Validación

1. ✅ Estructura `modules/` con al menos 2 módulos
2. ✅ Estructura `entornos/` con dev y prod independientes
3. ✅ Cada entorno tiene su propio state
4. ✅ Módulos reciben parámetros distintos por entorno
5. ✅ Outputs correctos en cada entorno

## 🎓 Conceptos Aprendidos

- ✅ Separación de módulos reutilizables y configuraciones de entorno
- ✅ Rutas relativas para source de módulos (`../../modules/X`)
- ✅ States independientes por entorno
- ✅ Pasar outputs de un módulo como inputs de otro
- ✅ Convención de directorios para proyectos reales

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Project Organization Badge**

---

**Anterior:** [Lab 3 - Módulos Avanzados](../lab3-modulos-avanzados/)
**Siguiente:** [Módulo 06 - State Management](../../06-state-management/)

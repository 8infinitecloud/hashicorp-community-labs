# Lab 2: Módulos del Registry

![Terraform](https://img.shields.io/badge/Terraform-Registry_Modules-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Usar módulos del Terraform Registry: encontrarlos, leer su documentación, instalarlos con versión fija y usarlos en tu proyecto — sin necesidad de credenciales cloud.

## ⏱️ Duración
25 minutos

## 📋 Prerrequisitos
- ✅ Lab 1 del módulo 05 completado
- Terraform instalado
- Conexión a internet (para descargar módulos del Registry)

## 🚀 Instrucciones Paso a Paso

### Paso 1: Navegar el Terraform Registry

```bash
# Abre en el browser (opcional — también puedes seguir el README)
# https://registry.terraform.io/
#
# Estructura de un módulo en el Registry:
# registry.terraform.io/<NAMESPACE>/<MODULO>/<PROVIDER>
#
# Ejemplos:
# registry.terraform.io/hashicorp/dir/template     → genera estructura de directorios
# registry.terraform.io/cloudposse/label/null      → genera etiquetas/tags estándar
# registry.terraform.io/terraform-aws-modules/vpc/aws → crea VPCs en AWS (requiere credenciales)
#
# Para este lab usamos "hashicorp/dir/template" y el provider "random"
# porque NO requieren credenciales cloud.
```

### Paso 2: Crear el Proyecto

```bash
mkdir lab2-registry-modules
cd lab2-registry-modules
```

### Paso 3: Usar el Provider Random desde el Registry

El provider `hashicorp/random` genera valores aleatorios — es un excelente ejemplo de módulo del Registry porque:
- No necesita credenciales
- Descarga desde registry.terraform.io automáticamente
- Muestra el flujo completo: source → init → apply

Crea `main.tf`:

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    random = {
      source  = "hashicorp/random"   # ← viene del Terraform Registry
      version = "~> 3.6"             # ← versión fija: 3.6.x
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Recurso del provider random
resource "random_id" "proyecto" {
  byte_length = 8
}

resource "random_pet" "nombre_servidor" {
  length    = 2
  separator = "-"
}

resource "random_integer" "puerto" {
  min = 8000
  max = 9000
}

resource "random_password" "secreto" {
  length           = 16
  special          = true
  override_special = "!#$%"
}

# Usar los valores generados en un archivo de config
resource "local_file" "config_app" {
  filename = "${path.module}/config-generada.txt"
  content  = <<-EOT
    # Configuración generada por Terraform Registry (random provider)
    # ---------------------------------------------------------------
    app_id    = ${random_id.proyecto.hex}
    servidor  = ${random_pet.nombre_servidor.id}
    puerto    = ${random_integer.puerto.result}
    secreto   = ${random_password.secreto.result}
  EOT
}

output "app_id"   { value = random_id.proyecto.hex }
output "servidor" { value = random_pet.nombre_servidor.id }
output "puerto"   { value = random_integer.puerto.result }
```

### Paso 4: Inicializar — Terraform descarga del Registry

```bash
# Terraform lee los 'source' y descarga los providers del Registry
terraform init

# Verás:
# Initializing provider plugins...
# - Finding hashicorp/random versions matching "~> 3.6"...
# - Finding hashicorp/local versions matching "~> 2.0"...
# - Installing hashicorp/random v3.6.x...
# - Installing hashicorp/local v2.x.x...

# Ver qué se descargó
cat .terraform.lock.hcl   # versiones exactas instaladas
ls .terraform/providers/  # binarios descargados
```

### Paso 5: Aplicar

```bash
terraform plan
terraform apply -auto-approve

# Ver los valores generados
cat config-generada.txt
terraform output
```

Cada `terraform apply` genera valores DIFERENTES excepto para recursos marcados como `keep_providers`.

```bash
# Destruir y re-crear para ver valores nuevos
terraform destroy -auto-approve
terraform apply -auto-approve
cat config-generada.txt   # valores distintos
```

### Paso 6: Entender el Patrón de Módulo del Registry

Los módulos son agrupaciones de recursos. Crea un módulo local que imita el patrón:

```bash
mkdir -p modules/identificador
```

Crea `modules/identificador/main.tf`:

```hcl
# modules/identificador/main.tf
# Módulo que genera identificadores únicos para un servicio

terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

variable "servicio" {
  type        = string
  description = "Nombre del servicio"
}

variable "entorno" {
  type        = string
  description = "Entorno: dev, staging, prod"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.entorno)
    error_message = "entorno debe ser dev, staging o prod"
  }
}

resource "random_id" "id" {
  byte_length = 4
}

resource "random_pet" "alias" {
  length = 1
}

output "id_completo" {
  value       = "${var.entorno}-${var.servicio}-${random_id.id.hex}"
  description = "Identificador único del servicio"
}

output "alias" {
  value       = "${var.servicio}-${random_pet.alias.id}"
  description = "Alias legible del servicio"
}
```

Actualiza `main.tf` para usar el módulo:

```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

module "id_web" {
  source   = "./modules/identificador"
  servicio = "web"
  entorno  = "prod"
}

module "id_api" {
  source   = "./modules/identificador"
  servicio = "api"
  entorno  = "staging"
}

resource "local_file" "inventario" {
  filename = "${path.module}/inventario.txt"
  content  = <<-EOT
    web  → ${module.id_web.id_completo}  (alias: ${module.id_web.alias})
    api  → ${module.id_api.id_completo}  (alias: ${module.id_api.alias})
  EOT
}

output "inventario" {
  value = {
    web = module.id_web.id_completo
    api = module.id_api.id_completo
  }
}
```

```bash
terraform init   # re-init por nuevo módulo
terraform apply -auto-approve
cat inventario.txt
terraform output inventario
```

### Paso 7: Cómo se Usaría un Módulo Real del Registry

```bash
# En proyectos reales con cloud, usarías:
cat > ejemplo-aws-no-ejecutar.tf.referencia << 'EOF'
# Este código es REFERENCIA — requiere credenciales AWS
# Lo ejecutarías en tu entorno con AWS configurado

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"   # ← del Registry
  version = "5.8.0"                            # ← versión fija

  name = "mi-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = { Terraform = "true", Environment = "dev" }
}

output "vpc_id" { value = module.vpc.vpc_id }
EOF

echo "Patrón idéntico al módulo local — solo cambia el source"
```

### Paso 8: Ejecutar Validación

```bash
./validate-lab.sh
```

## ✅ Criterios de Validación

1. ✅ `hashicorp/random` descargado del Registry con `terraform init`
2. ✅ `.terraform.lock.hcl` generado con versiones fijas
3. ✅ Recursos `random_id`, `random_pet`, `random_integer` aplicados
4. ✅ Módulo local creado con `source = "./modules/identificador"`
5. ✅ Módulo usado dos veces con parámetros distintos

## 💡 Diferencia: Provider vs Módulo

| | Provider | Módulo |
|---|---|---|
| **Qué es** | Plugin que habla con una API (AWS, GCP…) | Conjunto reutilizable de recursos |
| **Fuente** | `required_providers { source = "..." }` | `module { source = "..." }` |
| **Registry URL** | `registry.terraform.io/providers/hashicorp/random` | `registry.terraform.io/modules/namespace/nombre/provider` |
| **Ejemplo** | `hashicorp/random` | `terraform-aws-modules/vpc/aws` |

## 🎓 Conceptos Aprendidos

- ✅ Estructura de una fuente del Registry: `namespace/nombre/provider`
- ✅ `required_providers` con `source` y `version`
- ✅ `terraform init` descarga providers y módulos del Registry
- ✅ `.terraform.lock.hcl` fija las versiones exactas
- ✅ Patrón `module { source = "..." }` es el mismo para local y Registry

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Registry Expert Badge**

---

**Anterior:** [Lab 1 - Tu Primer Módulo](../lab1-primer-modulo/)
**Siguiente:** [Lab 3 - Módulos Avanzados](../lab3-modulos-avanzados/)

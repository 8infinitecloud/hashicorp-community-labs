# Lab 2: Módulos del Registry

![Terraform](https://img.shields.io/badge/Terraform-Registry_Modules-7B42BC?style=flat&logo=terraform)

## Objetivo

Usar módulos del Terraform Registry: encontrarlos, instalarlos con versión fija y consumirlos en tu proyecto, sin necesidad de credenciales cloud.

## Duración

25 minutos

## Prerrequisitos

- Lab 1 del módulo 05 completado
- Terraform instalado
- Conexión a internet (para descargar providers del Registry)

## Instrucciones Paso a Paso

### Paso 1: Preparar el Directorio de Trabajo

```bash
mkdir -p /root/lab
```

Todo el trabajo de este lab se hace dentro de `/root/lab`. El provider `hashicorp/random` genera valores aleatorios y no requiere credenciales cloud, lo que lo hace ideal para aprender el flujo del Registry.

### Paso 2: Crear la Configuración Principal

```bash
touch /root/lab/main.tf
cat > /root/lab/main.tf <<'EOF'
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

resource "local_file" "config_app" {
  filename = "${path.module}/config-generada.txt"
  content  = <<-EOT
    # Configuracion generada por Terraform (random provider)
    app_id   = ${random_id.proyecto.hex}
    servidor = ${random_pet.nombre_servidor.id}
    puerto   = ${random_integer.puerto.result}
    secreto  = ${random_password.secreto.result}
  EOT
}

output "app_id"   { value = random_id.proyecto.hex }
output "servidor" { value = random_pet.nombre_servidor.id }
output "puerto"   { value = random_integer.puerto.result }
EOF
```

El bloque `required_providers` le indica a Terraform que descargue `hashicorp/random` y `hashicorp/local` desde `registry.terraform.io`. La versión `~> 3.6` permite actualizaciones de parche (3.6.x) pero no de minor.

### Paso 3: Inicializar — Terraform Descarga del Registry

```bash
cd /root/lab && terraform init
```

`terraform init` lee los `source` declarados en `required_providers` y descarga los binarios correspondientes desde `registry.terraform.io`. Al finalizar crea `.terraform.lock.hcl` con los checksums exactos de cada versión instalada.

### Paso 4: Verificar el Lock File

```bash
cat /root/lab/.terraform.lock.hcl
```

El lock file fija las versiones exactas y sus checksums. Commitearlo en el repositorio garantiza que todos los miembros del equipo usen exactamente la misma versión del provider, sin importar cuándo ejecuten `terraform init`.

### Paso 5: Aplicar y Ver los Valores Generados

```bash
cd /root/lab && terraform apply -auto-approve
```

Crea los recursos `random_*` y el archivo de configuración. Cada ejecución sin state previo genera valores distintos, porque los providers `random` crean datos nuevos cada vez.

```bash
cat /root/lab/config-generada.txt
```

Muestra el archivo de configuración con los valores aleatorios generados. Esto simula el patrón real donde Terraform genera IDs, contraseñas y nombres de recursos de forma automática.

```bash
cd /root/lab && terraform output
```

Muestra los tres outputs definidos: `app_id`, `servidor` y `puerto`. Los outputs permiten que otros módulos o pipelines de CI/CD consuman valores generados por Terraform.

### Paso 6: Crear el Módulo Local — Estructura

```bash
mkdir -p /root/lab/modules/identificador
touch /root/lab/modules/identificador/main.tf
cat > /root/lab/modules/identificador/main.tf <<'EOF'
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
  description = "Identificador unico del servicio"
}

output "alias" {
  value       = "${var.servicio}-${random_pet.alias.id}"
  description = "Alias legible del servicio"
}
EOF
```

Este módulo encapsula la lógica de generación de identificadores únicos: recibe el nombre del servicio y el entorno como entrada, y devuelve un ID técnico y un alias legible. El bloque `validation` rechaza entornos no reconocidos antes de crear recursos.

### Paso 7: Actualizar main.tf para Usar el Módulo

```bash
cat > /root/lab/main.tf <<'EOF'
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
    web -> ${module.id_web.id_completo}  (alias: ${module.id_web.alias})
    api -> ${module.id_api.id_completo}  (alias: ${module.id_api.alias})
  EOT
}

output "inventario" {
  value = {
    web = module.id_web.id_completo
    api = module.id_api.id_completo
  }
}
EOF
```

El `main.tf` actualizado instancia el módulo `identificador` dos veces con parámetros distintos. Los outputs del módulo se referencian con `module.<nombre>.<output>` para construir el inventario final.

### Paso 8: Re-inicializar y Aplicar con el Módulo

```bash
cd /root/lab && terraform init
```

Siempre ejecuta `terraform init` después de agregar un nuevo módulo o cambiar su `source`. Terraform registra el módulo local y descarga cualquier provider adicional que declare.

```bash
cd /root/lab && terraform apply -auto-approve
```

Crea los recursos de ambas instancias del módulo y el archivo `inventario.txt`. El estado agrupa los recursos bajo `module.id_web.*` y `module.id_api.*` respectivamente.

```bash
cat /root/lab/inventario.txt
```

Muestra el inventario con los identificadores únicos generados para cada servicio. Este patrón se usa en proyectos reales para generar nombres de recursos cloud sin colisiones.

```bash
cd /root/lab && terraform output inventario
```

Muestra el mapa de outputs con los IDs completos de web y api. Los outputs de tipo `map` son útiles para pasar múltiples valores a módulos descendientes o a pipelines externos.

### Paso 9: Validar el Laboratorio

```bash
cd /root/lab
bash validate-lab.sh
```

---

## Criterios de Validacion

1. `hashicorp/random` descargado del Registry con `terraform init`
2. `.terraform.lock.hcl` generado con versiones fijas
3. Recursos `random_id`, `random_pet`, `random_integer` aplicados
4. Módulo local `modules/identificador/` creado con `main.tf`
5. El `main.tf` raíz usa el módulo al menos dos veces

## Diferencia: Provider vs Módulo

| | Provider | Módulo |
|---|---|---|
| Qué es | Plugin que habla con una API | Conjunto reutilizable de recursos |
| Fuente | `required_providers { source = "..." }` | `module { source = "..." }` |
| Ejemplo | `hashicorp/random` | `terraform-aws-modules/vpc/aws` |

## Conceptos Aprendidos

- Estructura de una fuente del Registry: `namespace/nombre/provider`
- `required_providers` con `source` y `version`
- `terraform init` descarga providers del Registry
- `.terraform.lock.hcl` fija las versiones exactas
- El patrón `module { source = "..." }` es el mismo para local y Registry

---

**Anterior:** [Lab 1 - Tu Primer Módulo](../lab1-primer-modulo/)
**Siguiente:** [Lab 3 - Módulos Avanzados](../lab3-modulos-avanzados/)

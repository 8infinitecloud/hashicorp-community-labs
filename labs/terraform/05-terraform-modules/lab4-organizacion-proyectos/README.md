# Lab 4: Organización de Proyectos

![Terraform](https://img.shields.io/badge/Terraform-Project_Structure-7B42BC?style=flat&logo=terraform)

## Objetivo

Estructurar proyectos Terraform escalables con múltiples módulos reutilizables y entornos separados (dev/prod), cada uno con su propio estado independiente.

## Duración

30 minutos

## Prerrequisitos

- Labs 1, 2 y 3 del módulo 05 completados
- Terraform instalado

## Instrucciones Paso a Paso

### Paso 1: Crear la Estructura Completa del Proyecto

```bash
mkdir -p /root/lab/modules/red
mkdir -p /root/lab/modules/aplicacion
mkdir -p /root/lab/modules/red/output
mkdir -p /root/lab/modules/aplicacion/output
mkdir -p /root/lab/entornos/dev
mkdir -p /root/lab/entornos/prod
```

La estructura separa los módulos reutilizables (en `modules/`) de las configuraciones de entorno (en `entornos/`). Cada entorno tiene su propio directorio con su propio estado, lo que permite aplicar cambios en dev sin afectar prod.

### Paso 2: Crear el Módulo de Red — main.tf

```bash
touch /root/lab/modules/red/main.tf
cat > /root/lab/modules/red/main.tf <<'EOF'
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

variable "entorno" {
  type        = string
  description = "Nombre del entorno (dev, staging, prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "Bloque CIDR de la VPC"
}

locals {
  nombre_red = "vpc-${var.entorno}"
  subnets = [
    cidrsubnet(var.vpc_cidr, 8, 0),
    cidrsubnet(var.vpc_cidr, 8, 1),
  ]
}

resource "local_file" "vpc" {
  filename = "${path.module}/output/vpc-${var.entorno}.json"
  content = jsonencode({
    vpc     = local.nombre_red
    cidr    = var.vpc_cidr
    subnets = local.subnets
  })
}

output "vpc_id"  { value = local.nombre_red }
output "subnets" { value = local.subnets }
EOF
```

El módulo de red simula la creación de una VPC calculando subnets con `cidrsubnet`. Devuelve el nombre de la VPC y la lista de subnets como outputs, para que el módulo de aplicación pueda consumirlos.

### Paso 3: Crear el Módulo de Aplicación — main.tf

```bash
touch /root/lab/modules/aplicacion/main.tf
cat > /root/lab/modules/aplicacion/main.tf <<'EOF'
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

variable "entorno" {
  type        = string
  description = "Nombre del entorno"
}

variable "vpc_id" {
  type        = string
  description = "ID de la VPC donde se despliega la aplicacion"
}

variable "subnets" {
  type        = list(string)
  description = "Lista de subnets disponibles"
}

variable "instancias" {
  type        = number
  description = "Numero de instancias de la aplicacion"
  default     = 1
}

resource "local_file" "app" {
  filename = "${path.module}/output/app-${var.entorno}.conf"
  content  = <<-EOT
    entorno    = ${var.entorno}
    vpc        = ${var.vpc_id}
    instancias = ${var.instancias}
    subnets    = ${join(", ", var.subnets)}
  EOT
}

output "app_endpoint" {
  value = "https://app-${var.entorno}.peru-hug.local"
}
EOF
```

El módulo de aplicación recibe los outputs del módulo de red (`vpc_id` y `subnets`) como inputs. Esto establece una dependencia implícita entre módulos: la aplicación depende de la red. En infraestructura real, aquí irían los recursos de compute (EC2, ECS, etc.).

### Paso 4: Crear la Configuración del Entorno Dev

```bash
touch /root/lab/entornos/dev/main.tf
cat > /root/lab/entornos/dev/main.tf <<'EOF'
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
EOF
```

El entorno dev usa el CIDR `10.0.0.0/16` y una sola instancia. Los paths relativos `../../modules/red` apuntan a los módulos compartidos desde el directorio del entorno.

### Paso 5: Crear la Configuración del Entorno Prod

```bash
touch /root/lab/entornos/prod/main.tf
cat > /root/lab/entornos/prod/main.tf <<'EOF'
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
EOF
```

El entorno prod usa un CIDR distinto (`10.1.0.0/16`) y 3 instancias. Mismo código de módulos, parámetros diferentes — este es el objetivo de la modularización.

### Paso 6: Inicializar y Aplicar el Entorno Dev

```bash
terraform -chdir=/root/lab/entornos/dev init
```

Cada entorno se inicializa de forma independiente. Terraform crea un `.terraform/` local al directorio del entorno y un `terraform.tfstate` separado.

```bash
terraform -chdir=/root/lab/entornos/dev apply -auto-approve
```

Aplica dev: crea `modules/red/output/vpc-dev.json` y `modules/aplicacion/output/app-dev.conf`. El estado queda en `entornos/dev/terraform.tfstate`.

```bash
terraform -chdir=/root/lab/entornos/dev output endpoint
```

Muestra el endpoint generado para dev. El output viene del módulo de aplicación a través de la cadena `module.aplicacion.app_endpoint`.

### Paso 7: Inicializar y Aplicar el Entorno Prod

```bash
terraform -chdir=/root/lab/entornos/prod init
```

Prod tiene su propio proceso de `init`, independiente de dev. No comparten estado ni `.terraform/`.

```bash
terraform -chdir=/root/lab/entornos/prod apply -auto-approve
```

Aplica prod sin afectar el estado de dev. Crea `vpc-prod.json` y `app-prod.conf` con los valores de prod.

```bash
terraform -chdir=/root/lab/entornos/prod output endpoint
```

Muestra el endpoint de prod, distinto al de dev aunque use los mismos módulos.

### Paso 8: Comparar los Entornos

```bash
cat /root/lab/modules/red/output/vpc-dev.json
```

Muestra la configuración de red de dev con CIDR `10.0.0.0/16` y sus subnets calculadas.

```bash
cat /root/lab/modules/red/output/vpc-prod.json
```

Muestra la configuración de red de prod con CIDR `10.1.0.0/16`. Misma lógica, distintos valores.

```bash
cat /root/lab/modules/aplicacion/output/app-dev.conf
```

```bash
cat /root/lab/modules/aplicacion/output/app-prod.conf
```

Compara los dos archivos de configuración de la aplicación. Dev tiene 1 instancia, prod tiene 3 — el módulo recibió parámetros distintos y generó configuraciones distintas.

### Paso 9: Validar el Laboratorio

```bash
cd /root/lab
bash validate-lab.sh
```

---

## Criterios de Validacion

1. Estructura `modules/` con al menos 2 módulos (`red` y `aplicacion`)
2. Estructura `entornos/` con `dev` y `prod` independientes
3. Cada entorno tiene su `main.tf` con referencia a los módulos
4. Dev inicializado y aplicado (`.terraform/` + `terraform.tfstate` en `entornos/dev/`)
5. Prod inicializado y aplicado (`.terraform/` + `terraform.tfstate` en `entornos/prod/`)
6. Archivos de salida generados por ambos entornos

## Conceptos Aprendidos

- Separación de módulos reutilizables y configuraciones de entorno
- Rutas relativas para `source` de módulos (`../../modules/X`)
- Estados independientes por entorno
- Pasar outputs de un módulo como inputs de otro (`module.red.vpc_id`)
- `terraform -chdir=<dir>` para operar en un directorio sin `cd`

---

**Anterior:** [Lab 3 - Módulos Avanzados](../lab3-modulos-avanzados/)
**Siguiente:** [Módulo 06 - State Management](../../06-state-management/)

# Lab 1: Crear Tu Primer Módulo

![Terraform](https://img.shields.io/badge/Terraform-Modules-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Crear un módulo local reutilizable de Terraform: definir sus variables, recursos y outputs, luego invocarlo desde una configuración raíz y verificar que el estado refleje los recursos creados a través del módulo.

## ⏱️ Duración
30 minutos

## 📋 Prerrequisitos
- ✅ Módulos 1–4 completados
- Terraform instalado (`terraform version` >= 1.0)

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear la Estructura de Directorios

Un módulo de Terraform es simplemente un directorio con archivos `.tf`. La convención es colocarlos bajo `modules/<nombre-del-modulo>/`.

```bash
mkdir -p modules/web-server
```

Verificar estructura:

```bash
tree .
# .
# └── modules/
#     └── web-server/
```

### Paso 2: Crear el Módulo — variables.tf

Las variables definen la interfaz del módulo: qué parámetros acepta quien lo invoca.

Crea `modules/web-server/variables.tf`:

```hcl
variable "server_name" {
  description = "Nombre del servidor"
  type        = string
}

variable "server_type" {
  description = "Tipo de servidor (web, api, worker)"
  type        = string
  default     = "web"
}

variable "port" {
  description = "Puerto en el que escucha el servidor"
  type        = number
  default     = 80
}

variable "environment" {
  description = "Entorno de despliegue (dev, staging, prod)"
  type        = string
  default     = "dev"
}
```

### Paso 3: Crear el Módulo — main.tf

Los recursos del módulo usan las variables del paso anterior.

Crea `modules/web-server/main.tf`:

```hcl
resource "local_file" "server_config" {
  filename = "${path.root}/output/servers/${var.server_name}.txt"
  content  = <<-EOT
    Server:      ${var.server_name}
    Type:        ${var.server_type}
    Port:        ${var.port}
    Environment: ${var.environment}
  EOT
}

resource "local_file" "server_log" {
  filename = "${path.root}/output/logs/${var.server_name}.log"
  content  = "Server ${var.server_name} initialized at ${timestamp()}"
}
```

### Paso 4: Crear el Módulo — outputs.tf

Los outputs exponen valores del módulo a quien lo invoca.

Crea `modules/web-server/outputs.tf`:

```hcl
output "config_path" {
  description = "Ruta del archivo de configuración generado"
  value       = local_file.server_config.filename
}

output "log_path" {
  description = "Ruta del archivo de log generado"
  value       = local_file.server_log.filename
}

output "server_info" {
  description = "Resumen del servidor configurado"
  value       = "${var.server_name} (${var.server_type}) en puerto ${var.port}"
}
```

### Paso 5: Crear la Configuración Raíz — main.tf

La configuración raíz invoca el módulo con el bloque `module`. Aquí puedes instanciarlo múltiples veces con distintos parámetros.

Crea `main.tf` en la raíz del proyecto:

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

module "web_server" {
  source = "./modules/web-server"

  server_name = "web-01"
  server_type = "web"
  port        = 8080
  environment = "dev"
}

module "api_server" {
  source = "./modules/web-server"

  server_name = "api-01"
  server_type = "api"
  port        = 3000
  environment = "dev"
}
```

### Paso 6: Exponer Outputs desde la Raíz

Crea `outputs.tf` en la raíz del proyecto:

```hcl
output "web_config_path" {
  description = "Ruta de configuración del servidor web"
  value       = module.web_server.config_path
}

output "api_config_path" {
  description = "Ruta de configuración del servidor API"
  value       = module.api_server.config_path
}

output "web_info" {
  value = module.web_server.server_info
}

output "api_info" {
  value = module.api_server.server_info
}
```

### Paso 7: Inicializar y Aplicar

```bash
# Inicializar — Terraform descarga el provider local y registra el módulo
terraform init

# Ver qué recursos creará
terraform plan

# Aplicar (crea los archivos de configuración y logs)
terraform apply -auto-approve
```

Salida esperada de `apply`:

```
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:
api_config_path = "./output/servers/api-01.txt"
api_info        = "api-01 (api) en puerto 3000"
web_config_path = "./output/servers/web-01.txt"
web_info        = "web-01 (web) en puerto 8080"
```

### Paso 8: Inspeccionar el Estado del Módulo

```bash
# Ver todos los recursos, incluidos los del módulo
terraform state list

# Salida esperada:
# module.api_server.local_file.server_config
# module.api_server.local_file.server_log
# module.web_server.local_file.server_config
# module.web_server.local_file.server_log

# Ver detalles de un recurso específico del módulo
terraform state show module.web_server.local_file.server_config

# Ver los outputs generados
terraform output
```

### Paso 9: Ejecutar el Script de Validación

```bash
./validate-lab.sh
```

## ✅ Criterios de Validación

Para completar exitosamente este laboratorio:

1. ✅ Directorio `modules/` existe con el módulo `web-server`
2. ✅ El módulo tiene `main.tf`, `variables.tf` y `outputs.tf`
3. ✅ El `main.tf` raíz invoca el módulo con un bloque `module`
4. ✅ Terraform inicializado (`.terraform/` presente)
5. ✅ Estado aplicado (`terraform.tfstate` presente)
6. ✅ El estado contiene recursos con prefijo `module.`
7. ✅ Al menos un output definido en el módulo

## 🎓 Conceptos Aprendidos

- ✅ Estructura de un módulo de Terraform (`main.tf`, `variables.tf`, `outputs.tf`)
- ✅ Cómo invocar un módulo local con `source = "./modules/..."`
- ✅ Reutilización: múltiples instancias del mismo módulo con distintos parámetros
- ✅ Cómo los outputs del módulo se consumen en la raíz
- ✅ `terraform state list` para ver recursos agrupados por módulo

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Modules Básico Badge**

---

**Siguiente:** [Lab 2 - Módulos del Registry](../lab2-registry-modules/)

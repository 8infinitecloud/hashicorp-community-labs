# Lab 1: Crear Tu Primer Módulo

![Terraform](https://img.shields.io/badge/Terraform-Modules-7B42BC?style=flat&logo=terraform)

## Objetivo

Crear un módulo local reutilizable de Terraform: definir sus variables, recursos y outputs, luego invocarlo desde una configuración raíz y verificar que el estado refleje los recursos creados a través del módulo.

## Duración

30 minutos

## Prerrequisitos

- Módulos 1-4 completados
- Terraform instalado (`terraform version` >= 1.0)

## Instrucciones Paso a Paso

### Paso 1: Crear la Estructura de Directorios

```bash
mkdir -p /root/lab/modules/web-server
```

Un módulo de Terraform es un directorio con archivos `.tf`. La convención es colocarlos bajo `modules/<nombre-del-modulo>/` dentro del proyecto raíz.

### Paso 2: Crear el Módulo — variables.tf

```bash
touch /root/lab/modules/web-server/variables.tf
cat > /root/lab/modules/web-server/variables.tf <<'EOF'
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
EOF
```

Las variables definen la interfaz del módulo: qué parámetros acepta quien lo invoca. Cualquier valor sin `default` es obligatorio.

### Paso 3: Crear el Módulo — main.tf

```bash
touch /root/lab/modules/web-server/main.tf
cat > /root/lab/modules/web-server/main.tf <<'EOF'
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
EOF
```

Los recursos del módulo usan las variables declaradas en el paso anterior. `path.root` apunta al directorio raíz del proyecto, no al directorio del módulo, por lo que los archivos de salida se crean en un lugar centralizado.

### Paso 4: Crear el Módulo — outputs.tf

```bash
touch /root/lab/modules/web-server/outputs.tf
cat > /root/lab/modules/web-server/outputs.tf <<'EOF'
output "config_path" {
  description = "Ruta del archivo de configuracion generado"
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
EOF
```

Los outputs exponen valores internos del módulo a quien lo invoca. Sin outputs, la raíz no puede leer ningún dato calculado dentro del módulo.

### Paso 5: Crear los Directorios de Salida

```bash
mkdir -p /root/lab/output/servers
mkdir -p /root/lab/output/logs
```

El provider `local` necesita que los directorios destino existan antes de crear los archivos. Si no existen, `terraform apply` falla con un error de permiso de escritura.

### Paso 6: Crear la Configuración Raíz — main.tf

```bash
touch /root/lab/main.tf
cat > /root/lab/main.tf <<'EOF'
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
EOF
```

El bloque `module` invoca el módulo local indicado en `source`. Aquí se instancia el mismo módulo dos veces con parámetros distintos, demostrando la reutilización sin duplicar código.

### Paso 7: Crear la Configuración Raíz — outputs.tf

```bash
touch /root/lab/outputs.tf
cat > /root/lab/outputs.tf <<'EOF'
output "web_config_path" {
  description = "Ruta de configuracion del servidor web"
  value       = module.web_server.config_path
}

output "api_config_path" {
  description = "Ruta de configuracion del servidor API"
  value       = module.api_server.config_path
}

output "web_info" {
  value = module.web_server.server_info
}

output "api_info" {
  value = module.api_server.server_info
}
EOF
```

Los outputs de la raíz consumen los outputs del módulo usando la sintaxis `module.<nombre>.<output>`. Esto conecta los valores calculados dentro del módulo con el nivel superior.

### Paso 8: Inicializar Terraform

```bash
cd /root/lab && terraform init
```

`terraform init` descarga el provider `hashicorp/local` y registra el módulo local. Siempre es el primer comando a ejecutar en un proyecto nuevo o tras agregar módulos.

### Paso 9: Ver el Plan

```bash
cd /root/lab && terraform plan
```

`terraform plan` muestra los 4 recursos que se crearán (2 por cada instancia del módulo: `server_config` y `server_log`). No modifica nada.

### Paso 10: Aplicar

```bash
cd /root/lab && terraform apply -auto-approve
```

Crea los 4 archivos de configuración y log. La salida debe indicar `4 added, 0 changed, 0 destroyed` y mostrar los outputs con las rutas generadas.

### Paso 11: Inspeccionar el Estado del Módulo

```bash
cd /root/lab && terraform state list
```

Muestra todos los recursos en el estado con el prefijo `module.<nombre>`. Esto confirma que Terraform agrupa los recursos por módulo, facilitando la gestión y el troubleshooting.

```bash
cd /root/lab && terraform output
```

Muestra los valores de los outputs definidos en la raíz, que internamente referencian los outputs del módulo.

### Paso 12: Validar el Laboratorio

```bash
cd /root/lab
bash validate-lab.sh
```

---

## Criterios de Validacion

1. Directorio `modules/` existe con el módulo `web-server`
2. El módulo tiene `main.tf`, `variables.tf` y `outputs.tf`
3. El `main.tf` raíz invoca el módulo con al menos un bloque `module`
4. Terraform inicializado (`.terraform/` presente o `terraform.tfstate` existe)
5. Estado aplicado (`terraform.tfstate` presente)
6. El estado contiene recursos con prefijo `module.`
7. Al menos un output definido en el módulo

## Conceptos Aprendidos

- Estructura de un módulo de Terraform (`main.tf`, `variables.tf`, `outputs.tf`)
- Cómo invocar un módulo local con `source = "./modules/..."`
- Reutilización: múltiples instancias del mismo módulo con distintos parámetros
- Cómo los outputs del módulo se consumen en la raíz
- `terraform state list` para ver recursos agrupados por módulo

---

**Siguiente:** [Lab 2 - Módulos del Registry](../lab2-registry-modules/)

# Lab 3: Módulos Avanzados

![Terraform](https://img.shields.io/badge/Terraform-Modules_Advanced-7B42BC?style=flat&logo=terraform)

## Objetivo

Implementar módulos con `for_each` y variables de tipo `map(object(...))` para crear recursos escalables. Usar `validation` blocks para rechazar entradas inválidas antes de planificar.

## Duración

35 minutos

## Prerrequisitos

- Labs 1 y 2 del módulo 05 completados
- Terraform instalado
- Conceptos de `for` expressions (Módulo 04)

## Instrucciones Paso a Paso

### Paso 1: Crear la Estructura del Proyecto

```bash
mkdir -p /root/lab/modules/servidor
mkdir -p /root/lab/modules/servidor/output
```

El módulo `servidor` recibirá un mapa de servidores y creará un archivo de configuración por cada uno usando `for_each`. Los archivos de salida van al subdirectorio `output/` del módulo.

### Paso 2: Crear el Módulo — variables.tf

```bash
touch /root/lab/modules/servidor/variables.tf
cat > /root/lab/modules/servidor/variables.tf <<'EOF'
variable "servidores" {
  description = "Mapa de servidores a configurar"
  type = map(object({
    entorno  = string
    puerto   = number
    replicas = number
  }))

  validation {
    condition     = length(var.servidores) > 0
    error_message = "Debes definir al menos un servidor en el mapa."
  }
}

variable "prefijo" {
  description = "Prefijo para nombres de recursos"
  type        = string
  default     = "app"
}

variable "etiquetas" {
  description = "Lista de etiquetas a incluir en el inventario"
  type        = list(string)
  default     = []
}
EOF
```

`map(object(...))` permite pasar una estructura tipada de clave-valor al módulo. El bloque `validation` rechaza un mapa vacío antes de crear cualquier recurso, evitando estados inconsistentes.

### Paso 3: Crear el Módulo — main.tf

```bash
touch /root/lab/modules/servidor/main.tf
cat > /root/lab/modules/servidor/main.tf <<'EOF'
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

resource "local_file" "config" {
  for_each = var.servidores

  filename = "${path.module}/output/${each.key}.conf"
  content  = <<-EOT
    # Servidor: ${each.key}
    prefijo   = ${var.prefijo}
    entorno   = ${each.value.entorno}
    puerto    = ${each.value.puerto}
    replicas  = ${each.value.replicas}
  EOT
}

resource "local_file" "inventario" {
  filename = "${path.module}/output/inventario.txt"
  content  = <<-EOT
    # Inventario de Servidores
    # Prefijo: ${var.prefijo}

    ${join("\n", [
      for nombre, srv in var.servidores :
      "[${nombre}] entorno=${srv.entorno} puerto=${srv.puerto} replicas=${srv.replicas}"
    ])}

    # Etiquetas: ${length(var.etiquetas) > 0 ? join(", ", var.etiquetas) : "ninguna"}
  EOT
}
EOF
```

`for_each = var.servidores` crea un recurso `local_file.config` por cada entrada del mapa. `each.key` es el nombre del servidor y `each.value` contiene sus atributos. El recurso `inventario` usa un `for` expression para construir una línea por servidor.

### Paso 4: Crear el Módulo — outputs.tf

```bash
touch /root/lab/modules/servidor/outputs.tf
cat > /root/lab/modules/servidor/outputs.tf <<'EOF'
output "configs_creadas" {
  description = "Lista de rutas de archivos de configuracion generados"
  value       = [for k, v in local_file.config : v.filename]
}

output "inventario_path" {
  description = "Ruta del archivo de inventario"
  value       = local_file.inventario.filename
}
EOF
```

El output `configs_creadas` usa un `for` expression para transformar el mapa de recursos en una lista de rutas. La raíz puede iterar esta lista para procesamiento adicional o para mostrarla en CI/CD.

### Paso 5: Crear la Configuración Raíz — main.tf

```bash
touch /root/lab/main.tf
cat > /root/lab/main.tf <<'EOF'
terraform {
  required_version = ">= 1.0"
}

locals {
  servidores = {
    "web-prod" = {
      entorno  = "produccion"
      puerto   = 443
      replicas = 3
    }
    "web-dev" = {
      entorno  = "desarrollo"
      puerto   = 8080
      replicas = 1
    }
    "api-prod" = {
      entorno  = "produccion"
      puerto   = 8443
      replicas = 2
    }
  }
}

module "infra" {
  source = "./modules/servidor"

  servidores = local.servidores
  prefijo    = "peru-hug"
  etiquetas  = ["v2.0", "terraform", "bootcamp"]
}

output "configs" {
  value = module.infra.configs_creadas
}

output "inventario" {
  value = module.infra.inventario_path
}
EOF
```

El `local.servidores` define el mapa de servidores en la raíz y lo pasa al módulo. Centralizar los datos en `locals` facilita modificar un servidor sin tocar la definición del módulo.

### Paso 6: Inicializar Terraform

```bash
cd /root/lab && terraform init
```

`terraform init` descarga el provider `hashicorp/local` y registra el módulo local en `.terraform/`. Ejecutar siempre después de agregar un módulo nuevo o modificar su `source`.

### Paso 7: Ver el Plan

```bash
cd /root/lab && terraform plan
```

El plan muestra 4 recursos: un `local_file.config` por cada uno de los 3 servidores del mapa, más el `local_file.inventario`. Observa cómo los nombres de recursos incluyen la clave del mapa (`web-prod`, `web-dev`, `api-prod`).

### Paso 8: Aplicar

```bash
cd /root/lab && terraform apply -auto-approve
```

Crea los 4 archivos. La ventaja de `for_each` sobre `count` es que agregar o eliminar un servidor solo afecta ese recurso específico, sin re-crear los demás.

### Paso 9: Verificar los Archivos Generados

```bash
cat /root/lab/modules/servidor/output/web-prod.conf
```

Muestra la configuración del servidor `web-prod`. Cada archivo tiene el nombre del servidor como key del mapa, lo que facilita la trazabilidad.

```bash
cat /root/lab/modules/servidor/output/inventario.txt
```

Muestra el inventario completo generado dinámicamente con `join` y un `for` expression. Este patrón simula la generación de archivos de inventario para Ansible u otras herramientas.

### Paso 10: Ver el Estado del Módulo

```bash
cd /root/lab && terraform state list
```

Muestra los recursos agrupados bajo `module.infra`, con el sufijo `["web-prod"]`, `["web-dev"]` etc. — el `for_each` crea instancias indexadas por la clave del mapa, no por número.

### Paso 11: Agregar un Servidor y Observar el Diff

```bash
cat >> /root/lab/main.tf <<'EOF'

# Servidor adicional — agrega al bloque locals manualmente si prefieres
EOF
```

Edita `/root/lab/main.tf` y agrega `"db-prod" = { entorno = "produccion", puerto = 5432, replicas = 2 }` dentro de `local.servidores`. Luego ejecuta:

```bash
cd /root/lab && terraform plan
```

El plan muestra solo 2 recursos nuevos (`local_file.config["db-prod"]` y la actualización de `inventario.txt`), sin tocar `web-prod` ni `web-dev`. Esta es la ventaja principal de `for_each`.

```bash
cd /root/lab && terraform apply -auto-approve
```

Aplica solo los cambios necesarios. Los recursos existentes no se destruyen ni re-crean.

### Paso 12: Validar el Laboratorio

```bash
cd /root/lab
bash validate-lab.sh
```

---

## Criterios de Validacion

1. Módulo `modules/servidor/` existe con `main.tf`, `variables.tf` y `outputs.tf`
2. El módulo usa `for_each` con tipo `map(object(...))`
3. Variables del módulo incluyen un bloque `validation`
4. Terraform inicializado y estado aplicado
5. Archivos de configuración generados por `for_each`
6. El estado contiene múltiples instancias del módulo

## Conceptos Aprendidos

- `for_each` con `map(object(...))` en recursos dentro de módulos
- `each.key` y `each.value` para acceder a datos del mapa
- Bloque `validation` en variables para rechazar entradas inválidas
- `for` expressions en outputs para transformar mapas en listas
- Modificaciones aisladas con `for_each`: solo cambia el recurso afectado

---

**Anterior:** [Lab 2 - Registry Modules](../lab2-registry-modules/)
**Siguiente:** [Lab 4 - Organización de Proyectos](../lab4-organizacion-proyectos/)

# Lab 3: Variables con Validacion

![Terraform](https://img.shields.io/badge/Terraform-Variables-7B42BC?style=flat&logo=terraform)

## Objetivo

Declarar variables de distintos tipos (string, number, bool, list, map, object), agregar bloques `validation` con condiciones y mensajes de error, marcar variables como `sensitive`, y suministrar valores mediante `terraform.tfvars`, archivos `.tfvars` nombrados y la línea de comandos.

## Duración

30 minutos

## Prerrequisitos

- Labs 1 y 2 completados
- Terraform instalado (`terraform version` >= 1.0)

## Instrucciones Paso a Paso

### Paso 1: Crear la Estructura del Proyecto

```bash
mkdir -p /root/lab/output
```

Un directorio limpio con subdirectorio `output/` separa los archivos de configuración Terraform de los archivos que los recursos crean en tiempo de apply.

### Paso 2: Crear main.tf con el Provider

```bash
touch /root/lab/main.tf
```

```bash
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

# Crear archivo de configuracion usando las variables
resource "local_file" "config" {
  filename = "/root/lab/output/config.txt"
  content  = <<-EOT
    Environment   : ${var.environment}
    Instance Count: ${var.instance_count}
    Port          : ${var.port}
    Monitoring    : ${var.enable_monitoring}
  EOT
}

# Usar variable sensible en un archivo separado
resource "local_sensitive_file" "credentials" {
  filename = "/root/lab/output/credentials.txt"
  content  = "API_KEY=${var.api_key}"
}
EOF
```

`local_sensitive_file` es igual que `local_file` pero Terraform oculta su contenido en la salida del plan y del apply, igual que hace con los outputs marcados como `sensitive = true`.

### Paso 3: Crear variables.tf con Tipos Primitivos y Validaciones

```bash
touch /root/lab/variables.tf
```

```bash
cat > /root/lab/variables.tf <<'EOF'
variable "environment" {
  description = "Entorno de despliegue"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "El entorno debe ser dev, staging o prod."
  }
}

variable "instance_count" {
  description = "Numero de instancias"
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "El numero de instancias debe estar entre 1 y 10."
  }
}

variable "port" {
  description = "Puerto de la aplicacion"
  type        = number
  default     = 8080

  validation {
    condition     = var.port > 0 && var.port < 65536
    error_message = "El puerto debe estar entre 1 y 65535."
  }
}

variable "enable_monitoring" {
  description = "Activar monitoreo"
  type        = bool
  default     = true
}

variable "api_key" {
  description = "Clave de API (sensible)"
  type        = string
  sensitive   = true
  default     = "default-key-change-me"

  validation {
    condition     = length(var.api_key) >= 10
    error_message = "La clave de API debe tener al menos 10 caracteres."
  }
}
EOF
```

El bloque `validation` acepta cualquier expresión booleana en `condition`. Cuando la condición es `false`, Terraform muestra el `error_message` y detiene el plan antes de tocar ningún recurso.

### Paso 4: Crear complex-variables.tf con Tipos de Coleccion

```bash
touch /root/lab/complex-variables.tf
```

```bash
cat > /root/lab/complex-variables.tf <<'EOF'
variable "allowed_environments" {
  description = "Lista de entornos permitidos"
  type        = list(string)
  default     = ["dev", "staging", "prod"]

  validation {
    condition     = length(var.allowed_environments) >= 1
    error_message = "Debe haber al menos un entorno permitido."
  }
}

variable "instance_types" {
  description = "Tipo de instancia por entorno"
  type        = map(string)
  default = {
    dev     = "small"
    staging = "medium"
    prod    = "large"
  }
}

variable "database_config" {
  description = "Configuracion de la base de datos"
  type = object({
    engine            = string
    engine_version    = string
    instance_class    = string
    allocated_storage = number
  })
  default = {
    engine            = "postgres"
    engine_version    = "14.7"
    instance_class    = "db.t3.micro"
    allocated_storage = 20
  }

  validation {
    condition     = var.database_config.allocated_storage >= 20
    error_message = "El almacenamiento debe ser de al menos 20 GB."
  }

  validation {
    condition     = contains(["postgres", "mysql", "mariadb"], var.database_config.engine)
    error_message = "El motor debe ser postgres, mysql o mariadb."
  }
}
EOF
```

Un tipo `object` define la forma exacta que debe tener el valor: claves y tipos de cada campo. Terraform valida la estructura en tiempo de plan, antes de ejecutar cualquier operacion.

### Paso 5: Crear complex-resources.tf con Recursos que Usan Variables Complejas

```bash
touch /root/lab/complex-resources.tf
```

```bash
cat > /root/lab/complex-resources.tf <<'EOF'
resource "local_file" "complex_config" {
  filename = "/root/lab/output/complex-config.txt"
  content  = <<-EOT
    Entornos permitidos : ${join(", ", var.allowed_environments)}
    Tipo para ${var.environment}: ${lookup(var.instance_types, var.environment, "unknown")}

    Base de datos:
      Motor   : ${var.database_config.engine}
      Version : ${var.database_config.engine_version}
      Clase   : ${var.database_config.instance_class}
      Storage : ${var.database_config.allocated_storage} GB
  EOT
}

output "environment" {
  description = "Entorno activo"
  value       = var.environment
}

output "db_engine" {
  description = "Motor de base de datos"
  value       = var.database_config.engine
}

output "instance_type" {
  description = "Tipo de instancia para el entorno activo"
  value       = lookup(var.instance_types, var.environment, "unknown")
}
EOF
```

`lookup(map, key, default)` devuelve el valor del mapa para la clave dada, o el valor por defecto si la clave no existe. Es más seguro que la notación `map[key]` cuando la clave puede no estar presente.

### Paso 6: Crear terraform.tfvars con Valores por Defecto del Proyecto

```bash
touch /root/lab/terraform.tfvars
```

```bash
cat > /root/lab/terraform.tfvars <<'EOF'
environment       = "staging"
instance_count    = 3
port              = 3000
enable_monitoring = true
api_key           = "staging-api-key-xyz"

allowed_environments = ["dev", "staging", "prod"]

instance_types = {
  dev     = "nano"
  staging = "micro"
  prod    = "large"
}

database_config = {
  engine            = "postgres"
  engine_version    = "15.2"
  instance_class    = "db.t3.small"
  allocated_storage = 50
}
EOF
```

Terraform carga `terraform.tfvars` automáticamente en cada operación. Los valores aquí sobrescriben los `default` de las variables pero pueden a su vez ser sobrescritos con `-var` o `-var-file` en la línea de comandos.

### Paso 7: Crear prod.tfvars para el Entorno de Produccion

```bash
touch /root/lab/prod.tfvars
```

```bash
cat > /root/lab/prod.tfvars <<'EOF'
environment       = "prod"
instance_count    = 5
port              = 443
enable_monitoring = true
api_key           = "prod-api-key-secure-1234"

database_config = {
  engine            = "postgres"
  engine_version    = "15.2"
  instance_class    = "db.t3.large"
  allocated_storage = 100
}
EOF
```

Los archivos `.tfvars` nombrados no se cargan automáticamente; hay que pasarlos con `-var-file="prod.tfvars"`. Permiten mantener configuraciones distintas por entorno en el mismo directorio de trabajo.

### Paso 8: Inicializar y Aplicar con Valores por Defecto (terraform.tfvars)

```bash
terraform -chdir=/root/lab init
```

```bash
terraform -chdir=/root/lab apply -auto-approve
```

Terraform carga `terraform.tfvars` automáticamente y aplica la configuración de `staging`. Observa en la salida que la variable `api_key` no aparece en texto claro gracias al atributo `sensitive = true`.

### Paso 9: Probar la Validacion con un Valor Incorrecto

```bash
terraform -chdir=/root/lab plan -var="environment=test"
```

Terraform rechaza el plan antes de contactar ningún recurso porque `test` no pasa la condición `contains(["dev", "staging", "prod"], var.environment)`. El mensaje que ves es exactamente el `error_message` definido en la variable.

### Paso 10: Aplicar con el Archivo de Produccion

```bash
terraform -chdir=/root/lab apply -var-file="prod.tfvars" -auto-approve
```

```bash
cat /root/lab/output/config.txt
```

```bash
cat /root/lab/output/complex-config.txt
```

Al pasar `-var-file="prod.tfvars"`, los valores de ese archivo sobrescriben los de `terraform.tfvars`. Compara el contenido de los archivos de salida con el de la ejecución anterior para ver el cambio de entorno.

### Paso 11: Ir al Directorio del Lab

```bash
cd /root/lab
```

### Paso 12: Ejecutar la Validacion

```bash
bash validate-lab.sh
```

## Conceptos

| Concepto | Descripcion |
|---|---|
| `variable` block | Declara un parámetro de entrada con tipo, descripción, valor por defecto y reglas de validación |
| `validation` | Bloque dentro de `variable` que define una condición booleana y el mensaje de error cuando falla |
| `sensitive = true` | Oculta el valor de la variable en todos los outputs de Terraform (plan, apply, state show) |
| `type = object({...})` | Define la forma exacta del valor: claves requeridas y tipo de cada una |
| `terraform.tfvars` | Archivo cargado automáticamente por Terraform para suministrar valores a las variables |
| `-var-file` | Flag de CLI para cargar un archivo `.tfvars` específico; sobrescribe `terraform.tfvars` |
| `-var` | Flag de CLI para suministrar un valor individual; tiene la mayor precedencia |
| `lookup(map, key, default)` | Función que accede a un valor de un mapa con un valor de respaldo si la clave no existe |

---

**Anterior:** [Lab 2 - Data Sources](../lab2-data-sources/)
**Siguiente:** [Lab 4 - Outputs y Funciones](../lab4-outputs-funciones/)

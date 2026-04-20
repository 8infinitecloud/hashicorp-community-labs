# Lab 1: Explorar HCL y Tipos de Datos

![Terraform](https://img.shields.io/badge/Terraform-HCL%20Syntax-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Familiarizarte con la sintaxis HCL (HashiCorp Configuration Language) y los diferentes tipos de datos en Terraform.

## ⏱️ Duración
30 minutos

## 📋 Prerrequisitos
- ✅ Módulo 1 completado
- Terraform instalado
- Editor de texto

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear el Directorio del Proyecto

```bash
mkdir lab2-hcl
cd lab2-hcl
```

### Paso 2: Crear el Archivo main.tf

Crea un archivo `main.tf` con el siguiente contenido:

```hcl
# main.tf - Explorando tipos de datos en HCL

# Variables de diferentes tipos
variable "app_name" {
  description = "Nombre de la aplicación"
  type        = string
  default     = "PeruApp"
}

variable "instance_count" {
  description = "Número de instancias"
  type        = number
  default     = 3
}

variable "enable_monitoring" {
  description = "Habilitar monitoreo"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "Zonas de disponibilidad"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default = {
    Environment = "desarrollo"
    Country     = "Peru"
    Team        = "DevOps"
  }
}

variable "server_config" {
  description = "Configuración del servidor"
  type = object({
    name = string
    size = string
    port = number
  })
  default = {
    name = "web-server"
    size = "t2.micro"
    port = 8080
  }
}

# Locals para cálculos
locals {
  # Concatenación de strings
  full_app_name = "${var.app_name}-${var.tags["Environment"]}"
  
  # Condicional
  instance_type = var.tags["Environment"] == "produccion" ? "t3.large" : "t2.micro"
  
  # Funciones de strings
  app_name_upper = upper(var.app_name)
  app_name_lower = lower(var.app_name)
  
  # Funciones de listas
  az_count = length(var.availability_zones)
  first_az = var.availability_zones[0]
  
  # Funciones de mapas
  all_tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
      CreatedAt = timestamp()
    }
  )
  
  # Formateo
  server_url = format("http://%s:%d", var.server_config.name, var.server_config.port)
}

# Outputs para ver los resultados
output "1_variables_basicas" {
  value = {
    app_name          = var.app_name
    instance_count    = var.instance_count
    enable_monitoring = var.enable_monitoring
  }
}

output "2_colecciones" {
  value = {
    availability_zones = var.availability_zones
    tags               = var.tags
    server_config      = var.server_config
  }
}

output "3_locals_calculados" {
  value = {
    full_app_name  = local.full_app_name
    instance_type  = local.instance_type
    app_name_upper = local.app_name_upper
    app_name_lower = local.app_name_lower
  }
}

output "4_funciones" {
  value = {
    az_count   = local.az_count
    first_az   = local.first_az
    all_tags   = local.all_tags
    server_url = local.server_url
  }
}

output "5_expresiones" {
  value = {
    # Ternario
    message = var.enable_monitoring ? "Monitoreo habilitado ✅" : "Monitoreo deshabilitado ❌"
    
    # Interpolación
    greeting = "Bienvenido a ${var.app_name}!"
    
    # Join y split
    az_string = join(", ", var.availability_zones)
    
    # Condicional complejo
    deployment_size = (
      var.instance_count > 10 ? "grande" :
      var.instance_count > 5  ? "mediano" :
      "pequeño"
    )
  }
}
```

### Paso 3: Inicializar y Aplicar

```bash
# Inicializar
terraform init

# Ver el plan
terraform plan

# Aplicar
terraform apply
```

### Paso 4: Explorar los Outputs

Observa los diferentes tipos de datos y cómo se procesan:

```bash
# Ver todos los outputs
terraform output

# Ver un output específico
terraform output 1_variables_basicas
terraform output 3_locals_calculados

# Ver en formato JSON
terraform output -json | jq .
```

### Paso 5: Experimentar con Variables

#### Experimento 1: Cambiar a Producción

```bash
# Crear archivo terraform.tfvars
cat > terraform.tfvars <<EOF
tags = {
  Environment = "produccion"
  Country     = "Peru"
  Team        = "DevOps"
}
EOF

# Aplicar y observar cómo cambia instance_type
terraform apply
```

#### Experimento 2: Cambiar Instance Count

```bash
# Aplicar con variable inline
terraform apply -var="instance_count=15"

# Observa cómo deployment_size cambia a "grande"
terraform output 5_expresiones
```

#### Experimento 3: Agregar Más Zonas

Modifica `main.tf` y agrega más zonas:

```hcl
variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
}
```

Aplica y ve cómo cambia `az_count`.

### Paso 6: Usar Terraform Console

```bash
# Abrir consola interactiva
terraform console

# Dentro de la consola, prueba:
> var.app_name
> var.instance_count
> var.tags["Environment"]
> upper("hello terraform")
> length(var.availability_zones)
> join(" | ", var.availability_zones)
> format("Server: %s on port %d", var.server_config.name, var.server_config.port)

# Salir
> exit
```

### Paso 7: Ejecutar Validación

```bash
# Volver al directorio del lab
cd ..

# Ejecutar validación
./validate-lab.sh
```

## 📚 Tipos de Datos en Terraform

### Tipos Primitivos

| Tipo | Descripción | Ejemplo |
|------|-------------|---------|
| `string` | Cadena de texto | `"PeruApp"` |
| `number` | Número entero o decimal | `42`, `3.14` |
| `bool` | Booleano | `true`, `false` |

### Tipos de Colección

| Tipo | Descripción | Ejemplo |
|------|-------------|---------|
| `list(type)` | Lista ordenada | `["a", "b", "c"]` |
| `set(type)` | Conjunto sin duplicados | `["a", "b"]` |
| `map(type)` | Mapa clave-valor | `{key = "value"}` |

### Tipos Estructurales

| Tipo | Descripción | Ejemplo |
|------|-------------|---------|
| `object({...})` | Objeto con atributos específicos | `{name = "web", port = 80}` |
| `tuple([...])` | Tupla con tipos específicos | `["string", 123, true]` |

## 🔧 Funciones Útiles de Terraform

### Funciones de Strings

```hcl
upper("hello")           # "HELLO"
lower("HELLO")           # "hello"
title("hello world")     # "Hello World"
trim("  hello  ")        # "hello"
format("Hello %s", "World")  # "Hello World"
```

### Funciones de Listas

```hcl
length([1, 2, 3])        # 3
concat([1, 2], [3, 4])   # [1, 2, 3, 4]
join(", ", ["a", "b"])   # "a, b"
split(",", "a,b,c")      # ["a", "b", "c"]
```

### Funciones de Mapas

```hcl
merge({a = 1}, {b = 2})  # {a = 1, b = 2}
keys({a = 1, b = 2})     # ["a", "b"]
values({a = 1, b = 2})   # [1, 2]
```

### Funciones Numéricas

```hcl
max(1, 5, 3)             # 5
min(1, 5, 3)             # 1
abs(-5)                  # 5
ceil(3.2)                # 4
floor(3.8)               # 3
```

### Funciones de Fecha

```hcl
timestamp()              # "2026-04-14T23:10:00Z"
formatdate("YYYY-MM-DD", timestamp())  # "2026-04-14"
```

## 🧪 Experimentos Adicionales

### Experimento 4: Validación de Variables

Agrega validación a las variables:

```hcl
variable "instance_count" {
  type    = number
  default = 3
  
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 100
    error_message = "Instance count debe estar entre 1 y 100."
  }
}
```

### Experimento 5: Variables Sensibles

```hcl
variable "db_password" {
  type      = string
  sensitive = true
  default   = "super-secret-password"
}

output "password_length" {
  value = length(var.db_password)
  # No muestra el password, solo su longitud
}
```

## ✅ Criterios de Validación

1. ✅ Proyecto `lab2-hcl` creado
2. ✅ Variables de todos los tipos definidas
3. ✅ Locals con cálculos y funciones
4. ✅ Outputs mostrando resultados
5. ✅ Terraform console explorado
6. ✅ Experimentos con variables completados

## 🎓 Conceptos Aprendidos

- ✅ Sintaxis HCL básica
- ✅ Tipos de datos primitivos y complejos
- ✅ Variables de entrada
- ✅ Locals para cálculos
- ✅ Expresiones condicionales (ternario)
- ✅ Interpolación de strings
- ✅ Funciones built-in de Terraform
- ✅ Terraform console para testing

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform HCL Master Badge**

---

**Anterior:** [Módulo 1](../../01-iac-fundamentals/)  
**Siguiente:** [Lab 2 - Providers](../lab2-providers/)

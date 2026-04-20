# Lab 3: Variables con Validación

![Terraform](https://img.shields.io/badge/Terraform-Variables-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Crear variables con validación compleja, tipos avanzados y diferentes formas de pasar valores.

## ⏱️ Duración
30 minutos

## 📋 Prerrequisitos
- ✅ Labs 1 y 2 completados
- Terraform instalado
- Editor de texto

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear el Directorio del Proyecto

```bash
mkdir lab3-variables
cd lab3-variables
```

### Paso 2: Variables Básicas con Validación

Crea `variables.tf`:

```hcl
# variables.tf - Variables con validación

# Variable de entorno con validación
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# Variable numérica con rango
variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
  
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

# Variable de puerto
variable "port" {
  description = "Application port"
  type        = number
  default     = 8080
  
  validation {
    condition     = var.port > 0 && var.port < 65536
    error_message = "Port must be between 1 and 65535."
  }
}

# Variable de región
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "Region must be a valid AWS region format (e.g., us-east-1)."
  }
}

# Variable booleana
variable "enable_monitoring" {
  description = "Enable monitoring"
  type        = bool
  default     = true
}

# Variable sensible
variable "api_key" {
  description = "API Key"
  type        = string
  sensitive   = true
  default     = "default-key-change-me"
  
  validation {
    condition     = length(var.api_key) >= 10
    error_message = "API key must be at least 10 characters long."
  }
}
```

Crea `main.tf`:

```hcl
# main.tf

terraform {
  required_version = ">= 1.0"
}

# Usar las variables
resource "local_file" "config" {
  filename = "${path.module}/config.txt"
  content  = <<-EOT
    Environment: ${var.environment}
    Instance Count: ${var.instance_count}
    Port: ${var.port}
    Region: ${var.region}
    Monitoring: ${var.enable_monitoring}
    API Key: ${var.api_key}
  EOT
}

# Outputs
output "environment" {
  value = var.environment
}

output "api_key" {
  value     = var.api_key
  sensitive = true
}
```

Ejecuta:

```bash
# Inicializar
terraform init

# Aplicar con valores por defecto
terraform apply -auto-approve

# Ver config
cat config.txt

# Probar validación (debe fallar)
terraform apply -var="environment=test"
# Error: Environment must be dev, staging, or prod.

# Probar con valor válido
terraform apply -var="environment=prod" -auto-approve
```

### Paso 3: Variables con Tipos Complejos

Crea `complex-variables.tf`:

```hcl
# complex-variables.tf - Tipos complejos

# Variable tipo list
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones required."
  }
}

# Variable tipo map
variable "instance_types" {
  description = "Instance types by environment"
  type        = map(string)
  default = {
    dev     = "t2.micro"
    staging = "t2.small"
    prod    = "t2.medium"
  }
}

# Variable tipo object
variable "database_config" {
  description = "Database configuration"
  type = object({
    engine         = string
    engine_version = string
    instance_class = string
    allocated_storage = number
  })
  
  default = {
    engine         = "postgres"
    engine_version = "14.7"
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
  
  validation {
    condition     = var.database_config.allocated_storage >= 20
    error_message = "Database storage must be at least 20 GB."
  }
  
  validation {
    condition     = contains(["postgres", "mysql", "mariadb"], var.database_config.engine)
    error_message = "Database engine must be postgres, mysql, or mariadb."
  }
}

# Variable tipo set
variable "allowed_ips" {
  description = "Allowed IP addresses"
  type        = set(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12"]
  
  validation {
    condition     = length(var.allowed_ips) > 0
    error_message = "At least one IP range must be specified."
  }
}

# Variable tipo list of objects
variable "users" {
  description = "List of users"
  type = list(object({
    name  = string
    email = string
    role  = string
  }))
  
  default = [
    {
      name  = "admin"
      email = "admin@example.com"
      role  = "admin"
    },
    {
      name  = "developer"
      email = "dev@example.com"
      role  = "developer"
    }
  ]
  
  validation {
    condition = alltrue([
      for user in var.users : contains(["admin", "developer", "viewer"], user.role)
    ])
    error_message = "User role must be admin, developer, or viewer."
  }
}
```

Crea `complex-main.tf`:

```hcl
# complex-main.tf

# Usar variables complejas
resource "local_file" "complex_config" {
  filename = "${path.module}/complex-config.txt"
  content  = <<-EOT
    Availability Zones:
    ${join("\n    ", var.availability_zones)}
    
    Instance Type for ${var.environment}: ${lookup(var.instance_types, var.environment, "t2.micro")}
    
    Database Configuration:
    - Engine: ${var.database_config.engine}
    - Version: ${var.database_config.engine_version}
    - Instance: ${var.database_config.instance_class}
    - Storage: ${var.database_config.allocated_storage} GB
    
    Allowed IPs:
    ${join("\n    ", var.allowed_ips)}
    
    Users:
    ${join("\n    ", [for user in var.users : "${user.name} (${user.role}) - ${user.email}"])}
  EOT
}

# Outputs
output "az_count" {
  value = length(var.availability_zones)
}

output "database_engine" {
  value = var.database_config.engine
}

output "user_count" {
  value = length(var.users)
}
```

Ejecuta:

```bash
# Aplicar
terraform apply -auto-approve

# Ver config
cat complex-config.txt

# Ver outputs
terraform output
```

### Paso 4: Archivo terraform.tfvars

Crea `terraform.tfvars`:

```hcl
# terraform.tfvars - Valores de variables

environment    = "staging"
instance_count = 3
port           = 3000
region         = "us-west-2"
enable_monitoring = true
api_key        = "my-secret-api-key-12345"

availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

instance_types = {
  dev     = "t2.nano"
  staging = "t2.micro"
  prod    = "t2.large"
}

database_config = {
  engine         = "postgres"
  engine_version = "15.2"
  instance_class = "db.t3.small"
  allocated_storage = 50
}

allowed_ips = [
  "10.0.0.0/8",
  "172.16.0.0/12",
  "192.168.0.0/16"
]

users = [
  {
    name  = "alice"
    email = "alice@example.com"
    role  = "admin"
  },
  {
    name  = "bob"
    email = "bob@example.com"
    role  = "developer"
  },
  {
    name  = "charlie"
    email = "charlie@example.com"
    role  = "viewer"
  }
]
```

Ejecuta:

```bash
# Aplicar con terraform.tfvars (se carga automáticamente)
terraform apply -auto-approve

# Ver cambios
cat config.txt
cat complex-config.txt
```

### Paso 5: Múltiples Archivos de Variables

Crea `dev.tfvars`:

```hcl
# dev.tfvars
environment    = "dev"
instance_count = 1
port           = 8080
enable_monitoring = false

database_config = {
  engine         = "postgres"
  engine_version = "14.7"
  instance_class = "db.t3.micro"
  allocated_storage = 20
}
```

Crea `prod.tfvars`:

```hcl
# prod.tfvars
environment    = "prod"
instance_count = 5
port           = 443
enable_monitoring = true

database_config = {
  engine         = "postgres"
  engine_version = "15.2"
  instance_class = "db.t3.large"
  allocated_storage = 100
}
```

Ejecuta:

```bash
# Aplicar con dev
terraform apply -var-file="dev.tfvars" -auto-approve
cat config.txt

# Aplicar con prod
terraform apply -var-file="prod.tfvars" -auto-approve
cat config.txt
```

### Paso 6: Variables de Entorno

```bash
# Definir variables de entorno (prefijo TF_VAR_)
export TF_VAR_environment="prod"
export TF_VAR_instance_count=7
export TF_VAR_port=9000

# Aplicar (usa variables de entorno)
terraform apply -auto-approve

# Ver resultado
cat config.txt

# Limpiar variables
unset TF_VAR_environment
unset TF_VAR_instance_count
unset TF_VAR_port
```

### Paso 7: Precedencia de Variables

```bash
# Orden de precedencia (menor a mayor):
# 1. Variables de entorno (TF_VAR_)
# 2. terraform.tfvars
# 3. *.auto.tfvars (alfabético)
# 4. -var-file
# 5. -var

# Ejemplo: Combinar múltiples fuentes
export TF_VAR_port=5000
terraform apply \
  -var-file="dev.tfvars" \
  -var="instance_count=2" \
  -auto-approve

# -var tiene mayor precedencia
cat config.txt
```

### Paso 8: Validaciones Avanzadas

Crea `advanced-validation.tf`:

```hcl
# advanced-validation.tf

# Validación con regex
variable "email" {
  type    = string
  default = "user@example.com"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.email))
    error_message = "Must be a valid email address."
  }
}

# Validación con múltiples condiciones
variable "password" {
  type      = string
  sensitive = true
  default   = "SecurePass123!"
  
  validation {
    condition     = length(var.password) >= 12
    error_message = "Password must be at least 12 characters."
  }
  
  validation {
    condition     = can(regex("[A-Z]", var.password))
    error_message = "Password must contain at least one uppercase letter."
  }
  
  validation {
    condition     = can(regex("[a-z]", var.password))
    error_message = "Password must contain at least one lowercase letter."
  }
  
  validation {
    condition     = can(regex("[0-9]", var.password))
    error_message = "Password must contain at least one number."
  }
  
  validation {
    condition     = can(regex("[!@#$%^&*]", var.password))
    error_message = "Password must contain at least one special character."
  }
}

# Validación de CIDR
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

# Validación de lista no vacía
variable "tags" {
  type    = map(string)
  default = {
    Project = "MyProject"
  }
  
  validation {
    condition     = length(var.tags) > 0
    error_message = "At least one tag must be specified."
  }
}
```

Ejecuta:

```bash
# Probar validaciones
terraform apply -auto-approve

# Probar email inválido (debe fallar)
terraform apply -var='email=invalid-email'

# Probar password débil (debe fallar)
terraform apply -var='password=weak'

# Probar CIDR inválido (debe fallar)
terraform apply -var='vpc_cidr=invalid'
```

### Paso 9: Terraform Console

```bash
# Abrir consola
terraform console

# Ver variables
> var.environment
> var.instance_count
> var.database_config

# Probar funciones con variables
> upper(var.environment)
> var.instance_count * 2
> lookup(var.instance_types, var.environment)

# Salir
> exit
```

### Paso 10: Limpiar

```bash
# Destruir
terraform destroy -auto-approve

# Limpiar archivos
rm -f *.txt

# Verificar
terraform state list
```

### Paso 11: Ejecutar Validación

```bash
cd ..
./validate-lab.sh
```

## 📚 Tipos de Variables

### Tipos Primitivos

```hcl
variable "string_var" {
  type = string
}

variable "number_var" {
  type = number
}

variable "bool_var" {
  type = bool
}
```

### Tipos de Colección

```hcl
variable "list_var" {
  type = list(string)
}

variable "set_var" {
  type = set(number)
}

variable "map_var" {
  type = map(string)
}
```

### Tipos Estructurales

```hcl
variable "object_var" {
  type = object({
    name = string
    age  = number
  })
}

variable "tuple_var" {
  type = tuple([string, number, bool])
}
```

## 💡 Mejores Prácticas

1. **Siempre valida variables críticas**
   ```hcl
   variable "environment" {
     validation {
       condition     = contains(["dev", "prod"], var.environment)
       error_message = "Invalid environment."
     }
   }
   ```

2. **Usa valores por defecto sensatos**
   ```hcl
   variable "instance_count" {
     default = 1  # Valor seguro
   }
   ```

3. **Marca variables sensibles**
   ```hcl
   variable "password" {
     sensitive = true
   }
   ```

4. **Documenta variables**
   ```hcl
   variable "port" {
     description = "Application port (1-65535)"
     type        = number
   }
   ```

## 🔧 Troubleshooting

### Error: "Invalid value for variable"

```bash
# La validación falló
# Lee el error_message de la validación
# Corrige el valor
```

### Variable no se actualiza

```bash
# Verifica la precedencia
# -var tiene mayor precedencia que terraform.tfvars
terraform apply -var="name=value"
```

### Variable sensible visible en logs

```bash
# Marca como sensible
variable "secret" {
  sensitive = true
}
```

## ✅ Criterios de Validación

1. ✅ Proyecto `lab3-variables` creado
2. ✅ Variables con validación implementadas
3. ✅ Tipos complejos usados
4. ✅ terraform.tfvars creado
5. ✅ Múltiples archivos .tfvars
6. ✅ Variables de entorno probadas
7. ✅ Validaciones avanzadas implementadas

## 🎓 Conceptos Aprendidos

- ✅ Variables con validación
- ✅ Tipos primitivos y complejos
- ✅ Variables sensibles
- ✅ terraform.tfvars
- ✅ Múltiples archivos de variables
- ✅ Variables de entorno (TF_VAR_)
- ✅ Precedencia de variables
- ✅ Validaciones avanzadas

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Variables Master Badge**

---

**Anterior:** [Lab 2 - Data Sources](../lab2-data-sources/)  
**Siguiente:** [Lab 4 - Outputs y Funciones](../lab4-outputs-funciones/)

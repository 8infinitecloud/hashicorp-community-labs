# Módulo 4: Terraform Configuration

![Terraform](https://img.shields.io/badge/Terraform-Configuration-7B42BC?style=for-the-badge&logo=terraform)

## 📚 Descripción del Módulo

Este módulo profundiza en la configuración avanzada de Terraform: resources con lifecycle rules, data sources para consultar infraestructura existente, variables con validación compleja, y outputs con funciones built-in.

## ⏱️ Duración Total
Aproximadamente 2 horas (4 labs de 25-35 minutos cada uno)

## 🎯 Objetivos de Aprendizaje

Al completar este módulo serás capaz de:

- ✅ Gestionar dependencias entre recursos
- ✅ Usar lifecycle rules para controlar comportamiento
- ✅ Consultar infraestructura existente con data sources
- ✅ Crear variables con validación compleja
- ✅ Usar funciones built-in de Terraform
- ✅ Crear outputs dinámicos y sensibles
- ✅ Trabajar con tipos de datos complejos

## 📋 Prerrequisitos

- ✅ Módulos 1, 2 y 3 completados
- Terraform instalado (versión 1.0+)
- Editor de texto
- Conocimientos de HCL

## 🧪 Laboratorios

### [Lab 1: Resources con Dependencias y Lifecycle](./lab1-resources-lifecycle/)
**Duración:** 35 minutos  
**Objetivo:** Crear recursos con dependencias y usar lifecycle rules

**Aprenderás:**
- Dependencias implícitas (referencias)
- Dependencias explícitas (`depends_on`)
- Lifecycle rules:
  - `create_before_destroy`
  - `prevent_destroy`
  - `ignore_changes`
- Orden de creación de recursos
- Grafo de dependencias

**Badge:** 🏆 Terraform Dependencies Master

---

### [Lab 2: Data Sources](./lab2-data-sources/)
**Duración:** 30 minutos  
**Objetivo:** Consultar infraestructura existente con data sources

**Aprenderás:**
- Obtener AMIs dinámicamente
- Consultar VPCs y subnets existentes
- Obtener información de la cuenta AWS
- Obtener zonas de disponibilidad
- Usar data sources en resources
- Filtros en data sources

**Badge:** 🏆 Terraform Data Sources Expert

---

### [Lab 3: Variables con Validación](./lab3-variables-validacion/)
**Duración:** 30 minutos  
**Objetivo:** Crear variables con validación compleja

**Aprenderás:**
- Validación con múltiples condiciones
- Tipos complejos (object, list, map)
- Variables sensibles
- Diferentes formas de pasar variables
- Precedencia de variables
- Variables de entorno (TF_VAR_)

**Badge:** 🏆 Terraform Variables Master

---

### [Lab 4: Outputs y Funciones](./lab4-outputs-funciones/)
**Duración:** 25 minutos  
**Objetivo:** Usar outputs y funciones built-in

**Aprenderás:**
- For expressions
- Funciones de string, colecciones, fecha
- Funciones de red (CIDR)
- Outputs sensibles
- Terraform console para testing
- Transformación de datos

**Badge:** 🏆 Terraform Functions Expert

---

## 🎓 Conceptos Clave

### Lifecycle Rules

```hcl
resource "aws_instance" "web" {
  # ...
  
  lifecycle {
    # Crear nuevo antes de destruir viejo
    create_before_destroy = true
    
    # Prevenir destrucción accidental
    prevent_destroy = true
    
    # Ignorar cambios en ciertos atributos
    ignore_changes = [tags, user_data]
    
    # Reemplazar si cambia cierto atributo
    replace_triggered_by = [aws_security_group.web]
  }
}
```

### Data Sources

```hcl
# Consultar AMI más reciente
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/*"]
  }
}

# Usar en resource
resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id
  # ...
}
```

### Variables con Validación

```hcl
variable "environment" {
  type = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_count" {
  type = number
  
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}
```

### Funciones Built-in

```hcl
locals {
  # String functions
  name_upper = upper("hello")
  name_lower = lower("WORLD")
  
  # Collection functions
  list_length = length([1, 2, 3])
  merged_map = merge({a = 1}, {b = 2})
  
  # Date functions
  created_at = timestamp()
  formatted = formatdate("YYYY-MM-DD", timestamp())
  
  # Network functions
  subnet_cidr = cidrsubnet("10.0.0.0/16", 8, 1)
  first_ip = cidrhost("10.0.0.0/24", 5)
}
```

## 📊 Progreso del Módulo

Completa los 4 labs en orden:

1. ⬜ Lab 1: Resources con Dependencias y Lifecycle
2. ⬜ Lab 2: Data Sources
3. ⬜ Lab 3: Variables con Validación
4. ⬜ Lab 4: Outputs y Funciones

Al completar los 4 labs obtienes: **🎖️ Terraform Configuration Complete**

## 🔧 Meta-Arguments

### count

```hcl
resource "aws_instance" "web" {
  count = 3
  
  ami           = "ami-12345"
  instance_type = "t2.micro"
  
  tags = {
    Name = "web-${count.index}"
  }
}
```

### for_each

```hcl
resource "aws_instance" "web" {
  for_each = toset(["dev", "staging", "prod"])
  
  ami           = "ami-12345"
  instance_type = "t2.micro"
  
  tags = {
    Name = "web-${each.key}"
  }
}
```

### depends_on

```hcl
resource "aws_eip" "web" {
  instance = aws_instance.web.id
  
  # Dependencia explícita
  depends_on = [aws_internet_gateway.main]
}
```

## 💡 Mejores Prácticas

### 1. Usa Data Sources para Datos Dinámicos

```hcl
# ✅ BIEN - AMI dinámica
data "aws_ami" "ubuntu" {
  most_recent = true
  # ...
}

# ❌ MAL - AMI hardcodeada
ami = "ami-12345"  # Se vuelve obsoleta
```

### 2. Valida Variables

```hcl
# ✅ BIEN - Con validación
variable "port" {
  type = number
  
  validation {
    condition     = var.port > 0 && var.port < 65536
    error_message = "Port must be between 1 and 65535."
  }
}

# ❌ MAL - Sin validación
variable "port" {
  type = number
}
```

### 3. Usa Lifecycle Rules Apropiadamente

```hcl
# Para recursos críticos
lifecycle {
  prevent_destroy = true
}

# Para recursos con downtime
lifecycle {
  create_before_destroy = true
}

# Para ignorar cambios externos
lifecycle {
  ignore_changes = [tags]
}
```

### 4. Outputs Sensibles

```hcl
# ✅ BIEN - Password sensible
output "db_password" {
  value     = random_password.db.result
  sensitive = true
}

# ❌ MAL - Password visible
output "db_password" {
  value = random_password.db.result
}
```

## 📚 Funciones Útiles

### String Functions

| Función | Descripción | Ejemplo |
|---------|-------------|---------|
| `upper()` | Mayúsculas | `upper("hello")` → `"HELLO"` |
| `lower()` | Minúsculas | `lower("WORLD")` → `"world"` |
| `trim()` | Quitar espacios | `trim("  hi  ")` → `"hi"` |
| `format()` | Formatear | `format("Hello %s", "World")` |
| `join()` | Unir lista | `join(", ", ["a", "b"])` → `"a, b"` |
| `split()` | Dividir string | `split(",", "a,b")` → `["a", "b"]` |

### Collection Functions

| Función | Descripción | Ejemplo |
|---------|-------------|---------|
| `length()` | Longitud | `length([1, 2, 3])` → `3` |
| `concat()` | Concatenar | `concat([1], [2])` → `[1, 2]` |
| `merge()` | Combinar maps | `merge({a=1}, {b=2})` |
| `keys()` | Claves de map | `keys({a=1, b=2})` → `["a", "b"]` |
| `values()` | Valores de map | `values({a=1, b=2})` → `[1, 2]` |
| `distinct()` | Sin duplicados | `distinct([1, 2, 2])` → `[1, 2]` |

### Network Functions

| Función | Descripción | Ejemplo |
|---------|-------------|---------|
| `cidrhost()` | IP de CIDR | `cidrhost("10.0.0.0/24", 5)` → `"10.0.0.5"` |
| `cidrnetmask()` | Netmask | `cidrnetmask("10.0.0.0/24")` → `"255.255.255.0"` |
| `cidrsubnet()` | Calcular subnet | `cidrsubnet("10.0.0.0/16", 8, 1)` → `"10.0.1.0/24"` |
| `cidrsubnets()` | Múltiples subnets | `cidrsubnets("10.0.0.0/16", 8, 8)` |

### Date Functions

| Función | Descripción | Ejemplo |
|---------|-------------|---------|
| `timestamp()` | Timestamp actual | `timestamp()` → `"2026-04-14T..."` |
| `formatdate()` | Formatear fecha | `formatdate("YYYY-MM-DD", timestamp())` |
| `timeadd()` | Sumar tiempo | `timeadd(timestamp(), "24h")` |

## 📚 Recursos Adicionales

### Documentación Oficial
- [Resources](https://www.terraform.io/language/resources)
- [Data Sources](https://www.terraform.io/language/data-sources)
- [Variables](https://www.terraform.io/language/values/variables)
- [Outputs](https://www.terraform.io/language/values/outputs)
- [Functions](https://www.terraform.io/language/functions)
- [Lifecycle](https://www.terraform.io/language/meta-arguments/lifecycle)

### Tutoriales
- [Define Infrastructure with Resources](https://learn.hashicorp.com/tutorials/terraform/resource)
- [Query Data Sources](https://learn.hashicorp.com/tutorials/terraform/data-sources)
- [Customize with Variables](https://learn.hashicorp.com/tutorials/terraform/variables)
- [Output Data](https://learn.hashicorp.com/tutorials/terraform/outputs)

## 🏆 Badges del Módulo

Al completar cada lab obtienes un badge:

- 🏆 **Terraform Dependencies Master** (Lab 1)
- 🏆 **Terraform Data Sources Expert** (Lab 2)
- 🏆 **Terraform Variables Master** (Lab 3)
- 🏆 **Terraform Functions Expert** (Lab 4)

Al completar los 4 labs:
- 🎖️ **Terraform Configuration Complete**

---

**¡Comienza con el Lab 1!** → [Resources con Dependencias y Lifecycle](./lab1-resources-lifecycle/)

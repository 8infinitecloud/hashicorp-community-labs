# Lab 4: Outputs y Funciones

![Terraform](https://img.shields.io/badge/Terraform-Functions-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Dominar outputs y funciones built-in de Terraform para transformar y exponer datos.

## ⏱️ Duración
25 minutos

## 📋 Prerrequisitos
- ✅ Labs 1, 2 y 3 completados
- Terraform instalado
- Editor de texto

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear el Directorio del Proyecto

```bash
mkdir lab4-outputs-funciones
cd lab4-outputs-funciones
```

### Paso 2: Funciones de String

Crea `string-functions.tf`:

```hcl
# string-functions.tf - Funciones de string

terraform {
  required_version = ">= 1.0"
}

locals {
  # Funciones básicas
  app_name       = "MyApp"
  name_upper     = upper(local.app_name)
  name_lower     = lower(local.app_name)
  name_title     = title(local.app_name)
  
  # Trim y strip
  text_with_spaces = "  hello world  "
  text_trimmed     = trim(local.text_with_spaces, " ")
  text_trimprefix  = trimprefix("https://example.com", "https://")
  text_trimsuffix  = trimsuffix("file.txt", ".txt")
  
  # Join y split
  list_items    = ["apple", "banana", "orange"]
  joined_string = join(", ", local.list_items)
  split_result  = split(",", "a,b,c,d")
  
  # Format
  formatted = format("Hello %s, you have %d messages", "Alice", 5)
  
  # Replace
  original = "Hello World"
  replaced = replace(local.original, "World", "Terraform")
  
  # Substr
  long_text = "Terraform is awesome"
  substring = substr(local.long_text, 0, 9)
  
  # Regex
  email         = "user@example.com"
  domain        = regex("@(.+)$", local.email)[0]
  has_uppercase = can(regex("[A-Z]", "Hello"))
}

# Crear archivo con resultados
resource "local_file" "string_results" {
  filename = "${path.module}/string-results.txt"
  content  = <<-EOT
    String Functions:
    
    Original: ${local.app_name}
    Upper: ${local.name_upper}
    Lower: ${local.name_lower}
    Title: ${local.name_title}
    
    Trim: '${local.text_trimmed}'
    Trim Prefix: ${local.text_trimprefix}
    Trim Suffix: ${local.text_trimsuffix}
    
    Join: ${local.joined_string}
    Split: ${jsonencode(local.split_result)}
    
    Format: ${local.formatted}
    Replace: ${local.replaced}
    Substr: ${local.substring}
    
    Email Domain: ${local.domain}
    Has Uppercase: ${local.has_uppercase}
  EOT
}

# Outputs
output "string_functions" {
  value = {
    upper     = local.name_upper
    lower     = local.name_lower
    joined    = local.joined_string
    formatted = local.formatted
  }
}
```

Ejecuta:

```bash
# Inicializar
terraform init

# Aplicar
terraform apply -auto-approve

# Ver resultados
cat string-results.txt

# Ver outputs
terraform output string_functions
```

### Paso 3: Funciones de Colecciones

Crea `collection-functions.tf`:

```hcl
# collection-functions.tf - Funciones de colecciones

locals {
  # Length
  my_list   = ["a", "b", "c", "d"]
  list_len  = length(local.my_list)
  
  # Concat
  list1     = ["a", "b"]
  list2     = ["c", "d"]
  combined  = concat(local.list1, local.list2)
  
  # Contains
  has_item  = contains(local.my_list, "b")
  
  # Element
  first_item  = element(local.my_list, 0)
  second_item = element(local.my_list, 1)
  
  # Index
  index_of_c = index(local.my_list, "c")
  
  # Slice
  sliced = slice(local.my_list, 1, 3)
  
  # Distinct
  with_duplicates = ["a", "b", "a", "c", "b"]
  unique_items    = distinct(local.with_duplicates)
  
  # Flatten
  nested_list = [["a", "b"], ["c", "d"]]
  flat_list   = flatten(local.nested_list)
  
  # Reverse
  reversed = reverse(local.my_list)
  
  # Sort
  unsorted = ["zebra", "apple", "banana"]
  sorted   = sort(local.unsorted)
  
  # Map functions
  my_map = {
    name = "Alice"
    age  = 30
    city = "NYC"
  }
  map_keys   = keys(local.my_map)
  map_values = values(local.my_map)
  
  # Merge
  map1   = { a = 1, b = 2 }
  map2   = { c = 3, d = 4 }
  merged = merge(local.map1, local.map2)
  
  # Lookup
  env_config = {
    dev  = "t2.micro"
    prod = "t2.large"
  }
  instance_type = lookup(local.env_config, "dev", "t2.nano")
  
  # Zipmap
  names  = ["alice", "bob", "charlie"]
  ages   = [30, 25, 35]
  people = zipmap(local.names, local.ages)
}

resource "local_file" "collection_results" {
  filename = "${path.module}/collection-results.txt"
  content  = <<-EOT
    Collection Functions:
    
    Original List: ${jsonencode(local.my_list)}
    Length: ${local.list_len}
    
    Concat: ${jsonencode(local.combined)}
    Contains 'b': ${local.has_item}
    
    First Item: ${local.first_item}
    Index of 'c': ${local.index_of_c}
    
    Sliced [1:3]: ${jsonencode(local.sliced)}
    Distinct: ${jsonencode(local.unique_items)}
    Flattened: ${jsonencode(local.flat_list)}
    Reversed: ${jsonencode(local.reversed)}
    Sorted: ${jsonencode(local.sorted)}
    
    Map Keys: ${jsonencode(local.map_keys)}
    Map Values: ${jsonencode(local.map_values)}
    Merged: ${jsonencode(local.merged)}
    
    Lookup: ${local.instance_type}
    Zipmap: ${jsonencode(local.people)}
  EOT
}

output "collection_functions" {
  value = {
    length   = local.list_len
    distinct = local.unique_items
    sorted   = local.sorted
    merged   = local.merged
  }
}
```

Ejecuta:

```bash
# Aplicar
terraform apply -auto-approve

# Ver resultados
cat collection-results.txt

# Ver outputs
terraform output collection_functions
```

### Paso 4: Funciones Numéricas y de Fecha

Crea `numeric-date-functions.tf`:

```hcl
# numeric-date-functions.tf

locals {
  # Funciones numéricas
  num1 = 10
  num2 = 3
  
  max_val = max(5, 10, 3, 8)
  min_val = min(5, 10, 3, 8)
  abs_val = abs(-42)
  ceil_val = ceil(4.3)
  floor_val = floor(4.7)
  
  # Funciones de fecha
  current_time = timestamp()
  formatted_date = formatdate("YYYY-MM-DD", timestamp())
  formatted_time = formatdate("hh:mm:ss", timestamp())
  formatted_full = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  
  # Timeadd
  tomorrow = timeadd(timestamp(), "24h")
  next_week = timeadd(timestamp(), "168h")
  
  # Plantimestamp (para fechas fijas)
  fixed_date = plantimestamp()
}

resource "local_file" "numeric_date_results" {
  filename = "${path.module}/numeric-date-results.txt"
  content  = <<-EOT
    Numeric Functions:
    
    Max(5,10,3,8): ${local.max_val}
    Min(5,10,3,8): ${local.min_val}
    Abs(-42): ${local.abs_val}
    Ceil(4.3): ${local.ceil_val}
    Floor(4.7): ${local.floor_val}
    
    Date Functions:
    
    Current Time: ${local.current_time}
    Date: ${local.formatted_date}
    Time: ${local.formatted_time}
    Full: ${local.formatted_full}
    
    Tomorrow: ${formatdate("YYYY-MM-DD", local.tomorrow)}
    Next Week: ${formatdate("YYYY-MM-DD", local.next_week)}
  EOT
}

output "date_info" {
  value = {
    current = local.formatted_full
    date    = local.formatted_date
    time    = local.formatted_time
  }
}
```

Ejecuta:

```bash
# Aplicar
terraform apply -auto-approve

# Ver resultados
cat numeric-date-results.txt

# Ver outputs
terraform output date_info
```

### Paso 5: Funciones de Red (CIDR)

Crea `network-functions.tf`:

```hcl
# network-functions.tf - Funciones de red

locals {
  # CIDR base
  vpc_cidr = "10.0.0.0/16"
  
  # Cidrhost - Obtener IP específica
  first_ip    = cidrhost(local.vpc_cidr, 0)
  second_ip   = cidrhost(local.vpc_cidr, 1)
  tenth_ip    = cidrhost(local.vpc_cidr, 10)
  last_ip     = cidrhost(local.vpc_cidr, -1)
  
  # Cidrnetmask - Obtener máscara de red
  netmask = cidrnetmask(local.vpc_cidr)
  
  # Cidrsubnet - Calcular subnets
  subnet_1 = cidrsubnet(local.vpc_cidr, 8, 0)  # 10.0.0.0/24
  subnet_2 = cidrsubnet(local.vpc_cidr, 8, 1)  # 10.0.1.0/24
  subnet_3 = cidrsubnet(local.vpc_cidr, 8, 2)  # 10.0.2.0/24
  
  # Cidrsubnets - Múltiples subnets
  subnets = cidrsubnets(local.vpc_cidr, 8, 8, 8, 8)
  
  # Crear subnets para diferentes AZs
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  subnet_cidrs = [
    for i, az in local.availability_zones :
    cidrsubnet(local.vpc_cidr, 8, i)
  ]
}

resource "local_file" "network_results" {
  filename = "${path.module}/network-results.txt"
  content  = <<-EOT
    Network Functions:
    
    VPC CIDR: ${local.vpc_cidr}
    Netmask: ${local.netmask}
    
    IP Addresses:
    - First IP: ${local.first_ip}
    - Second IP: ${local.second_ip}
    - Tenth IP: ${local.tenth_ip}
    - Last IP: ${local.last_ip}
    
    Subnets:
    - Subnet 1: ${local.subnet_1}
    - Subnet 2: ${local.subnet_2}
    - Subnet 3: ${local.subnet_3}
    
    All Subnets: ${jsonencode(local.subnets)}
    
    AZ Subnets:
    ${join("\n    ", [for i, az in local.availability_zones : "${az}: ${local.subnet_cidrs[i]}"])}
  EOT
}

output "network_info" {
  value = {
    vpc_cidr = local.vpc_cidr
    netmask  = local.netmask
    subnets  = local.subnet_cidrs
  }
}
```

Ejecuta:

```bash
# Aplicar
terraform apply -auto-approve

# Ver resultados
cat network-results.txt

# Ver outputs
terraform output network_info
```

### Paso 6: For Expressions

Crea `for-expressions.tf`:

```hcl
# for-expressions.tf - Expresiones for

locals {
  # Lista simple
  numbers = [1, 2, 3, 4, 5]
  
  # For con transformación
  doubled = [for n in local.numbers : n * 2]
  squared = [for n in local.numbers : n * n]
  
  # For con condición
  evens = [for n in local.numbers : n if n % 2 == 0]
  odds  = [for n in local.numbers : n if n % 2 != 0]
  
  # For con map
  users = {
    alice   = "admin"
    bob     = "developer"
    charlie = "viewer"
  }
  
  # Transformar map a lista
  user_list = [for name, role in local.users : "${name} is ${role}"]
  
  # Transformar map a map
  upper_users = { for name, role in local.users : upper(name) => upper(role) }
  
  # For con objetos
  instances = [
    { name = "web-1", type = "t2.micro" },
    { name = "web-2", type = "t2.small" },
    { name = "db-1", type = "t2.medium" }
  ]
  
  instance_names = [for i in local.instances : i.name]
  instance_types = [for i in local.instances : i.type]
  
  # Filtrar instancias
  web_instances = [for i in local.instances : i if can(regex("^web-", i.name))]
  
  # For anidado
  matrix = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
  ]
  flattened = flatten([for row in local.matrix : [for val in row : val * 10]])
}

resource "local_file" "for_results" {
  filename = "${path.module}/for-results.txt"
  content  = <<-EOT
    For Expressions:
    
    Original: ${jsonencode(local.numbers)}
    Doubled: ${jsonencode(local.doubled)}
    Squared: ${jsonencode(local.squared)}
    
    Evens: ${jsonencode(local.evens)}
    Odds: ${jsonencode(local.odds)}
    
    Users: ${jsonencode(local.users)}
    User List: ${jsonencode(local.user_list)}
    Upper Users: ${jsonencode(local.upper_users)}
    
    Instance Names: ${jsonencode(local.instance_names)}
    Instance Types: ${jsonencode(local.instance_types)}
    Web Instances: ${jsonencode(local.web_instances)}
    
    Flattened Matrix: ${jsonencode(local.flattened)}
  EOT
}

output "for_expressions" {
  value = {
    doubled       = local.doubled
    evens         = local.evens
    user_list     = local.user_list
    web_instances = local.web_instances
  }
}
```

Ejecuta:

```bash
# Aplicar
terraform apply -auto-approve

# Ver resultados
cat for-results.txt

# Ver outputs
terraform output for_expressions
```

### Paso 7: Outputs Avanzados

Crea `advanced-outputs.tf`:

```hcl
# advanced-outputs.tf - Outputs avanzados

variable "db_password" {
  type      = string
  sensitive = true
  default   = "super-secret-password"
}

locals {
  environment = "production"
  
  app_config = {
    name    = "MyApp"
    version = "1.0.0"
    port    = 8080
  }
  
  servers = [
    { name = "web-1", ip = "10.0.1.10" },
    { name = "web-2", ip = "10.0.1.11" },
    { name = "db-1", ip = "10.0.2.10" }
  ]
}

# Output simple
output "environment" {
  description = "Current environment"
  value       = local.environment
}

# Output con objeto
output "app_config" {
  description = "Application configuration"
  value       = local.app_config
}

# Output sensible
output "db_password" {
  description = "Database password"
  value       = var.db_password
  sensitive   = true
}

# Output con transformación
output "server_ips" {
  description = "List of server IPs"
  value       = [for s in local.servers : s.ip]
}

# Output con map
output "server_map" {
  description = "Map of servers"
  value       = { for s in local.servers : s.name => s.ip }
}

# Output condicional
output "is_production" {
  description = "Is production environment"
  value       = local.environment == "production"
}

# Output con formato
output "app_url" {
  description = "Application URL"
  value       = format("http://%s:%d", local.servers[0].ip, local.app_config.port)
}

# Output JSON
output "config_json" {
  description = "Configuration as JSON"
  value       = jsonencode(local.app_config)
}
```

Ejecuta:

```bash
# Aplicar
terraform apply -auto-approve

# Ver todos los outputs
terraform output

# Ver output específico
terraform output environment
terraform output server_ips

# Ver output sensible (oculto por defecto)
terraform output db_password

# Ver output en JSON
terraform output -json

# Ver output específico en formato raw
terraform output -raw config_json
```

### Paso 8: Terraform Console - Testing

```bash
# Abrir consola interactiva
terraform console

# Probar funciones de string
> upper("hello")
> lower("WORLD")
> join(", ", ["a", "b", "c"])

# Probar funciones de colecciones
> length([1, 2, 3, 4])
> concat([1, 2], [3, 4])
> distinct([1, 2, 2, 3, 3])

# Probar funciones de red
> cidrhost("10.0.0.0/24", 5)
> cidrsubnet("10.0.0.0/16", 8, 1)

# Probar for expressions
> [for i in [1, 2, 3] : i * 2]
> [for i in [1, 2, 3, 4] : i if i % 2 == 0]

# Probar funciones de fecha
> timestamp()
> formatdate("YYYY-MM-DD", timestamp())

# Ver locals
> local.app_config
> local.servers

# Salir
> exit
```

### Paso 9: Crear Resumen Completo

Crea `summary.tf`:

```hcl
# summary.tf - Resumen de todas las funciones

resource "local_file" "function_summary" {
  filename = "${path.module}/function-summary.txt"
  content  = <<-EOT
    ========================================
    TERRAFORM FUNCTIONS SUMMARY
    ========================================
    
    STRING FUNCTIONS:
    - upper(), lower(), title()
    - trim(), trimprefix(), trimsuffix()
    - join(), split()
    - format(), replace(), substr()
    - regex()
    
    COLLECTION FUNCTIONS:
    - length(), concat(), contains()
    - element(), index(), slice()
    - distinct(), flatten(), reverse(), sort()
    - keys(), values(), merge(), lookup()
    - zipmap()
    
    NUMERIC FUNCTIONS:
    - max(), min(), abs()
    - ceil(), floor()
    
    DATE FUNCTIONS:
    - timestamp()
    - formatdate()
    - timeadd()
    
    NETWORK FUNCTIONS:
    - cidrhost()
    - cidrnetmask()
    - cidrsubnet()
    - cidrsubnets()
    
    FOR EXPRESSIONS:
    - [for item in list : transform]
    - [for item in list : item if condition]
    - {for key, val in map : key => val}
    
    OUTPUTS:
    - Simple outputs
    - Sensitive outputs
    - Transformed outputs
    - JSON outputs
    
    ========================================
    Lab 4 Completed! 🎉
    ========================================
  EOT
}

output "lab_complete" {
  value = "🎉 Lab 4: Outputs y Funciones - Completado!"
}
```

Ejecuta:

```bash
# Aplicar
terraform apply -auto-approve

# Ver resumen
cat function-summary.txt

# Ver output final
terraform output lab_complete
```

### Paso 10: Limpiar

```bash
# Destruir todos los recursos
terraform destroy -auto-approve

# Verificar
terraform state list

# Limpiar archivos
rm -f *.txt
```

### Paso 11: Ejecutar Validación

```bash
cd ..
./validate-lab.sh
```

## 📚 Referencia Rápida de Funciones

### String Functions

| Función | Ejemplo | Resultado |
|---------|---------|-----------|
| `upper()` | `upper("hello")` | `"HELLO"` |
| `lower()` | `lower("WORLD")` | `"world"` |
| `title()` | `title("hello world")` | `"Hello World"` |
| `trim()` | `trim("  hi  ", " ")` | `"hi"` |
| `join()` | `join(", ", ["a", "b"])` | `"a, b"` |
| `split()` | `split(",", "a,b,c")` | `["a", "b", "c"]` |
| `format()` | `format("Hello %s", "World")` | `"Hello World"` |
| `replace()` | `replace("hello", "l", "L")` | `"heLLo"` |

### Collection Functions

| Función | Ejemplo | Resultado |
|---------|---------|-----------|
| `length()` | `length([1, 2, 3])` | `3` |
| `concat()` | `concat([1], [2])` | `[1, 2]` |
| `contains()` | `contains([1, 2], 2)` | `true` |
| `distinct()` | `distinct([1, 2, 2])` | `[1, 2]` |
| `flatten()` | `flatten([[1], [2]])` | `[1, 2]` |
| `merge()` | `merge({a=1}, {b=2})` | `{a=1, b=2}` |
| `keys()` | `keys({a=1, b=2})` | `["a", "b"]` |
| `values()` | `values({a=1, b=2})` | `[1, 2]` |

### Network Functions

| Función | Ejemplo | Resultado |
|---------|---------|-----------|
| `cidrhost()` | `cidrhost("10.0.0.0/24", 5)` | `"10.0.0.5"` |
| `cidrnetmask()` | `cidrnetmask("10.0.0.0/24")` | `"255.255.255.0"` |
| `cidrsubnet()` | `cidrsubnet("10.0.0.0/16", 8, 1)` | `"10.0.1.0/24"` |

## 💡 Mejores Prácticas

1. **Usa locals para cálculos complejos**
   ```hcl
   locals {
     subnet_cidrs = [for i in range(3) : cidrsubnet(var.vpc_cidr, 8, i)]
   }
   ```

2. **Outputs sensibles para secretos**
   ```hcl
   output "password" {
     value     = random_password.db.result
     sensitive = true
   }
   ```

3. **Documenta outputs**
   ```hcl
   output "instance_ip" {
     description = "Public IP of the instance"
     value       = aws_instance.web.public_ip
   }
   ```

4. **Usa terraform console para testing**
   ```bash
   terraform console
   > cidrsubnet("10.0.0.0/16", 8, 1)
   ```

## ✅ Criterios de Validación

1. ✅ Proyecto `lab4-outputs-funciones` creado
2. ✅ Funciones de string implementadas
3. ✅ Funciones de colecciones implementadas
4. ✅ Funciones de red implementadas
5. ✅ For expressions usadas
6. ✅ Outputs avanzados creados
7. ✅ Terraform console usado

## 🎓 Conceptos Aprendidos

- ✅ Funciones de string
- ✅ Funciones de colecciones
- ✅ Funciones numéricas y de fecha
- ✅ Funciones de red (CIDR)
- ✅ For expressions
- ✅ Outputs simples y sensibles
- ✅ Terraform console

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Functions Expert Badge**

---

**Anterior:** [Lab 3 - Variables con Validación](../lab3-variables-validacion/)  
**Siguiente:** [Módulo 5 - Terraform Modules](../../05-terraform-modules/)

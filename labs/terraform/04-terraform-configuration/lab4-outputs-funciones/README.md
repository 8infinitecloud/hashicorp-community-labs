# Lab 4: Outputs y Funciones

![Terraform](https://img.shields.io/badge/Terraform-Functions-7B42BC?style=flat&logo=terraform)

## Objetivo

Usar las funciones built-in de Terraform para transformar cadenas, colecciones, números y CIDRs, y exponer resultados mediante outputs simples, tipados, sensibles y derivados con expresiones `for`. Todo usando el provider `local` sin necesidad de credenciales de nube.

## Duración

25 minutos

## Prerrequisitos

- Labs 1, 2 y 3 completados
- Terraform instalado (`terraform version` >= 1.0)

## Instrucciones Paso a Paso

### Paso 1: Crear la Estructura del Proyecto

```bash
mkdir -p /root/lab/output
```

El directorio `/root/lab` contendrá todos los archivos `.tf`. El subdirectorio `output/` guardará los archivos generados por los recursos para facilitar su inspección al final del lab.

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
EOF
```

El bloque `terraform` es el único lugar donde se declaran los providers requeridos. Sin él, Terraform no sabe qué plugins descargar en el `init`.

### Paso 3: Crear string-functions.tf con Funciones de Cadena

```bash
touch /root/lab/string-functions.tf
```

```bash
cat > /root/lab/string-functions.tf <<'EOF'
locals {
  app_name = "MyApp"

  # Cambio de case
  name_upper = upper(local.app_name)
  name_lower = lower(local.app_name)

  # Recorte de espacios y prefijos/sufijos
  raw_text       = "  hello world  "
  text_trimmed   = trimspace(local.raw_text)
  text_nohttps   = trimprefix("https://example.com", "https://")
  text_noext     = trimsuffix("report.txt", ".txt")

  # Union y separacion
  items  = ["alpha", "beta", "gamma"]
  joined = join(", ", local.items)
  parts  = split("/", "a/b/c/d")

  # Formato y reemplazo
  greeting = format("Hola %s, tienes %d mensajes", "Alice", 3)
  replaced = replace("Hello World", "World", "Terraform")

  # Subcadena
  substring = substr("Terraform rocks", 0, 9)
}

resource "local_file" "string_results" {
  filename = "/root/lab/output/string-results.txt"
  content  = <<-EOT
    upper      : ${local.name_upper}
    lower      : ${local.name_lower}
    trimspace  : '${local.text_trimmed}'
    trimprefix : ${local.text_nohttps}
    trimsuffix : ${local.text_noext}
    join       : ${local.joined}
    split      : ${jsonencode(local.parts)}
    format     : ${local.greeting}
    replace    : ${local.replaced}
    substr     : ${local.substring}
  EOT
}

output "string_functions" {
  description = "Resultados de funciones de cadena"
  value = {
    upper   = local.name_upper
    joined  = local.joined
    greeting = local.greeting
  }
}
EOF
```

Los `locals` calculan valores intermedios una sola vez y los reutilizan en cualquier parte del módulo. Son equivalentes a variables locales de un lenguaje de programación: evitan repetir expresiones complejas.

### Paso 4: Crear collection-functions.tf con Funciones de Coleccion

```bash
touch /root/lab/collection-functions.tf
```

```bash
cat > /root/lab/collection-functions.tf <<'EOF'
locals {
  letters = ["c", "a", "b", "a", "c"]

  # Operaciones sobre listas
  letters_unique  = distinct(local.letters)
  letters_sorted  = sort(distinct(local.letters))
  letters_reversed = reverse(local.letters)
  letters_sliced  = slice(local.letters, 1, 4)

  # Concat de listas
  extra   = ["d", "e"]
  all     = concat(local.letters, local.extra)

  # Flatten de lista de listas
  nested  = [["x", "y"], ["z"]]
  flat    = flatten(local.nested)

  # Operaciones sobre mapas
  sizes = {
    dev     = "small"
    staging = "medium"
    prod    = "large"
  }
  map_keys   = keys(local.sizes)
  map_values = values(local.sizes)

  # Merge de dos mapas (el segundo gana en conflicto)
  defaults   = { color = "blue", size = "medium" }
  overrides  = { size = "large", shape = "circle" }
  merged     = merge(local.defaults, local.overrides)

  # zipmap: combina dos listas en un mapa
  envs  = ["dev", "staging", "prod"]
  costs = [10, 50, 200]
  cost_map = zipmap(local.envs, local.costs)
}

resource "local_file" "collection_results" {
  filename = "/root/lab/output/collection-results.txt"
  content  = <<-EOT
    letters   : ${jsonencode(local.letters)}
    unique    : ${jsonencode(local.letters_unique)}
    sorted    : ${jsonencode(local.letters_sorted)}
    reversed  : ${jsonencode(local.letters_reversed)}
    sliced    : ${jsonencode(local.letters_sliced)}
    concat    : ${jsonencode(local.all)}
    flatten   : ${jsonencode(local.flat)}

    map keys  : ${jsonencode(local.map_keys)}
    map values: ${jsonencode(local.map_values)}
    merged    : ${jsonencode(local.merged)}
    zipmap    : ${jsonencode(local.cost_map)}
  EOT
}

output "collection_functions" {
  description = "Resultados de funciones de coleccion"
  value = {
    unique  = local.letters_unique
    sorted  = local.letters_sorted
    merged  = local.merged
    zipmap  = local.cost_map
  }
}
EOF
```

`distinct` elimina duplicados conservando el orden de primera aparición. `flatten` convierte una lista de listas en una lista plana. `merge` combina mapas y el último en ser listado gana en caso de clave duplicada.

### Paso 5: Crear numeric-functions.tf con Funciones Numericas y de Fecha

```bash
touch /root/lab/numeric-functions.tf
```

```bash
cat > /root/lab/numeric-functions.tf <<'EOF'
locals {
  # Funciones numericas
  max_val   = max(5, 10, 3, 8)
  min_val   = min(5, 10, 3, 8)
  abs_val   = abs(-42)
  ceil_val  = ceil(4.3)
  floor_val = floor(4.7)

  # Fecha y hora (nota: timestamp() cambia en cada apply)
  now           = timestamp()
  today         = formatdate("YYYY-MM-DD", local.now)
  tomorrow      = formatdate("YYYY-MM-DD", timeadd(local.now, "24h"))
  next_week     = formatdate("YYYY-MM-DD", timeadd(local.now, "168h"))
}

resource "local_file" "numeric_results" {
  filename = "/root/lab/output/numeric-results.txt"
  content  = <<-EOT
    max(5,10,3,8) : ${local.max_val}
    min(5,10,3,8) : ${local.min_val}
    abs(-42)      : ${local.abs_val}
    ceil(4.3)     : ${local.ceil_val}
    floor(4.7)    : ${local.floor_val}

    today         : ${local.today}
    tomorrow      : ${local.tomorrow}
    next_week     : ${local.next_week}
  EOT

  lifecycle {
    ignore_changes = [content]
  }
}

output "numeric_functions" {
  description = "Resultados de funciones numericas"
  value = {
    max   = local.max_val
    min   = local.min_val
    today = local.today
  }
}
EOF
```

`timestamp()` devuelve la hora actual en RFC 3339 y cambia en cada apply. Se usa `ignore_changes = [content]` para que Terraform no reescriba el archivo en cada ejecución posterior. `timeadd` suma una duración (`"24h"`, `"30m"`, `"-1h"`) a un timestamp.

### Paso 6: Crear network-functions.tf con Funciones de Red

```bash
touch /root/lab/network-functions.tf
```

```bash
cat > /root/lab/network-functions.tf <<'EOF'
locals {
  vpc_cidr = "10.0.0.0/16"

  # Hosts dentro del CIDR
  first_ip  = cidrhost(local.vpc_cidr, 1)
  tenth_ip  = cidrhost(local.vpc_cidr, 10)
  last_ip   = cidrhost(local.vpc_cidr, -1)

  # Mascara de red
  netmask = cidrnetmask(local.vpc_cidr)

  # Subnets individuales
  subnet_a = cidrsubnet(local.vpc_cidr, 8, 0)
  subnet_b = cidrsubnet(local.vpc_cidr, 8, 1)
  subnet_c = cidrsubnet(local.vpc_cidr, 8, 2)

  # For expression para generar N subnets
  az_count  = 3
  az_subnets = [for i in range(local.az_count) : cidrsubnet(local.vpc_cidr, 8, i)]
}

resource "local_file" "network_results" {
  filename = "/root/lab/output/network-results.txt"
  content  = <<-EOT
    VPC CIDR  : ${local.vpc_cidr}
    Netmask   : ${local.netmask}
    First IP  : ${local.first_ip}
    Tenth IP  : ${local.tenth_ip}
    Last IP   : ${local.last_ip}
    Subnet A  : ${local.subnet_a}
    Subnet B  : ${local.subnet_b}
    Subnet C  : ${local.subnet_c}
    AZ Subnets: ${jsonencode(local.az_subnets)}
  EOT
}

output "network_functions" {
  description = "Resultados de funciones de red"
  value = {
    vpc_cidr   = local.vpc_cidr
    netmask    = local.netmask
    az_subnets = local.az_subnets
  }
}
EOF
```

`cidrsubnet(prefix, newbits, netnum)` calcula una subred del bloque dado. `newbits` son los bits adicionales de prefijo y `netnum` es el número de la subred. `cidrhost` devuelve la dirección IP de un host dentro del CIDR; los índices negativos cuentan desde el final del rango.

### Paso 7: Crear for-expressions.tf con Expresiones For

```bash
touch /root/lab/for-expressions.tf
```

```bash
cat > /root/lab/for-expressions.tf <<'EOF'
locals {
  numbers = [1, 2, 3, 4, 5]

  # Transformar lista
  doubled = [for n in local.numbers : n * 2]

  # Filtrar lista
  evens = [for n in local.numbers : n if n % 2 == 0]

  # Transformar mapa a lista
  roles = { alice = "admin", bob = "developer", charlie = "viewer" }
  role_strings = [for name, role in local.roles : "${name} es ${role}"]

  # Transformar mapa a mapa
  roles_upper = { for name, role in local.roles : upper(name) => upper(role) }

  # Filtrar objetos
  servers = [
    { name = "web-01", type = "web" },
    { name = "web-02", type = "web" },
    { name = "db-01", type = "database" },
  ]
  web_servers = [for s in local.servers : s if s.type == "web"]
  server_map  = { for s in local.servers : s.name => s.type }
}

resource "local_file" "for_results" {
  filename = "/root/lab/output/for-results.txt"
  content  = <<-EOT
    numbers     : ${jsonencode(local.numbers)}
    doubled     : ${jsonencode(local.doubled)}
    evens       : ${jsonencode(local.evens)}
    role_strings: ${jsonencode(local.role_strings)}
    roles_upper : ${jsonencode(local.roles_upper)}
    web_servers : ${jsonencode(local.web_servers)}
    server_map  : ${jsonencode(local.server_map)}
  EOT
}

output "for_expressions" {
  description = "Resultados de expresiones for"
  value = {
    doubled     = local.doubled
    evens       = local.evens
    web_servers = local.web_servers
    server_map  = local.server_map
  }
}
EOF
```

Las expresiones `for` tienen dos formas: `[for x in list : expr]` produce una lista, y `{for k, v in map : k => v}` produce un mapa. Ambas aceptan un filtro opcional con `if condición` al final. Son la forma idiomática de transformar colecciones en Terraform.

### Paso 8: Crear advanced-outputs.tf con Outputs Tipados y Sensibles

```bash
touch /root/lab/advanced-outputs.tf
```

```bash
cat > /root/lab/advanced-outputs.tf <<'EOF'
variable "db_password" {
  type      = string
  sensitive = true
  default   = "super-secret-password-123"
}

locals {
  app = {
    name    = "MyApp"
    version = "2.0.0"
    port    = 8080
  }
}

# Output simple con descripcion
output "app_name" {
  description = "Nombre de la aplicacion"
  value       = local.app.name
}

# Output de objeto
output "app_config" {
  description = "Configuracion completa de la aplicacion"
  value       = local.app
}

# Output sensible — Terraform oculta el valor en la terminal
output "db_password" {
  description = "Contrasena de la base de datos"
  value       = var.db_password
  sensitive   = true
}

# Output derivado con for expression
output "server_map" {
  description = "Mapa nombre=>tipo de servidores"
  value       = { for s in local.servers : s.name => s.type }
}

# Output booleano derivado
output "is_production" {
  description = "Indica si la configuracion es de produccion"
  value       = local.app.port == 443
}

# Output con format
output "app_url" {
  description = "URL de la aplicacion"
  value       = format("http://localhost:%d/%s", local.app.port, lower(local.app.name))
}
EOF
```

Los outputs son el contrato de salida de un módulo: lo que expone hacia afuera. Cuando un módulo es invocado desde otro, sus outputs son accesibles con `module.nombre.output_name`. El atributo `sensitive = true` en un output impide que el valor aparezca en la salida de la terminal aunque sí quede registrado en el estado.

### Paso 9: Inicializar y Aplicar

```bash
terraform -chdir=/root/lab init
```

```bash
terraform -chdir=/root/lab apply -auto-approve
```

Terraform calcula todos los `locals`, los pasa a los recursos y registra el estado. Observa que el output `db_password` aparece como `(sensitive value)` en la salida del apply.

### Paso 10: Inspeccionar Outputs

```bash
terraform -chdir=/root/lab output
```

```bash
terraform -chdir=/root/lab output -json
```

```bash
terraform -chdir=/root/lab output app_config
```

`terraform output` lista todos los outputs no sensibles. `-json` los imprime en formato JSON (incluye los sensibles enmascarados). Para ver el valor de un output sensible: `terraform output db_password` (muestra el valor en la terminal; úsalo con cuidado).

### Paso 11: Verificar los Archivos Generados

```bash
cat /root/lab/output/string-results.txt
```

```bash
cat /root/lab/output/network-results.txt
```

```bash
cat /root/lab/output/for-results.txt
```

Cada archivo corresponde a un recurso `local_file` y contiene los valores calculados por las funciones de Terraform. Compara los resultados con las expresiones del código para reforzar la comprensión de cada función.

### Paso 12: Ir al Directorio del Lab

```bash
cd /root/lab
```

### Paso 13: Ejecutar la Validacion

```bash
bash validate-lab.sh
```

## Conceptos

| Concepto | Descripcion |
|---|---|
| `locals` | Valores intermedios reutilizables calculados una sola vez por plan; equivalentes a variables locales |
| `upper()` / `lower()` / `title()` | Cambian el case de una cadena |
| `join()` / `split()` | Unen una lista en cadena o separan una cadena en lista usando un delimitador |
| `format()` | Cadena con marcadores de posición (`%s`, `%d`) al estilo printf |
| `distinct()` / `sort()` / `flatten()` | Eliminan duplicados, ordenan y aplanan listas anidadas |
| `merge()` | Combina dos o más mapas; las claves del mapa más a la derecha ganan |
| `cidrsubnet()` | Calcula un bloque CIDR hijo dado bits adicionales de prefijo y número de subred |
| `cidrhost()` | Devuelve la dirección IP de un host dentro de un CIDR; índices negativos desde el final |
| `for` expression | Transforma o filtra listas y mapas; produce lista con `[...]` o mapa con `{...}` |
| `output` | Expone valores del módulo; `sensitive = true` oculta el valor en terminal y plan |

---

**Anterior:** [Lab 3 - Variables con Validacion](../lab3-variables-validacion/)
**Siguiente:** [Modulo 5 - Terraform Modules](../../05-terraform-modules/)

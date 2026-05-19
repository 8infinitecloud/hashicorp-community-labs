# Lab 1: HCL y Tipos de Datos

## Objetivo

Familiarizarte con la sintaxis HCL (HashiCorp Configuration Language) explorando todos los tipos de datos de Terraform: primitivos, colecciones y estructurales, junto con las funciones built-in mas usadas.

## Duracion

30 minutos

## Prerrequisitos

- Modulo 1 completado
- Terraform instalado (verificar con `terraform version`)

## Instrucciones

### Paso 1: Crear el directorio del proyecto

```bash
mkdir lab1-hcl
```

Crea el directorio de trabajo aislado para este lab.

```bash
cd lab1-hcl
```

Entra al directorio para que todos los comandos operen dentro de el.

### Paso 2: Crear el archivo main.tf

```bash
touch main.tf
```

Crea el archivo vacio antes de escribir el contenido.

```bash
cat > main.tf <<'EOF'
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# --- Tipos primitivos ---
variable "app_name" {
  description = "Nombre de la aplicacion"
  type        = string
  default     = "PeruApp"
}

variable "instance_count" {
  description = "Numero de instancias"
  type        = number
  default     = 3
}

variable "enable_monitoring" {
  description = "Habilitar monitoreo"
  type        = bool
  default     = true
}

# --- Tipos de coleccion ---
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

# --- Tipo estructural ---
variable "server_config" {
  description = "Configuracion del servidor"
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

# --- Locals: valores calculados ---
locals {
  full_app_name  = "${var.app_name}-${var.tags["Environment"]}"
  instance_type  = var.tags["Environment"] == "produccion" ? "t3.large" : "t2.micro"
  app_name_upper = upper(var.app_name)
  app_name_lower = lower(var.app_name)
  az_count       = length(var.availability_zones)
  first_az       = var.availability_zones[0]
  server_url     = format("http://%s:%d", var.server_config.name, var.server_config.port)
  deployment_size = (
    var.instance_count > 10 ? "grande" :
    var.instance_count > 5 ? "mediano" :
    "pequeno"
  )
}

# --- Archivo de resumen generado por Terraform ---
resource "local_file" "summary" {
  filename = "resumen.txt"
  content  = <<-EOT
    Resumen de tipos de datos HCL
    ==============================

    Primitivos:
      app_name         = ${var.app_name}
      instance_count   = ${var.instance_count}
      enable_monitoring = ${var.enable_monitoring}

    Colecciones:
      availability_zones = ${join(", ", var.availability_zones)}
      tags[Environment]  = ${var.tags["Environment"]}

    Objeto:
      server_url = ${local.server_url}

    Locals calculados:
      full_app_name   = ${local.full_app_name}
      instance_type   = ${local.instance_type}
      app_name_upper  = ${local.app_name_upper}
      az_count        = ${local.az_count}
      first_az        = ${local.first_az}
      deployment_size = ${local.deployment_size}
  EOT
}

# --- Outputs ---
output "primitivos" {
  value = {
    app_name          = var.app_name
    instance_count    = var.instance_count
    enable_monitoring = var.enable_monitoring
  }
}

output "colecciones" {
  value = {
    availability_zones = var.availability_zones
    tags               = var.tags
    server_config      = var.server_config
  }
}

output "locals_calculados" {
  value = {
    full_app_name   = local.full_app_name
    instance_type   = local.instance_type
    app_name_upper  = local.app_name_upper
    az_count        = local.az_count
    first_az        = local.first_az
    server_url      = local.server_url
    deployment_size = local.deployment_size
  }
}

output "condicional" {
  value = {
    monitoreo = var.enable_monitoring ? "Monitoreo habilitado" : "Monitoreo deshabilitado"
    az_string = join(", ", var.availability_zones)
  }
}
EOF
```

Define variables de todos los tipos de Terraform: `string`, `number`, `bool`, `list(string)`, `map(string)` y `object`. Los `locals` demuestran funciones built-in como `upper`, `lower`, `length`, `format` y `join`, junto con condicionales ternarios simples y anidados.

### Paso 3: Inicializar Terraform

```bash
terraform init
```

Descarga el provider `hashicorp/local` necesario para crear el archivo de resumen. Sin este paso no es posible ejecutar plan ni apply.

### Paso 4: Ver el plan

```bash
terraform plan
```

Muestra los valores calculados de cada local y los outputs antes de crear nada. Es la mejor forma de verificar que la logica de los condicionales y funciones es correcta.

### Paso 5: Aplicar la configuracion

```bash
terraform apply -auto-approve
```

Crea el archivo `resumen.txt` y registra todos los recursos en el state. Los outputs se imprimen al final, mostrando el resultado de todas las expresiones HCL.

### Paso 6: Inspeccionar los outputs

```bash
terraform output
```

Lista todos los outputs con sus valores calculados. Esto confirma que cada tipo de dato fue procesado correctamente por Terraform.

```bash
terraform output locals_calculados
```

Muestra unicamente el output con los valores derivados de `locals`, lo que permite verificar los resultados de las funciones y el condicional ternario anidado.

### Paso 7: Usar Terraform Console

```bash
terraform console
```

Abre la consola interactiva de Terraform donde puedes evaluar expresiones HCL en tiempo real usando el estado actual. Prueba dentro de la consola las expresiones del siguiente bloque y luego escribe `exit`.

```bash
var.app_name
upper(var.app_name)
length(var.availability_zones)
var.tags["Environment"]
format("Server: %s:%d", var.server_config.name, var.server_config.port)
join(" | ", var.availability_zones)
exit
```

La consola evalua cada expresion contra el state actual, lo que permite experimentar con funciones sin modificar archivos ni ejecutar apply.

### Paso 8: Probar con variables diferentes

```bash
terraform apply -auto-approve -var="instance_count=15"
```

Aplica con un valor de `instance_count` mayor a 10, lo que debe cambiar `deployment_size` de `pequeno` a `grande`. Revisa el output `locals_calculados` para confirmar el cambio.

```bash
terraform output locals_calculados
```

Confirma que `deployment_size` ahora muestra `grande` gracias al condicional ternario anidado con el nuevo valor de `instance_count`.

### Paso 9: Volver al directorio del lab y validar

```bash
cd /root/lab
```

Regresa al directorio raiz del lab donde se encuentra el script de validacion.

```bash
bash validate-lab.sh
```

Ejecuta todas las verificaciones automaticas para confirmar que el lab fue completado correctamente.

## Conceptos

| Concepto | Descripcion |
|---|---|
| `string` | Cadena de texto: `"PeruApp"` |
| `number` | Entero o decimal: `3`, `3.14` |
| `bool` | Booleano: `true`, `false` |
| `list(type)` | Lista ordenada con elementos del mismo tipo |
| `map(type)` | Mapa clave-valor con valores del mismo tipo |
| `object({...})` | Estructura con atributos tipados individualmente |
| `locals` | Bloque para valores calculados reutilizables dentro del modulo |
| Ternario | `condition ? valor_si_true : valor_si_false` |
| `upper` / `lower` | Funciones de transformacion de strings |
| `length` | Cuenta elementos en una lista, mapa o string |
| `join` | Une elementos de una lista con un separador |
| `format` | Formatea un string al estilo printf |
| `terraform console` | Consola interactiva para evaluar expresiones HCL |

---

**Anterior:** [Modulo 1](../../01-iac-fundamentals/)
**Siguiente:** [Lab 2 - Providers](../lab2-providers/)

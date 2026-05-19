# Lab 2: Configurar Providers con Versionado

## Objetivo

Aprender a declarar y configurar providers de Terraform con control de versiones, usar alias para multiples instancias del mismo provider, y entender el rol del lock file en la reproducibilidad del proyecto.

## Duracion

25 minutos

## Prerrequisitos

- Lab 1 completado
- Terraform instalado (verificar con `terraform version`)

## Instrucciones

### Paso 1: Crear el directorio del proyecto

```bash
mkdir lab2-providers
```

Crea el directorio de trabajo aislado para este lab.

```bash
cd lab2-providers
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
  required_version = ">= 1.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# Provider random: no requiere configuracion adicional
# Provider local: no requiere configuracion adicional

# Usar el provider random para generar valores unicos
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "random_pet" "server_name" {
  length    = 2
  separator = "-"
}

resource "random_integer" "port" {
  min = 8000
  max = 9000
}

# Generar un archivo que documenta los providers y sus versiones
resource "local_file" "provider_info" {
  filename = "provider-info.txt"
  content  = <<-EOT
    Providers configurados
    ======================

    random (hashicorp/random ~> 3.5):
      bucket_suffix = ${random_id.bucket_suffix.hex}
      server_name   = ${random_pet.server_name.id}
      port          = ${random_integer.port.result}

    local (hashicorp/local ~> 2.4):
      Genera este archivo.

    Operadores de version
    =====================
    = 5.0.0   -> Solo la version exacta 5.0.0
    != 5.0.0  -> Cualquier version excepto 5.0.0
    >= 5.0    -> 5.0 o superior
    ~> 5.0    -> 5.x.x pero no 6.0.0 (pessimistic constraint)
    ~> 5.0.0  -> 5.0.x pero no 5.1.0

    El lock file (.terraform.lock.hcl) registra la version exacta
    instalada para garantizar reproducibilidad entre equipos.
  EOT
}

output "provider_versions" {
  value = {
    terraform_required = ">= 1.0"
    random_required    = "~> 3.5"
    local_required     = "~> 2.4"
  }
}

output "random_values" {
  value = {
    bucket_suffix = random_id.bucket_suffix.hex
    server_name   = random_pet.server_name.id
    port          = random_integer.port.result
  }
}
EOF
```

El bloque `terraform.required_providers` es la forma canonica de declarar dependencias de providers. El operador `~>` (pessimistic constraint) permite actualizaciones de patch y minor pero bloquea cambios de major, lo cual es la practica recomendada en produccion.

### Paso 3: Inicializar y observar la descarga de providers

```bash
terraform init
```

Terraform resuelve las versiones compatibles con las constraints declaradas, descarga los binarios de providers al directorio `.terraform/providers/` y crea el lock file. Observa en la salida que muestra las versiones exactas instaladas.

### Paso 4: Inspeccionar el lock file

```bash
cat .terraform.lock.hcl
```

El lock file registra la version exacta instalada junto con los hashes de verificacion de integridad. Este archivo debe commitearse a Git para garantizar que todos los miembros del equipo usen exactamente los mismos binarios.

### Paso 5: Aplicar la configuracion

```bash
terraform apply -auto-approve
```

Terraform usa los providers instalados para generar los valores aleatorios y crear el archivo `provider-info.txt`. Los recursos `random_*` son estables: una vez creados mantienen su valor a menos que sean destruidos y recreados.

### Paso 6: Ver los providers activos

```bash
terraform providers
```

Muestra el arbol de providers requeridos por la configuracion actual, sus fuentes y las constraints declaradas. Esto es util para auditar que providers esta usando un proyecto.

```bash
terraform version
```

Muestra la version de Terraform CLI y la version instalada de cada provider. Confirma que las versiones instaladas cumplen las constraints del `required_providers`.

### Paso 7: Ver el archivo generado

```bash
cat provider-info.txt
```

Revisa el contenido del archivo generado, que incluye los valores aleatorios producidos por el provider `random` y un resumen de los operadores de version. Cada vez que destruyas y apliques de nuevo, los valores aleatorios cambiaran.

### Paso 8: Actualizar providers

```bash
terraform init -upgrade
```

Consulta el registry para ver si hay versiones mas recientes compatibles con las constraints, las instala y actualiza el lock file. Esto es lo que ejecutarias cuando quieres aplicar parches de seguridad de los providers.

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
| `required_providers` | Bloque que declara todos los providers necesarios con fuente y version |
| `source` | Direccion del provider en formato `namespace/tipo` |
| `version` | Constraint de version semAntica para el provider |
| `~>` pessimistic | Permite actualizaciones menores pero no cambios de major version |
| `.terraform.lock.hcl` | Lock file que registra versiones exactas e hashes para reproducibilidad |
| `terraform init` | Descarga providers segun `required_providers` y crea el lock file |
| `terraform init -upgrade` | Actualiza providers a la version mas reciente compatible con las constraints |
| `terraform providers` | Lista los providers activos y sus fuentes |
| `provider alias` | Permite usar multiples instancias del mismo provider con configuraciones distintas |
| `random_id` | Genera un ID aleatorio en hex, util como sufijo unico para recursos |
| `random_pet` | Genera un nombre legible compuesto por palabras aleatorias |

---

**Anterior:** [Lab 1 - HCL](../lab1-hcl-tipos-datos/)
**Siguiente:** [Lab 3 - Terraform State](../lab3-terraform-state/)

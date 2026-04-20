# Lab 2: Configurar Providers con Versionado

![Terraform](https://img.shields.io/badge/Terraform-Providers-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Aprender a configurar providers correctamente con control de versiones y usar múltiples instancias del mismo provider.

## ⏱️ Duración
25 minutos

## 📋 Prerrequisitos
- ✅ Lab 1 completado
- Terraform instalado

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear el Directorio del Proyecto

```bash
mkdir lab2-providers
cd lab2-providers
```

### Paso 2: Crear el Archivo main.tf

```hcl
# main.tf - Configuración de providers

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    # Provider oficial de AWS
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Cualquier 5.x
    }
    
    # Provider random (útil para testing)
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    
    # Provider local (para archivos locales)
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# Configurar provider de AWS para región principal
provider "aws" {
  region = "us-east-1"
  
  # Simular configuración (no se conectará realmente)
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = "lab"
      Country     = "Peru"
    }
  }
}

# Configurar provider de AWS para región secundaria (São Paulo)
provider "aws" {
  alias  = "saopaulo"
  region = "sa-east-1"
  
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = "lab"
      Country     = "Brazil"
      Region      = "SaoPaulo"
    }
  }
}

# Usar provider random para generar IDs únicos
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "random_pet" "server_name" {
  length    = 2
  separator = "-"
}

# Crear archivo local con información de providers
resource "local_file" "provider_info" {
  filename = "provider-info.txt"
  content  = <<-EOT
    Providers Configurados
    =====================
    
    AWS Provider (Principal):
    - Región: us-east-1 (Virginia)
    - Versión: ~> 5.0
    - Default Tags: ManagedBy, Environment, Country
    
    AWS Provider (Secundario):
    - Región: sa-east-1 (São Paulo)
    - Alias: saopaulo
    - Versión: ~> 5.0
    - Default Tags: ManagedBy, Environment, Country, Region
    
    Random Provider:
    - Versión: ~> 3.5
    - Bucket Suffix: ${random_id.bucket_suffix.hex}
    - Server Name: ${random_pet.server_name.id}
    
    Local Provider:
    - Versión: ~> 2.4
    
    Generado: ${timestamp()}
    
    ---
    
    Uso de Providers con Alias:
    
    # Provider por defecto (us-east-1)
    resource "aws_instance" "web" {
      # usa provider aws por defecto
    }
    
    # Provider con alias (sa-east-1)
    resource "aws_instance" "web_sa" {
      provider = aws.saopaulo
      # usa provider aws.saopaulo
    }
  EOT
}

# Crear archivo con información de versionado
resource "local_file" "version_info" {
  filename = "version-constraints.md"
  content  = <<-EOT
    # Versionado de Providers en Terraform
    
    ## Operadores de Versión
    
    | Operador | Descripción | Ejemplo | Permite |
    |----------|-------------|---------|---------|
    | `=` | Versión exacta | `= 5.0.0` | Solo 5.0.0 |
    | `!=` | Excluir versión | `!= 5.0.0` | Cualquiera excepto 5.0.0 |
    | `>` | Mayor que | `> 5.0.0` | 5.0.1, 5.1.0, 6.0.0, etc. |
    | `>=` | Mayor o igual | `>= 5.0.0` | 5.0.0, 5.0.1, 5.1.0, etc. |
    | `<` | Menor que | `< 5.0.0` | 4.9.9, 4.0.0, etc. |
    | `<=` | Menor o igual | `<= 5.0.0` | 5.0.0, 4.9.9, etc. |
    | `~>` | Pessimistic | `~> 5.0` | 5.0.x, 5.1.x, pero no 6.0.0 |
    
    ## Ejemplos Prácticos
    
    ### Pessimistic Constraint (~>)
    
    ```hcl
    version = "~> 5.0"    # Permite 5.0.x, 5.1.x, 5.99.x, pero NO 6.0.0
    version = "~> 5.0.0"  # Permite 5.0.x, pero NO 5.1.0
    version = "~> 5"      # Permite 5.x.x, pero NO 6.0.0
    ```
    
    ### Múltiples Constraints
    
    ```hcl
    version = ">= 5.0, < 6.0"  # Entre 5.0 y 6.0 (no incluye 6.0)
    version = ">= 5.0, != 5.5.0"  # 5.0+ excepto 5.5.0
    ```
    
    ## Mejores Prácticas
    
    ✅ **Recomendado:**
    ```hcl
    version = "~> 5.0"  # Permite parches y minor, no major
    ```
    
    ❌ **No recomendado:**
    ```hcl
    version = ">= 5.0"  # Permite cualquier versión mayor (riesgoso)
    # Sin version      # Usa la última (puede romper)
    ```
    
    ## Lock File (.terraform.lock.hcl)
    
    El lock file asegura que todos usen las mismas versiones:
    
    - Se genera automáticamente con \`terraform init\`
    - Debe commitearse a Git
    - Bloquea versiones exactas de providers
    - Se actualiza con \`terraform init -upgrade\`
    
    Generado: ${timestamp()}
  EOT
}

# Outputs
output "provider_versions" {
  value = {
    terraform_version = "Terraform ${terraform.version}"
    random_suffix     = random_id.bucket_suffix.hex
    server_name       = random_pet.server_name.id
    info_file         = local_file.provider_info.filename
    version_guide     = local_file.version_info.filename
  }
}

output "aws_regions" {
  value = {
    primary   = "us-east-1 (Virginia)"
    secondary = "sa-east-1 (São Paulo)"
    note      = "Usa 'provider = aws.saopaulo' para recursos en São Paulo"
  }
}

output "next_steps" {
  value = <<-EOT
    
    ✅ Providers configurados exitosamente!
    
    Archivos generados:
    1. cat provider-info.txt
    2. cat version-constraints.md
    
    Comandos útiles:
    - terraform providers: Ver providers instalados
    - terraform version: Ver versión de Terraform
    - cat .terraform.lock.hcl: Ver versiones bloqueadas
    - terraform init -upgrade: Actualizar providers
  EOT
}
```

### Paso 3: Inicializar y Observar

```bash
# Inicializar Terraform
terraform init

# Observa la salida:
# Initializing provider plugins...
# - Finding hashicorp/aws versions matching "~> 5.0"...
# - Finding hashicorp/random versions matching "~> 3.5"...
# - Finding hashicorp/local versions matching "~> 2.4"...
# - Installing hashicorp/aws v5.31.0...
# - Installing hashicorp/random v3.5.1...
# - Installing hashicorp/local v2.4.1...
```

### Paso 4: Inspeccionar el Lock File

```bash
# Ver el archivo de lock
cat .terraform.lock.hcl

# Verás algo como:
# provider "registry.terraform.io/hashicorp/aws" {
#   version     = "5.31.0"
#   constraints = "~> 5.0"
#   hashes = [
#     "h1:...",
#     "zh:...",
#   ]
# }
```

### Paso 5: Aplicar la Configuración

```bash
# Aplicar
terraform apply

# Ver archivos generados
cat provider-info.txt
cat version-constraints.md
```

### Paso 6: Ver Información de Providers

```bash
# Listar providers instalados
terraform providers

# Ver versión de Terraform y providers
terraform version

# Ver schema de providers (JSON)
terraform providers schema -json | jq '.provider_schemas | keys'
```

### Paso 7: Experimentar con Versiones

#### Experimento 1: Actualizar Providers

```bash
# Ver versiones actuales
terraform version

# Actualizar a las últimas versiones compatibles
terraform init -upgrade

# Ver qué cambió
git diff .terraform.lock.hcl
```

#### Experimento 2: Cambiar Constraints

Modifica `main.tf`:

```hcl
required_providers {
  random = {
    source  = "hashicorp/random"
    version = "~> 3.6"  # Cambiar a 3.6
  }
}
```

Luego:
```bash
terraform init -upgrade
```

### Paso 8: Ejecutar Validación

```bash
cd ..
./validate-lab.sh
```

## 📚 Conceptos Clave

### Provider Source

```hcl
source = "hashicorp/aws"
# Formato: [hostname/]namespace/type
# hostname: registry.terraform.io (por defecto)
# namespace: hashicorp (organización)
# type: aws (nombre del provider)
```

### Versionado Semántico

```
MAJOR.MINOR.PATCH
  5  .  31 .  0

MAJOR: Cambios incompatibles
MINOR: Nueva funcionalidad compatible
PATCH: Bug fixes compatibles
```

### Provider Alias

Usa alias para múltiples instancias del mismo provider:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

# Usar el provider con alias
resource "aws_instance" "west" {
  provider = aws.west
  # ...
}
```

### Default Tags

Tags que se aplican automáticamente a todos los recursos:

```hcl
provider "aws" {
  default_tags {
    tags = {
      Environment = "production"
      ManagedBy   = "Terraform"
    }
  }
}
```

## 🔧 Comandos Útiles

```bash
# Inicializar providers
terraform init

# Actualizar providers
terraform init -upgrade

# Ver providers instalados
terraform providers

# Ver versiones
terraform version

# Ver lock file
cat .terraform.lock.hcl

# Limpiar y reinicializar
rm -rf .terraform .terraform.lock.hcl
terraform init
```

## ✅ Criterios de Validación

1. ✅ Proyecto `lab2-providers` creado
2. ✅ Múltiples providers configurados
3. ✅ Versionado con `~>` especificado
4. ✅ Provider con alias configurado
5. ✅ Lock file generado
6. ✅ Archivos informativos creados

## 🎓 Conceptos Aprendidos

- ✅ Configuración de providers
- ✅ Versionado semántico
- ✅ Operadores de versión (~>, >=, etc.)
- ✅ Provider alias para múltiples regiones
- ✅ Default tags
- ✅ Lock file (.terraform.lock.hcl)
- ✅ Actualización de providers

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Provider Expert Badge**

---

**Anterior:** [Lab 1 - HCL](../lab1-hcl-tipos-datos/)  
**Siguiente:** [Lab 3 - Terraform State](../lab3-terraform-state/)

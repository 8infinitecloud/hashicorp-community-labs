# Lab 2: Data Sources

![Terraform](https://img.shields.io/badge/Terraform-DataSources-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Aprender a consultar infraestructura existente usando data sources para obtener información dinámica.

## ⏱️ Duración
30 minutos

## 📋 Prerrequisitos
- ✅ Lab 1 completado
- Terraform instalado
- AWS CLI configurado (opcional para ejemplos AWS)
- Editor de texto

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear el Directorio del Proyecto

```bash
mkdir lab2-data-sources
cd lab2-data-sources
```

### Paso 2: Data Sources Locales

Primero crearemos archivos locales para luego consultarlos con data sources.

Crea `local-data-sources.tf`:

```hcl
# local-data-sources.tf - Data sources con archivos locales

terraform {
  required_version = ">= 1.0"
}

# Crear un archivo de configuración
resource "local_file" "config" {
  filename = "${path.module}/app-config.json"
  content  = jsonencode({
    app_name    = "MyApp"
    version     = "1.0.0"
    environment = "production"
    port        = 8080
  })
}

# Data source para leer el archivo
data "local_file" "read_config" {
  filename = local_file.config.filename
  
  # Depende del recurso
  depends_on = [local_file.config]
}

# Decodificar el JSON
locals {
  config_data = jsondecode(data.local_file.read_config.content)
}

# Usar la configuración leída
resource "local_file" "app_info" {
  filename = "${path.module}/app-info.txt"
  content  = <<-EOT
    Application: ${local.config_data.app_name}
    Version: ${local.config_data.version}
    Environment: ${local.config_data.environment}
    Port: ${local.config_data.port}
  EOT
}

# Outputs
output "config_content" {
  value = local.config_data
}
```

Ejecuta:

```bash
# Inicializar
terraform init

# Aplicar
terraform apply -auto-approve

# Ver el output
terraform output config_content

# Ver los archivos creados
cat app-config.json
cat app-info.txt
```

### Paso 3: Data Sources con HTTP

Crea `http-data-sources.tf`:

```hcl
# http-data-sources.tf - Consultar APIs externas

terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

# Obtener IP pública
data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}

# Obtener información de GitHub
data "http" "github_terraform" {
  url = "https://api.github.com/repos/hashicorp/terraform"
  
  request_headers = {
    Accept = "application/vnd.github.v3+json"
  }
}

# Parsear respuesta de GitHub
locals {
  github_data = jsondecode(data.http.github_terraform.response_body)
}

# Crear archivo con la información
resource "local_file" "external_data" {
  filename = "${path.module}/external-data.txt"
  content  = <<-EOT
    My Public IP: ${trimspace(data.http.my_ip.response_body)}
    
    Terraform Repository:
    - Name: ${local.github_data.name}
    - Stars: ${local.github_data.stargazers_count}
    - Forks: ${local.github_data.forks_count}
    - Language: ${local.github_data.language}
    - Description: ${local.github_data.description}
  EOT
}

# Outputs
output "my_public_ip" {
  value = trimspace(data.http.my_ip.response_body)
}

output "terraform_stars" {
  value = local.github_data.stargazers_count
}
```

Ejecuta:

```bash
# Aplicar
terraform apply -auto-approve

# Ver outputs
terraform output my_public_ip
terraform output terraform_stars

# Ver el archivo generado
cat external-data.txt
```

### Paso 4: Data Sources con AWS (Opcional)

Si tienes AWS configurado, crea `aws-data-sources.tf`:

```hcl
# aws-data-sources.tf - Consultar recursos AWS

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Obtener información de la cuenta AWS
data "aws_caller_identity" "current" {}

# Obtener zonas de disponibilidad
data "aws_availability_zones" "available" {
  state = "available"
}

# Obtener AMI más reciente de Ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Obtener VPC por defecto
data "aws_vpc" "default" {
  default = true
}

# Obtener subnets de la VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Obtener región actual
data "aws_region" "current" {}

# Crear archivo con información AWS
resource "local_file" "aws_info" {
  filename = "${path.module}/aws-info.txt"
  content  = <<-EOT
    AWS Account Information:
    - Account ID: ${data.aws_caller_identity.current.account_id}
    - User ID: ${data.aws_caller_identity.current.user_id}
    - ARN: ${data.aws_caller_identity.current.arn}
    
    Region: ${data.aws_region.current.name}
    
    Availability Zones:
    ${join("\n    ", data.aws_availability_zones.available.names)}
    
    Ubuntu AMI:
    - ID: ${data.aws_ami.ubuntu.id}
    - Name: ${data.aws_ami.ubuntu.name}
    - Creation Date: ${data.aws_ami.ubuntu.creation_date}
    
    Default VPC:
    - ID: ${data.aws_vpc.default.id}
    - CIDR: ${data.aws_vpc.default.cidr_block}
    - Subnets: ${length(data.aws_subnets.default.ids)}
  EOT
}

# Outputs
output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "ubuntu_ami_id" {
  value = data.aws_ami.ubuntu.id
}

output "availability_zones" {
  value = data.aws_availability_zones.available.names
}
```

Ejecuta:

```bash
# Aplicar
terraform apply -auto-approve

# Ver outputs
terraform output aws_account_id
terraform output ubuntu_ami_id
terraform output availability_zones

# Ver el archivo
cat aws-info.txt
```

### Paso 5: Usar Data Sources en Resources

Crea `data-in-resources.tf`:

```hcl
# data-in-resources.tf - Usar data sources en recursos

# Crear archivo base
resource "local_file" "base" {
  filename = "${path.module}/base.txt"
  content  = "Base Configuration"
}

# Leer el archivo base
data "local_file" "base_read" {
  filename   = local_file.base.filename
  depends_on = [local_file.base]
}

# Crear archivo derivado usando data source
resource "local_file" "derived" {
  filename = "${path.module}/derived.txt"
  content  = <<-EOT
    Derived from: ${data.local_file.base_read.filename}
    Original content: ${data.local_file.base_read.content}
    Content length: ${length(data.local_file.base_read.content)}
    Timestamp: ${timestamp()}
  EOT
}

# Crear múltiples archivos basados en data
resource "local_file" "copies" {
  count = 3
  
  filename = "${path.module}/copy-${count.index}.txt"
  content  = "Copy ${count.index} of: ${data.local_file.base_read.content}"
}
```

Ejecuta:

```bash
# Aplicar
terraform apply -auto-approve

# Ver archivos creados
ls -la *.txt

# Ver contenido
cat derived.txt
cat copy-0.txt
```

### Paso 6: Data Sources con Filtros

Crea `data-filters.tf`:

```hcl
# data-filters.tf - Filtros en data sources

# Crear varios archivos de prueba
resource "local_file" "test_files" {
  for_each = {
    dev     = "Development Environment"
    staging = "Staging Environment"
    prod    = "Production Environment"
  }
  
  filename = "${path.module}/${each.key}-config.txt"
  content  = each.value
}

# Leer archivo específico
data "local_file" "prod_config" {
  filename   = "${path.module}/prod-config.txt"
  depends_on = [local_file.test_files]
}

# Crear resumen
resource "local_file" "summary" {
  filename = "${path.module}/summary.txt"
  content  = <<-EOT
    Production Configuration:
    ${data.local_file.prod_config.content}
    
    File: ${data.local_file.prod_config.filename}
    ID: ${data.local_file.prod_config.id}
  EOT
}
```

Ejecuta:

```bash
# Aplicar
terraform apply -auto-approve

# Ver archivos
ls -la *-config.txt
cat summary.txt
```

### Paso 7: Data Sources Dinámicos

Crea `dynamic-data.tf`:

```hcl
# dynamic-data.tf - Data sources dinámicos

# Variable para el entorno
variable "environment" {
  type    = string
  default = "dev"
}

# Crear configuraciones por entorno
resource "local_file" "env_configs" {
  for_each = {
    dev = {
      replicas = 1
      memory   = "512Mi"
    }
    staging = {
      replicas = 2
      memory   = "1Gi"
    }
    prod = {
      replicas = 5
      memory   = "2Gi"
    }
  }
  
  filename = "${path.module}/env-${each.key}.json"
  content = jsonencode({
    environment = each.key
    replicas    = each.value.replicas
    memory      = each.value.memory
  })
}

# Leer configuración del entorno actual
data "local_file" "current_env" {
  filename   = "${path.module}/env-${var.environment}.json"
  depends_on = [local_file.env_configs]
}

# Parsear y usar
locals {
  env_config = jsondecode(data.local_file.current_env.content)
}

# Crear deployment basado en el entorno
resource "local_file" "deployment" {
  filename = "${path.module}/deployment.yaml"
  content  = <<-EOT
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: myapp
    spec:
      replicas: ${local.env_config.replicas}
      template:
        spec:
          containers:
          - name: app
            image: myapp:latest
            resources:
              limits:
                memory: ${local.env_config.memory}
  EOT
}

# Output
output "deployment_config" {
  value = local.env_config
}
```

Ejecuta:

```bash
# Aplicar con dev (default)
terraform apply -auto-approve

# Ver deployment
cat deployment.yaml

# Cambiar a producción
terraform apply -var="environment=prod" -auto-approve

# Ver cambios en deployment
cat deployment.yaml
```

### Paso 8: Terraform Console para Testing

```bash
# Abrir consola interactiva
terraform console

# Probar data sources
> data.local_file.current_env.content
> jsondecode(data.local_file.current_env.content)
> local.env_config.replicas

# Probar funciones
> length(data.local_file.current_env.content)
> upper(local.env_config.environment)

# Salir
> exit
```

### Paso 9: Inspeccionar Data Sources

```bash
# Listar todos los recursos y data sources
terraform state list

# Ver detalles de un data source
terraform state show data.local_file.current_env

# Ver todos los outputs
terraform output

# Ver output específico
terraform output deployment_config
```

### Paso 10: Limpiar

```bash
# Destruir todos los recursos
terraform destroy -auto-approve

# Verificar
terraform state list
# (debe estar vacío)

# Limpiar archivos
rm -f *.txt *.json *.yaml
```

### Paso 11: Ejecutar Validación

```bash
cd ..
./validate-lab.sh
```

## 📚 Data Sources Explicados

### Sintaxis Básica

```hcl
data "provider_type" "name" {
  # Argumentos de búsqueda
  filter {
    name   = "key"
    values = ["value"]
  }
}

# Usar en recursos
resource "..." "..." {
  attribute = data.provider_type.name.attribute
}
```

### Data Sources Comunes

#### AWS

```hcl
# AMI más reciente
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/*"]
  }
}

# VPC por defecto
data "aws_vpc" "default" {
  default = true
}

# Zonas de disponibilidad
data "aws_availability_zones" "available" {
  state = "available"
}

# Información de la cuenta
data "aws_caller_identity" "current" {}
```

#### Local

```hcl
# Leer archivo
data "local_file" "config" {
  filename = "${path.module}/config.json"
}
```

#### HTTP

```hcl
# Consultar API
data "http" "example" {
  url = "https://api.example.com/data"
  
  request_headers = {
    Accept = "application/json"
  }
}
```

## 💡 Mejores Prácticas

1. **Usa data sources para datos dinámicos**
   ```hcl
   # ✅ BIEN - AMI dinámica
   data "aws_ami" "ubuntu" {
     most_recent = true
   }
   
   # ❌ MAL - AMI hardcodeada
   ami = "ami-12345"
   ```

2. **Filtra apropiadamente**
   ```hcl
   # ✅ BIEN - Filtros específicos
   data "aws_ami" "ubuntu" {
     most_recent = true
     owners      = ["099720109477"]
     
     filter {
       name   = "name"
       values = ["ubuntu/images/hvm-ssd/*"]
     }
   }
   ```

3. **Maneja errores**
   ```hcl
   # Usa count para data sources opcionales
   data "aws_vpc" "selected" {
     count = var.vpc_id != "" ? 1 : 0
     id    = var.vpc_id
   }
   ```

4. **Documenta data sources**
   ```hcl
   # Obtener la AMI más reciente de Ubuntu 22.04
   # Usado para todas las instancias EC2
   data "aws_ami" "ubuntu" {
     # ...
   }
   ```

## 🔧 Troubleshooting

### Error: "No matching resource found"

```bash
# El data source no encontró resultados
# Verifica los filtros y que el recurso existe

# Ejemplo: Verificar AMIs disponibles
aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu*"
```

### Error: "Multiple matches found"

```bash
# El data source encontró múltiples resultados
# Agrega most_recent = true o filtros más específicos

data "aws_ami" "ubuntu" {
  most_recent = true  # Toma la más reciente
  # ...
}
```

### Data source no se actualiza

```bash
# Forzar refresh
terraform refresh

# O aplicar de nuevo
terraform apply -refresh-only
```

## ✅ Criterios de Validación

1. ✅ Proyecto `lab2-data-sources` creado
2. ✅ Data sources locales implementados
3. ✅ Data sources HTTP implementados
4. ✅ Data sources usados en resources
5. ✅ Filtros aplicados correctamente
6. ✅ Terraform console usado
7. ✅ Recursos limpiados

## 🎓 Conceptos Aprendidos

- ✅ Qué son los data sources
- ✅ Data sources locales
- ✅ Data sources HTTP
- ✅ Data sources AWS (opcional)
- ✅ Filtros en data sources
- ✅ Usar data sources en resources
- ✅ Data sources dinámicos
- ✅ Terraform console

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Data Sources Expert Badge**

---

**Anterior:** [Lab 1 - Resources Lifecycle](../lab1-resources-lifecycle/)  
**Siguiente:** [Lab 3 - Variables con Validación](../lab3-variables-validacion/)

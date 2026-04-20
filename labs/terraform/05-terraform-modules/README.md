# Módulo 5: Terraform Modules

![Terraform](https://img.shields.io/badge/Terraform-Modules-7B42BC?style=for-the-badge&logo=terraform)

## 📚 Descripción del Módulo

Este módulo enseña a crear módulos reutilizables de Terraform para organizar y compartir código de infraestructura.

## ⏱️ Duración Total
Aproximadamente 2 horas (4 labs de 25-35 minutos cada uno)

## 🎯 Objetivos de Aprendizaje

Al completar este módulo serás capaz de:

- ✅ Crear módulos locales reutilizables
- ✅ Usar módulos del Terraform Registry
- ✅ Pasar variables entre módulos
- ✅ Usar outputs de módulos
- ✅ Versionar módulos
- ✅ Organizar proyectos con módulos
- ✅ Aplicar mejores prácticas de módulos

## 📋 Prerrequisitos

- ✅ Módulos 1-4 completados
- Terraform instalado (versión 1.0+)
- Editor de texto
- Git instalado

## 🧪 Laboratorios

### [Lab 1: Crear Tu Primer Módulo](./lab1-primer-modulo/)
**Duración:** 30 minutos  
**Objetivo:** Crear un módulo local simple y reutilizable

**Aprenderás:**
- Estructura de un módulo
- Variables de entrada
- Outputs del módulo
- Llamar módulos locales
- Pasar valores entre módulos
- Módulos anidados

**Badge:** 🏆 Terraform Module Creator

---

### [Lab 2: Módulos del Registry](./lab2-registry-modules/)
**Duración:** 30 minutos  
**Objetivo:** Usar módulos públicos del Terraform Registry

**Aprenderás:**
- Buscar módulos en el Registry
- Usar módulos públicos
- Versionar módulos
- Módulos de AWS, Azure, GCP
- Combinar múltiples módulos
- Actualizar versiones de módulos

**Badge:** 🏆 Terraform Registry Expert

---

### [Lab 3: Módulos Avanzados](./lab3-modulos-avanzados/)
**Duración:** 35 minutos  
**Objetivo:** Técnicas avanzadas con módulos

**Aprenderás:**
- Módulos con count y for_each
- Módulos condicionales
- Composición de módulos
- Módulos con data sources
- Módulos con providers
- Testing de módulos

**Badge:** 🏆 Terraform Advanced Modules

---

### [Lab 4: Organización de Proyectos](./lab4-organizacion-proyectos/)
**Duración:** 25 minutos  
**Objetivo:** Organizar proyectos grandes con módulos

**Aprenderás:**
- Estructura de directorios
- Separación por entornos
- Módulos compartidos
- Monorepo vs multirepo
- Documentación de módulos
- Mejores prácticas

**Badge:** 🏆 Terraform Project Architect

---

## 🎓 Conceptos Clave

### Estructura de un Módulo

```
my-module/
├── main.tf          # Recursos principales
├── variables.tf     # Variables de entrada
├── outputs.tf       # Outputs del módulo
├── README.md        # Documentación
└── versions.tf      # Versiones de providers
```

### Llamar un Módulo Local

```hcl
module "web_server" {
  source = "./modules/web-server"
  
  instance_type = "t2.micro"
  instance_name = "web-1"
}

# Usar output del módulo
output "server_ip" {
  value = module.web_server.public_ip
}
```

### Usar Módulo del Registry

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  
  name = "my-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
}
```

### Módulo con Count

```hcl
module "servers" {
  source = "./modules/server"
  count  = 3
  
  name = "server-${count.index}"
}
```

### Módulo con For_Each

```hcl
module "servers" {
  source   = "./modules/server"
  for_each = toset(["web", "api", "db"])
  
  name = each.key
  type = each.value
}
```

## 📊 Progreso del Módulo

Completa los 4 labs en orden:

1. ⬜ Lab 1: Crear Tu Primer Módulo
2. ⬜ Lab 2: Módulos del Registry
3. ⬜ Lab 3: Módulos Avanzados
4. ⬜ Lab 4: Organización de Proyectos

Al completar los 4 labs obtienes: **🎖️ Terraform Modules Complete**

## 💡 Mejores Prácticas

### 1. Estructura Clara

```
project/
├── modules/
│   ├── networking/
│   ├── compute/
│   └── database/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── main.tf
```

### 2. Variables con Validación

```hcl
# modules/server/variables.tf
variable "instance_type" {
  type = string
  
  validation {
    condition     = contains(["t2.micro", "t2.small"], var.instance_type)
    error_message = "Instance type must be t2.micro or t2.small."
  }
}
```

### 3. Outputs Descriptivos

```hcl
# modules/server/outputs.tf
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.this.public_ip
}
```

### 4. Documentación

```markdown
# Web Server Module

Creates an EC2 instance configured as a web server.

## Usage

```hcl
module "web" {
  source = "./modules/web-server"
  
  instance_type = "t2.micro"
  name          = "my-web-server"
}
```

## Inputs

| Name | Type | Description |
|------|------|-------------|
| instance_type | string | EC2 instance type |
| name | string | Name of the instance |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | ID of the instance |
| public_ip | Public IP address |
```

### 5. Versionado Semántico

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"  # Permite 5.x pero no 6.0
}
```

## 🔧 Comandos Útiles

### Inicializar Módulos

```bash
# Descargar módulos
terraform init

# Actualizar módulos
terraform init -upgrade

# Ver módulos instalados
terraform providers
```

### Trabajar con Módulos

```bash
# Ver grafo con módulos
terraform graph

# Aplicar solo un módulo
terraform apply -target=module.web_server

# Ver outputs de módulo
terraform output module.web_server
```

### Validar Módulos

```bash
# Validar configuración
terraform validate

# Formatear código
terraform fmt -recursive

# Ver plan
terraform plan
```

## 📚 Recursos Adicionales

### Documentación Oficial
- [Modules Overview](https://www.terraform.io/language/modules)
- [Module Sources](https://www.terraform.io/language/modules/sources)
- [Terraform Registry](https://registry.terraform.io/)
- [Publishing Modules](https://www.terraform.io/registry/modules/publish)

### Tutoriales
- [Build and Use a Local Module](https://learn.hashicorp.com/tutorials/terraform/module-create)
- [Use Registry Modules](https://learn.hashicorp.com/tutorials/terraform/module-use)
- [Refactor Monolithic Configuration](https://learn.hashicorp.com/tutorials/terraform/organize-configuration)

### Módulos Populares
- [AWS VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws)
- [AWS EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws)
- [Azure Network Module](https://registry.terraform.io/modules/Azure/network/azurerm)
- [GCP Network Module](https://registry.terraform.io/modules/terraform-google-modules/network/google)

## 🏆 Badges del Módulo

Al completar cada lab obtienes un badge:

- 🏆 **Terraform Module Creator** (Lab 1)
- 🏆 **Terraform Registry Expert** (Lab 2)
- 🏆 **Terraform Advanced Modules** (Lab 3)
- 🏆 **Terraform Project Architect** (Lab 4)

Al completar los 4 labs:
- 🎖️ **Terraform Modules Complete**

---

**¡Comienza con el Lab 1!** → [Crear Tu Primer Módulo](./lab1-primer-modulo/)

# Módulo 2: Terraform Fundamentals

![Terraform](https://img.shields.io/badge/Terraform-Fundamentals-7B42BC?style=for-the-badge&logo=terraform)

## 📚 Descripción del Módulo

Este módulo profundiza en los fundamentos de Terraform: sintaxis HCL, tipos de datos, providers, gestión de estado y comandos CLI avanzados.

## ⏱️ Duración Total
Aproximadamente 2 horas (4 labs de 25-30 minutos cada uno)

## 🎯 Objetivos de Aprendizaje

Al completar este módulo serás capaz de:

- ✅ Dominar la sintaxis HCL y tipos de datos
- ✅ Configurar y versionar providers correctamente
- ✅ Entender y gestionar el Terraform State
- ✅ Usar comandos CLI avanzados
- ✅ Aplicar funciones built-in de Terraform
- ✅ Trabajar con múltiples providers y alias
- ✅ Inspeccionar y manipular el estado

## 📋 Prerrequisitos

- ✅ Módulo 1 completado (IaC Fundamentals)
- Terraform instalado (versión 1.0+)
- Editor de texto
- Conocimientos básicos de HCL

## 🧪 Laboratorios

### [Lab 1: Explorar HCL y Tipos de Datos](./lab1-hcl-tipos-datos/)
**Duración:** 30 minutos  
**Objetivo:** Dominar la sintaxis HCL y tipos de datos

**Aprenderás:**
- Tipos primitivos: string, number, bool
- Colecciones: list, map, set
- Tipos estructurales: object, tuple
- Variables y validación
- Locals y cálculos
- Funciones built-in
- Terraform console

**Badge:** 🏆 Terraform HCL Master

---

### [Lab 2: Configurar Providers](./lab2-providers/)
**Duración:** 25 minutos  
**Objetivo:** Configurar providers con versionado correcto

**Aprenderás:**
- Bloque `required_providers`
- Versionado semántico de providers
- Múltiples instancias con alias
- Default tags
- Archivo `.terraform.lock.hcl`
- Autenticación de providers

**Badge:** 🏆 Terraform Provider Expert

---

### [Lab 3: Terraform State](./lab3-terraform-state/)
**Duración:** 30 minutos  
**Objetivo:** Entender y gestionar el estado de Terraform

**Aprenderás:**
- Estructura del archivo `terraform.tfstate`
- Comandos de inspección de state
- `terraform state list/show`
- Drift detection
- State refresh
- Mejores prácticas de state

**Badge:** 🏆 Terraform State Manager

---

### [Lab 4: CLI Avanzado](./lab4-cli-avanzado/)
**Duración:** 25 minutos  
**Objetivo:** Dominar comandos avanzados de Terraform CLI

**Aprenderás:**
- Flags útiles de comandos
- Workspaces para múltiples ambientes
- Debugging con TF_LOG
- Terraform console interactivo
- Terraform graph
- Variables de entorno
- Cheatsheet de comandos

**Badge:** 🏆 Terraform CLI Master

---

## 🎓 Conceptos Clave

### HCL (HashiCorp Configuration Language)

HCL es un lenguaje declarativo diseñado para ser legible por humanos y máquinas:

```hcl
# Sintaxis básica
resource "tipo" "nombre" {
  argumento = "valor"
  
  bloque_anidado {
    argumento = "valor"
  }
}
```

### Providers

Los providers son plugins que permiten a Terraform interactuar con APIs:

```hcl
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
```

### Terraform State

El state es la fuente de verdad de tu infraestructura:

- Mapea recursos reales a configuración
- Almacena metadata
- Mejora performance
- Permite colaboración

### Comandos Esenciales

| Comando | Descripción |
|---------|-------------|
| `terraform init` | Inicializa providers |
| `terraform validate` | Valida sintaxis |
| `terraform fmt` | Formatea código |
| `terraform plan` | Muestra cambios |
| `terraform apply` | Aplica cambios |
| `terraform destroy` | Destruye recursos |
| `terraform state list` | Lista recursos |
| `terraform output` | Muestra outputs |
| `terraform console` | Consola interactiva |

## 📊 Progreso del Módulo

Completa los 4 labs en orden:

1. ⬜ Lab 1: HCL y Tipos de Datos
2. ⬜ Lab 2: Configurar Providers
3. ⬜ Lab 3: Terraform State
4. ⬜ Lab 4: CLI Avanzado

Al completar los 4 labs obtienes: **🎖️ Terraform Fundamentals Complete**

## 🔧 Funciones Útiles de Terraform

### Strings
- `upper()`, `lower()`, `title()`
- `trim()`, `trimprefix()`, `trimsuffix()`
- `format()`, `join()`, `split()`

### Colecciones
- `length()`, `concat()`, `merge()`
- `keys()`, `values()`, `lookup()`
- `contains()`, `distinct()`, `flatten()`

### Numéricas
- `max()`, `min()`, `abs()`
- `ceil()`, `floor()`, `pow()`

### Fecha/Hora
- `timestamp()`, `formatdate()`

### Encoding
- `base64encode()`, `base64decode()`
- `jsonencode()`, `jsondecode()`

## 📚 Recursos Adicionales

### Documentación Oficial
- [HCL Language](https://www.terraform.io/language)
- [Providers Registry](https://registry.terraform.io/browse/providers)
- [State Documentation](https://www.terraform.io/language/state)
- [CLI Commands](https://www.terraform.io/cli/commands)
- [Built-in Functions](https://www.terraform.io/language/functions)

### Tutoriales
- [Provider Versioning](https://learn.hashicorp.com/tutorials/terraform/provider-versioning)
- [Manage Terraform State](https://learn.hashicorp.com/tutorials/terraform/state-cli)
- [Terraform CLI Collection](https://learn.hashicorp.com/collections/terraform/cli)

## 💡 Tips para el Éxito

1. **Usa terraform console:** Experimenta con funciones interactivamente
2. **Versiona providers:** Siempre especifica versiones con `~>`
3. **No edites el state:** Usa comandos `terraform state` para modificarlo
4. **Formatea tu código:** Ejecuta `terraform fmt` antes de commit
5. **Lee los errores:** Terraform da mensajes muy descriptivos

## 🚀 Próximos Pasos

Después de completar este módulo:

1. **Módulo 3:** Core Workflow
   - Workflow completo de Terraform
   - Colaboración en equipo
   - CI/CD con Terraform

2. **Módulo 4:** Terraform Configuration
   - Variables avanzadas
   - Outputs complejos
   - Data sources

3. **Módulo 5:** Terraform Modules
   - Crear módulos reutilizables
   - Module registry
   - Composición de módulos

## 🏆 Badges del Módulo

Al completar cada lab obtienes un badge:

- 🏆 **Terraform HCL Master** (Lab 1)
- 🏆 **Terraform Provider Expert** (Lab 2)
- 🏆 **Terraform State Manager** (Lab 3)
- 🏆 **Terraform CLI Master** (Lab 4)

Al completar los 4 labs:
- 🎖️ **Terraform Fundamentals Complete**

---

**¡Comienza con el Lab 1!** → [HCL y Tipos de Datos](./lab1-hcl-tipos-datos/)

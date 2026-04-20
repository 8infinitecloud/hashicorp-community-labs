# Módulo 3: Core Workflow

![Terraform](https://img.shields.io/badge/Terraform-Core%20Workflow-7B42BC?style=for-the-badge&logo=terraform)

## 📚 Descripción del Módulo

Este módulo cubre el workflow completo de Terraform: Write → Plan → Apply → Destroy. Aprenderás a trabajar con infraestructura real, aplicar cambios incrementales, proteger recursos críticos y mantener calidad de código.

## ⏱️ Duración Total
Aproximadamente 2.5 horas (4 labs de 25-45 minutos cada uno)

## 🎯 Objetivos de Aprendizaje

Al completar este módulo serás capaz de:

- ✅ Ejecutar el workflow completo de Terraform
- ✅ Crear y gestionar infraestructura real en AWS
- ✅ Aplicar cambios incrementales con targets
- ✅ Proteger recursos críticos contra destrucción
- ✅ Mantener calidad de código con fmt y validate
- ✅ Debuggear problemas con logs y console
- ✅ Integrar Terraform en CI/CD

## 📋 Prerrequisitos

- ✅ Módulos 1 y 2 completados
- Terraform instalado (versión 1.0+)
- Cuenta de AWS (Free Tier) - solo para Lab 1
- AWS CLI configurado - solo para Lab 1
- Editor de texto

## 🧪 Laboratorios

### [Lab 1: Workflow Completo con AWS](./lab1-workflow-completo/)
**Duración:** 45 minutos  
**Objetivo:** Ejecutar el workflow completo creando infraestructura real en AWS

**Aprenderás:**
- Write: Escribir configuración de infraestructura
- Init: Inicializar providers
- Plan: Ver cambios antes de aplicar
- Apply: Crear infraestructura real
- Modify: Modificar recursos existentes
- Destroy: Limpiar recursos

**Requisitos:** Cuenta AWS, AWS CLI configurado

**Badge:** 🏆 Terraform Workflow Master

---

### [Lab 2: Targets y Apply Incremental](./lab2-targets-incremental/)
**Duración:** 30 minutos  
**Objetivo:** Aplicar cambios incrementales usando targets

**Aprenderás:**
- Usar `-target` para recursos específicos
- Terraform respeta dependencias automáticamente
- Apply y destroy selectivo
- Útil para debugging y cambios controlados

**Badge:** 🏆 Terraform Targeting Expert

---

### [Lab 3: Destroy Selectivo y Protección](./lab3-destroy-proteccion/)
**Duración:** 25 minutos  
**Objetivo:** Proteger recursos críticos y destruir selectivamente

**Aprenderás:**
- Lifecycle: `prevent_destroy`
- Destroy selectivo con targets
- Proteger recursos de producción
- Plan de destrucción sin ejecutar

**Badge:** 🏆 Terraform Protection Master

---

### [Lab 4: Calidad de Código y Debugging](./lab4-calidad-debugging/)
**Duración:** 30 minutos  
**Objetivo:** Mantener calidad de código y debuggear problemas

**Aprenderás:**
- `terraform fmt` para formateo automático
- `terraform validate` para validación
- Niveles de logging (TRACE, DEBUG, INFO)
- Terraform console para testing
- Integración con CI/CD

**Badge:** 🏆 Terraform Quality Expert

---

## 🎓 Conceptos Clave

### El Workflow de Terraform

```
Write → Init → Plan → Apply → Destroy
  ↓       ↓       ↓       ↓        ↓
 .tf    .terraform  diff   infra   clean
```

### 1. Write (Escribir)

Escribir configuración en archivos `.tf`:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345"
  instance_type = "t2.micro"
}
```

### 2. Init (Inicializar)

```bash
terraform init
```

- Descarga providers
- Inicializa backend
- Prepara directorio de trabajo

### 3. Plan (Planear)

```bash
terraform plan
```

- Compara configuración vs state
- Muestra qué cambiará
- No modifica nada

### 4. Apply (Aplicar)

```bash
terraform apply
```

- Ejecuta los cambios
- Actualiza el state
- Crea/modifica/destruye recursos

### 5. Destroy (Destruir)

```bash
terraform destroy
```

- Elimina todos los recursos
- Limpia el state
- Libera recursos cloud

## 🔧 Comandos del Workflow

| Fase | Comando | Descripción |
|------|---------|-------------|
| Write | - | Editar archivos `.tf` |
| Init | `terraform init` | Inicializar |
| Validate | `terraform validate` | Validar sintaxis |
| Format | `terraform fmt` | Formatear código |
| Plan | `terraform plan` | Ver cambios |
| Apply | `terraform apply` | Aplicar cambios |
| Show | `terraform show` | Ver state |
| Output | `terraform output` | Ver outputs |
| Destroy | `terraform destroy` | Destruir todo |

## 📊 Progreso del Módulo

Completa los 4 labs en orden:

1. ⬜ Lab 1: Workflow Completo con AWS
2. ⬜ Lab 2: Targets y Apply Incremental
3. ⬜ Lab 3: Destroy Selectivo y Protección
4. ⬜ Lab 4: Calidad de Código y Debugging

Al completar los 4 labs obtienes: **🎖️ Core Workflow Complete**

## 💡 Mejores Prácticas

### 1. Siempre Planea Antes de Aplicar

```bash
# ✅ BIEN
terraform plan
terraform apply

# ❌ MAL
terraform apply -auto-approve  # Sin revisar cambios
```

### 2. Usa Archivos de Plan

```bash
# Guardar plan
terraform plan -out=tfplan

# Revisar plan
terraform show tfplan

# Aplicar plan exacto
terraform apply tfplan
```

### 3. Formatea y Valida

```bash
# Antes de commit
terraform fmt -recursive
terraform validate
```

### 4. Protege Recursos Críticos

```hcl
resource "aws_db_instance" "prod" {
  # ...
  
  lifecycle {
    prevent_destroy = true
  }
}
```

### 5. Usa Targets con Cuidado

```bash
# Solo para debugging o cambios controlados
terraform apply -target=aws_instance.web

# No uses targets en producción regularmente
```

## 🚀 Integración CI/CD

### GitHub Actions

```yaml
name: Terraform

on: [push]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      
      - name: Terraform Init
        run: terraform init
      
      - name: Terraform Format
        run: terraform fmt -check
      
      - name: Terraform Validate
        run: terraform validate
      
      - name: Terraform Plan
        run: terraform plan
```

### Script de Validación

```bash
#!/bin/bash

echo "🔍 Verificando formato..."
terraform fmt -check -recursive || exit 1

echo "🔍 Validando configuración..."
terraform validate || exit 1

echo "🔍 Generando plan..."
terraform plan -out=tfplan

echo "✅ Todas las verificaciones pasaron"
```

## 📚 Recursos Adicionales

### Documentación Oficial
- [Terraform CLI Commands](https://www.terraform.io/cli/commands)
- [Terraform Workflow](https://www.terraform.io/intro/core-workflow)
- [Lifecycle Meta-Arguments](https://www.terraform.io/language/meta-arguments/lifecycle)

### Tutoriales
- [Initialize Terraform Configuration](https://learn.hashicorp.com/tutorials/terraform/init)
- [Create a Terraform Plan](https://learn.hashicorp.com/tutorials/terraform/plan)
- [Apply Terraform Configuration](https://learn.hashicorp.com/tutorials/terraform/apply)

### Herramientas
- [TFLint](https://github.com/terraform-linters/tflint) - Linter
- [Checkov](https://github.com/bridgecrewio/checkov) - Security Scanner
- [terraform-docs](https://github.com/terraform-docs/terraform-docs) - Doc Generator

## 🏆 Badges del Módulo

Al completar cada lab obtienes un badge:

- 🏆 **Terraform Workflow Master** (Lab 1)
- 🏆 **Terraform Targeting Expert** (Lab 2)
- 🏆 **Terraform Protection Master** (Lab 3)
- 🏆 **Terraform Quality Expert** (Lab 4)

Al completar los 4 labs:
- 🎖️ **Core Workflow Complete**

---

**¡Comienza con el Lab 1!** → [Workflow Completo con AWS](./lab1-workflow-completo/)

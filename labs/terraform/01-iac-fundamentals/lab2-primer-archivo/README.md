# Lab 2: Tu Primer Archivo Terraform

![Terraform](https://img.shields.io/badge/Terraform-First%20File-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Crear tu primera configuración Terraform, ejecutar el workflow básico y ver outputs en acción.

## ⏱️ Duración
20 minutos

## 📋 Prerrequisitos
- ✅ Lab 1 completado (Terraform instalado)

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear el directorio del proyecto

```bash
mkdir mi-primer-terraform && cd mi-primer-terraform
```

### Paso 2: Crear el archivo main.tf

```bash
cat > main.tf <<'EOF'
terraform {
  required_version = ">= 1.0"
}

locals {
  project_name = "Mi Primer Proyecto"
  environment  = "desarrollo"
  created_by   = "Peru HUG"
}

output "hello_world" {
  value = "¡Hola desde Terraform!"
}

output "workspace_info" {
  value = "Workspace actual: ${terraform.workspace}"
}

output "project_info" {
  value = "${local.project_name} - ${local.environment}"
}

output "metadata" {
  value = {
    project     = local.project_name
    environment = local.environment
    created_by  = local.created_by
  }
}
EOF
```

### Paso 3: Inicializar Terraform

```bash
terraform init
```

### Paso 4: Validar la configuración

```bash
terraform validate
```

### Paso 5: Ver el plan

```bash
terraform plan
```

### Paso 6: Aplicar la configuración

```bash
terraform apply -auto-approve
```

### Paso 7: Ver los outputs

```bash
terraform output
```

### Paso 8: Inspeccionar el estado

```bash
terraform show
```

### Paso 9: Volver al directorio del lab y validar

```bash
cd /root/lab && bash validate-lab.sh
```

## ✅ Criterios de Validación

1. ✅ Archivo `main.tf` creado
2. ✅ `terraform init` ejecutado
3. ✅ `terraform validate` pasa
4. ✅ `terraform apply` ejecutado (`terraform.tfstate` generado)
5. ✅ Outputs configurados

## 🎓 Conceptos Aprendidos

- Estructura básica de un archivo Terraform
- Bloque `terraform` para versión mínima
- `locals` para valores reutilizables
- `output` para exponer información
- Comandos: `init`, `validate`, `plan`, `apply`, `output`
- Archivo de estado `terraform.tfstate`

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform First Configuration Badge**

---

**Anterior:** [Lab 1 - Instalación](../lab1-instalacion/)
**Siguiente:** [Lab 3 - Infraestructura Local](../lab3-infraestructura-local/)

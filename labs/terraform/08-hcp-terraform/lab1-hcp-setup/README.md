# Lab 1: HCP Terraform Setup

![Terraform](https://img.shields.io/badge/HCP_Terraform-Setup-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Configurar HCP Terraform (antes Terraform Cloud), crear un workspace remoto y conectar tu proyecto local para ejecutar runs en la nube.

## ⏱️ Duración
30 minutos

## 📋 Prerrequisitos
- ✅ Módulo 07 completado
- Cuenta en [app.terraform.io](https://app.terraform.io) (gratuita)
- Terraform instalado

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear Cuenta en HCP Terraform

1. Ve a [https://app.terraform.io/signup/account](https://app.terraform.io/signup/account)
2. Crea una cuenta gratuita (o usa tu cuenta existente)
3. Crea una organización: `peru-hug-<tu-nombre>`
4. Anota el nombre de tu organización

### Paso 2: Generar un Token de API

```bash
# Opción A: Desde la CLI (abre el browser automáticamente)
terraform login

# Opción B: Desde la UI
# 1. HCP Terraform → User Settings → Tokens
# 2. Create an API token
# 3. Copia el token

# Verificar que el token se guardó
cat ~/.terraform.d/credentials.tfrc.json
```

### Paso 3: Crear el Proyecto

```bash
mkdir lab1-hcp-setup
cd lab1-hcp-setup
```

Crea `versions.tf`:

```hcl
terraform {
  required_version = ">= 1.0"

  cloud {
    organization = "peru-hug-TU-NOMBRE"   # ← reemplaza con tu org

    workspaces {
      name = "lab-hcp-setup"
    }
  }

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}
```

Crea `main.tf`:

```hcl
variable "entorno" {
  type    = string
  default = "dev"
}

resource "local_file" "info" {
  filename = "./info-hcp.txt"
  content  = <<-EOT
    # Ejecutado desde HCP Terraform
    entorno = ${var.entorno}
  EOT
}

output "mensaje" {
  value = "Run ejecutado en HCP Terraform - entorno: ${var.entorno}"
}
```

### Paso 4: Inicializar y Conectar el Workspace

```bash
# terraform init detecta el bloque cloud y conecta con HCP Terraform
terraform init

# Verás:
# Terraform Cloud has been successfully initialized!
# You may now begin working with Terraform Cloud.
# ...workspace: lab-hcp-setup
```

### Paso 5: Ejecutar el Primer Run Remoto

```bash
# Plan remoto — se ejecuta en HCP Terraform
terraform plan

# Observa en la URL que imprime: puedes ver el plan en la UI
# https://app.terraform.io/app/<org>/workspaces/lab-hcp-setup/runs/<id>

# Apply remoto
terraform apply
```

### Paso 6: Explorar la UI de HCP Terraform

Ve a [https://app.terraform.io](https://app.terraform.io) y explora:

```
1. Organization → Workspaces → lab-hcp-setup
   - Runs: historial de plans y applies
   - State Versions: histórico del state
   - Variables: variables de entorno y Terraform

2. Workspace Settings
   - General: modo de ejecución (Remote / Local / Agent)
   - Notifications: alertas en Slack/email
   - Team Access: permisos por equipo
```

### Paso 7: Agregar Variables en HCP Terraform

```bash
# En la UI:
# Workspace → Variables → Add variable

# Variable Terraform (para el código):
# Key: entorno
# Value: produccion
# Sensitive: No

# Variable de Entorno (para el runner):
# Key: TF_LOG
# Value: INFO
# Sensitive: No

# Luego ejecutar apply para ver el efecto
terraform apply
```

### Paso 8: Ejecutar Validación Local

```bash
./validate-lab.sh
```

## ✅ Criterios de Validación

1. ✅ Cuenta en HCP Terraform creada
2. ✅ `terraform login` ejecutado con éxito
3. ✅ Workspace `lab-hcp-setup` creado
4. ✅ `terraform init` conecta con el workspace remoto
5. ✅ Al menos un run completado en HCP Terraform

## 🔧 Troubleshooting

### Error: "No valid credential sources found"

```bash
# El token no está configurado
terraform login
# O manualmente:
# nano ~/.terraform.d/credentials.tfrc.json
```

### Error: "Organization not found"

```bash
# Verifica el nombre exacto de la organización
# En HCP Terraform: Organization Settings → General → Organization Name
```

### Error: "Workspace already exists"

```bash
# El workspace ya fue creado en una sesión anterior
# Solo ejecuta terraform init, el workspace ya está listo
```

## 📚 Recursos

- [HCP Terraform Getting Started](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started)
- [Terraform Cloud Block](https://developer.hashicorp.com/terraform/language/settings/terraform-cloud)

## 🎓 Conceptos Aprendidos

- ✅ Diferencia entre Terraform CLI y HCP Terraform
- ✅ Bloque `cloud {}` vs bloque `backend "remote" {}`
- ✅ `terraform login` y gestión de tokens
- ✅ Runs remotos: plan y apply ejecutados en HCP
- ✅ Variables en HCP Terraform (Terraform vars y env vars)
- ✅ Historial de runs y versiones de state

## 🏆 Badge

Al completar este laboratorio obtienes: **HCP Terraform Setup Badge**

---

**Anterior:** [Módulo 07 - Maintain Infrastructure](../../07-maintain-infrastructure/)
**Siguiente:** [Lab 2 - VCS Workflows](../lab2-vcs-workflows/)

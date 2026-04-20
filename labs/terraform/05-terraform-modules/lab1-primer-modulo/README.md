# Lab 1: Crear Tu Primer Módulo

![Terraform](https://img.shields.io/badge/Terraform-Modules-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Crear un módulo local reutilizable de Terraform.

## ⏱️ Duración
30 minutos

## 📋 Prerrequisitos
- ✅ Módulos 1-4 completados
- Terraform instalado

## 🚀 Instrucciones

### Paso 1: Crear Estructura

```bash
mkdir -p lab1-modules/{modules/web-server,environments/dev}
cd lab1-modules
```

### Paso 2: Crear el Módulo

Crea `modules/web-server/main.tf`:

```hcl
resource "local_file" "server_config" {
  filename = "${path.root}/servers/${var.server_name}.txt"
  content  = <<-EOT
    Server: ${var.server_name}
    Type: ${var.server_type}
    Port: ${var.port}
    Environment: ${var.environment}
  EOT
}

resource "local_file" "server_log" {
  filename = "${path.root}/logs/${var.server_name}.log"
  content  = "Server ${var.server_name} initialized at ${timestamp()}"
}

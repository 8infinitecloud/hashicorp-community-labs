# Lab 3: Workspaces

![Terraform](https://img.shields.io/badge/Terraform-Workspaces-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Gestionar múltiples entornos (dev/staging/prod) usando Terraform workspaces, manteniendo states separados con la misma configuración.

## ⏱️ Duración
25 minutos

## 📋 Prerrequisitos
- ✅ Labs 1 y 2 del módulo 06 completados
- Terraform instalado

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear el Proyecto

```bash
mkdir lab3-workspaces
cd lab3-workspaces
```

Crea `main.tf`:

```hcl
terraform {
  required_version = ">= 1.0"
}

# terraform.workspace devuelve el nombre del workspace activo
locals {
  entorno = terraform.workspace

  config = {
    default  = { instancias = 1, tipo = "micro",  debug = true  }
    dev      = { instancias = 1, tipo = "micro",  debug = true  }
    staging  = { instancias = 2, tipo = "small",  debug = false }
    prod     = { instancias = 4, tipo = "large",  debug = false }
  }

  cfg = lookup(local.config, local.entorno, local.config["default"])
}

resource "local_file" "deploy" {
  filename = "${path.module}/deploy-${local.entorno}.conf"
  content  = <<-EOT
    # Configuración para: ${local.entorno}
    instancias = ${local.cfg.instancias}
    tipo       = ${local.cfg.tipo}
    debug      = ${local.cfg.debug}
  EOT
}

output "entorno"    { value = local.entorno }
output "instancias" { value = local.cfg.instancias }
output "tipo"       { value = local.cfg.tipo }
```

### Paso 2: Explorar el Workspace Default

```bash
# Ver workspace activo
terraform workspace show

# Listar todos los workspaces
terraform workspace list

# Inicializar
terraform init
terraform apply -auto-approve

# Ver qué se generó
cat deploy-default.conf
terraform output
```

### Paso 3: Crear y Usar Workspace Dev

```bash
# Crear workspace dev
terraform workspace new dev

# Verificar que cambió
terraform workspace show
terraform workspace list

# Aplicar — genera su propio state
terraform apply -auto-approve
cat deploy-dev.conf
terraform output entorno
```

### Paso 4: Crear Workspace Staging

```bash
terraform workspace new staging
terraform apply -auto-approve

cat deploy-staging.conf
terraform output instancias
# Debe mostrar 2
```

### Paso 5: Crear Workspace Prod

```bash
terraform workspace new prod
terraform apply -auto-approve

cat deploy-prod.conf
terraform output
# Debe mostrar instancias=4, tipo=large
```

### Paso 6: Comparar States Independientes

```bash
# Ver la estructura de states creada
ls -la terraform.tfstate.d/
ls terraform.tfstate.d/dev/
ls terraform.tfstate.d/staging/
ls terraform.tfstate.d/prod/

# Cada workspace tiene su propio terraform.tfstate
echo "=== dev ==="
cat terraform.tfstate.d/dev/terraform.tfstate | python3 -m json.tool | grep '"value"'

echo "=== prod ==="
cat terraform.tfstate.d/prod/terraform.tfstate | python3 -m json.tool | grep '"value"'
```

### Paso 7: Cambiar entre Workspaces

```bash
# Volver a dev
terraform workspace select dev
terraform workspace show
terraform output instancias   # 1

# Ir a prod
terraform workspace select prod
terraform output instancias   # 4

# Cada switch cambia el state activo automáticamente
```

### Paso 8: Destruir un Workspace

```bash
# Primero destruir los recursos del workspace
terraform workspace select staging
terraform destroy -auto-approve

# Volver a default para poder eliminar staging
terraform workspace select default

# Eliminar el workspace (solo si está vacío)
terraform workspace delete staging
terraform workspace list
```

### Paso 9: Ejecutar Validación

```bash
./validate-lab.sh
```

## ✅ Criterios de Validación

1. ✅ Workspaces dev, staging, prod creados
2. ✅ Cada workspace genera configuración diferente
3. ✅ States están separados en `terraform.tfstate.d/`
4. ✅ `terraform.workspace` usado en la configuración
5. ✅ Switch entre workspaces funciona correctamente

## 🔧 Troubleshooting

### Error: "workspace already exists"

```bash
# El workspace ya fue creado, solo selecciónalo
terraform workspace select dev
```

### Error: "workspace is not empty"

```bash
# Debes destruir los recursos antes de eliminar el workspace
terraform workspace select <nombre>
terraform destroy -auto-approve
terraform workspace select default
terraform workspace delete <nombre>
```

## 💡 Cuándo Usar Workspaces vs Directorios Separados

| Workspaces | Directorios separados |
|------------|----------------------|
| Misma configuración, entornos distintos | Configuraciones muy distintas por entorno |
| Rápido de crear y cambiar | Más control y aislamiento |
| Riesgo de aplicar en el entorno equivocado | Más difícil cometer errores |
| Recomendado para entornos similares | Recomendado para producción crítica |

## 🎓 Conceptos Aprendidos

- ✅ Crear, seleccionar y eliminar workspaces
- ✅ Usar `terraform.workspace` en configuraciones
- ✅ States independientes por workspace en `terraform.tfstate.d/`
- ✅ Lookup dinámico de config por entorno
- ✅ Cuándo usar workspaces vs estructuras de directorios

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Workspaces Badge**

---

**Anterior:** [Lab 2 - State Locking](../lab2-state-locking/)
**Siguiente:** [Lab 4 - State Migration](../lab4-state-migration/)

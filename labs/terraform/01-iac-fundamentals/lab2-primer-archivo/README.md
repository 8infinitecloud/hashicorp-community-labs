# Lab 2: Tu Primer Archivo Terraform

![Terraform](https://img.shields.io/badge/Terraform-First%20File-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Crear tu primera configuración Terraform paso a paso, entender la estructura de un archivo `.tf` y ejecutar el workflow básico: `init → validate → plan → apply`.

## ⏱️ Duración
20 minutos

## 📋 Prerrequisitos
- ✅ Lab 1 completado (Terraform instalado)

---

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear el directorio del proyecto

Cada proyecto Terraform vive en su propio directorio. Terraform busca todos los archivos `.tf` dentro del directorio de trabajo.

```bash
mkdir mi-primer-terraform
```

```bash
cd mi-primer-terraform
```

### Paso 2: Crear el archivo main.tf

Por convención, la configuración principal se llama `main.tf`. Lo creamos vacío primero:

```bash
touch main.tf
```

### Paso 3: Agregar el bloque `terraform`

El bloque `terraform {}` configura el comportamiento del propio Terraform. Aquí declaramos la versión mínima requerida:

```bash
cat > main.tf <<'EOF'
terraform {
  required_version = ">= 1.0"
}
EOF
```

> `required_version` evita que alguien aplique esta configuración con una versión antigua de Terraform que podría comportarse diferente.

### Paso 4: Agregar `locals`

Los `locals` son valores que defines una vez y reutilizas en todo el archivo. Funcionan como variables internas del módulo:

```bash
cat >> main.tf <<'EOF'

locals {
  project_name = "Mi Primer Proyecto"
  environment  = "desarrollo"
  created_by   = "Peru HUG"
}
EOF
```

> Nota el `>>` — agrega contenido al final del archivo sin borrar lo anterior.

### Paso 5: Agregar `outputs`

Los `outputs` muestran información después de que Terraform aplica la configuración. Son la forma de exponer valores al usuario o a otros módulos:

```bash
cat >> main.tf <<'EOF'

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

> `terraform.workspace` es el único atributo del objeto `terraform` disponible en HCL. Por defecto vale `"default"`.

### Paso 6: Verificar el archivo completo

```bash
cat main.tf
```

### Paso 7: Inicializar Terraform

`terraform init` prepara el directorio de trabajo: descarga providers, configura el backend y crea la carpeta `.terraform/`:

```bash
terraform init
```

Deberías ver: `Terraform has been successfully initialized!`

### Paso 8: Validar la configuración

`terraform validate` revisa que la sintaxis HCL sea correcta y que las referencias entre bloques sean válidas, **sin conectarse a ningún proveedor**:

```bash
terraform validate
```

Deberías ver: `Success! The configuration is valid.`

### Paso 9: Ver el plan de ejecución

`terraform plan` muestra qué cambios aplicará Terraform. Como solo tenemos outputs (sin recursos), no hay cambios de infraestructura:

```bash
terraform plan
```

### Paso 10: Aplicar la configuración

`terraform apply` aplica los cambios y genera el archivo de estado `terraform.tfstate`:

```bash
terraform apply -auto-approve
```

Verás los outputs al final de la ejecución.

### Paso 11: Ver los outputs

```bash
terraform output
```

### Paso 12: Inspeccionar el estado

Terraform guarda el estado actual de la infraestructura en `terraform.tfstate`. Puedes inspeccionarlo con:

```bash
terraform show
```

### Paso 13: Volver al directorio del lab y validar

```bash
cd /root/lab
```

```bash
bash validate-lab.sh
```

---

## ✅ Criterios de Validación

1. ✅ Directorio `mi-primer-terraform` creado
2. ✅ Archivo `main.tf` con outputs y locals
3. ✅ `terraform init` ejecutado
4. ✅ `terraform validate` pasa sin errores
5. ✅ `terraform apply` ejecutado (`terraform.tfstate` generado)

---

## 🎓 Conceptos Aprendidos

| Concepto | Descripción |
|----------|-------------|
| `terraform {}` | Configura el propio Terraform (versión, backend) |
| `locals {}` | Valores reutilizables dentro del módulo |
| `output {}` | Expone valores tras el apply |
| `terraform init` | Prepara el directorio de trabajo |
| `terraform validate` | Verifica sintaxis sin conectarse a providers |
| `terraform plan` | Muestra cambios pendientes |
| `terraform apply` | Aplica los cambios y actualiza el estado |
| `terraform.tfstate` | Archivo de estado — la fuente de verdad de Terraform |

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform First Configuration Badge**

---

**Anterior:** [Lab 1 - Instalación](../lab1-instalacion/)
**Siguiente:** [Lab 3 - Infraestructura Local](../lab3-infraestructura-local/)

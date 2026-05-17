# Lab 3: Módulos Avanzados

![Terraform](https://img.shields.io/badge/Terraform-Modules_Advanced-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Implementar módulos con `count`, `for_each` y `dynamic blocks` para crear configuraciones reutilizables y escalables.

## ⏱️ Duración
35 minutos

## 📋 Prerrequisitos
- ✅ Labs 1 y 2 del módulo 05 completados
- Terraform instalado
- Conceptos de for expressions (Módulo 04)

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear la Estructura del Proyecto

```bash
mkdir lab3-modulos-avanzados
cd lab3-modulos-avanzados
mkdir -p modules/servidor
```

### Paso 2: Módulo con Variable de Tipo Object

Crea `modules/servidor/main.tf`:

```hcl
# modules/servidor/main.tf

variable "servidores" {
  type = map(object({
    entorno  = string
    puerto   = number
    replicas = number
  }))
}

variable "prefijo" {
  type    = string
  default = "app"
}

# Usar for_each para crear un archivo de config por servidor
resource "local_file" "config" {
  for_each = var.servidores

  filename = "${path.module}/output/${each.key}.conf"
  content  = <<-EOT
    # Servidor: ${each.key}
    entorno  = ${each.value.entorno}
    puerto   = ${each.value.puerto}
    replicas = ${each.value.replicas}
  EOT
}

output "configs_creadas" {
  value = [for k, v in local_file.config : v.filename]
}
```

Crea `modules/servidor/versions.tf`:

```hcl
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}
```

### Paso 3: Dynamic Blocks en el Módulo

Crea `modules/servidor/dynamic.tf`:

```hcl
# modules/servidor/dynamic.tf
# Genera un archivo de inventario con dynamic blocks

variable "etiquetas" {
  type    = list(string)
  default = []
}

resource "local_file" "inventario" {
  filename = "${path.module}/output/inventario.txt"
  content  = <<-EOT
    # Inventario de Servidores
    # Generado automáticamente con Terraform

    ${join("\n", [
      for nombre, srv in var.servidores :
      "[${nombre}]\nentorno=${srv.entorno}\npuerto=${srv.puerto}\nreplicas=${srv.replicas}"
    ])}

    # Etiquetas aplicadas:
    ${length(var.etiquetas) > 0 ? join(", ", var.etiquetas) : "ninguna"}
  EOT
}
```

### Paso 4: Root Module con for_each

Crea `main.tf` en la raíz:

```hcl
# main.tf

terraform {
  required_version = ">= 1.0"
}

locals {
  servidores = {
    "web-prod" = {
      entorno  = "produccion"
      puerto   = 443
      replicas = 3
    }
    "web-dev" = {
      entorno  = "desarrollo"
      puerto   = 8080
      replicas = 1
    }
    "api-prod" = {
      entorno  = "produccion"
      puerto   = 8443
      replicas = 2
    }
  }
}

module "infra" {
  source = "./modules/servidor"

  servidores = local.servidores
  prefijo    = "peru-hug"
  etiquetas  = ["v2.0", "terraform", "bootcamp"]
}

output "configs" {
  value = module.infra.configs_creadas
}
```

Ejecuta:

```bash
# Crear directorio de output del módulo
mkdir -p modules/servidor/output

# Inicializar
terraform init

# Planificar — observa los recursos que se crearán por for_each
terraform plan

# Aplicar
terraform apply -auto-approve

# Ver configuraciones generadas
cat modules/servidor/output/web-prod.conf
cat modules/servidor/output/inventario.txt

# Ver outputs
terraform output configs
```

### Paso 5: Modificar un Servidor y Observar el Diff

```bash
# Edita main.tf: cambia replicas de web-dev de 1 a 2
# Luego observa qué cambia
terraform plan

# Solo afecta el recurso modificado, no los demás
terraform apply -auto-approve
```

### Paso 6: Agregar un Nuevo Servidor

```bash
# Añade en locals.servidores:
#   "db-prod" = { entorno = "produccion", puerto = 5432, replicas = 2 }
# Terraform debe crear solo ese recurso nuevo
terraform plan
terraform apply -auto-approve
```

### Paso 7: Ejecutar Validación

```bash
cd ../..
./validate-lab.sh
```

## ✅ Criterios de Validación

1. ✅ Módulo usa `for_each` con tipo `map(object(...))`
2. ✅ Se generan configs individuales por servidor
3. ✅ Archivo de inventario creado con contenido correcto
4. ✅ Modificar un servidor no afecta a los demás
5. ✅ Agregar un servidor solo crea recursos nuevos

## 🔧 Troubleshooting

### Error: "The map has no element with the key"

```bash
# Verifica que el map no esté vacío
terraform console
> local.servidores
```

### Error al crear output/

```bash
mkdir -p modules/servidor/output
```

## 🎓 Conceptos Aprendidos

- ✅ `for_each` con `map(object(...))` en módulos
- ✅ `each.key` y `each.value` dentro del módulo
- ✅ Outputs con `for` expressions
- ✅ Modificaciones aisladas con `for_each` (vs `count`)
- ✅ Dynamic content con `join` y heredoc

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Advanced Modules Badge**

---

**Anterior:** [Lab 2 - Registry Modules](../lab2-registry-modules/)
**Siguiente:** [Lab 4 - Organización de Proyectos](../lab4-organizacion-proyectos/)

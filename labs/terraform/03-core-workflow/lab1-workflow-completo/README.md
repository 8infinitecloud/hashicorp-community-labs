# Lab 1: Workflow Completo de Terraform

![Terraform](https://img.shields.io/badge/Terraform-Workflow-7B42BC?style=flat&logo=terraform)

## Objetivo

Ejecutar el ciclo completo de Terraform (Write → Init → Validate → Plan → Apply → Modify → Destroy) usando el provider `local` para crear y gestionar archivos de configuración, observando cómo el state captura cada cambio a lo largo del proceso.

## Duración

30 minutos

## Prerrequisitos

- Módulos 1 y 2 completados
- Terraform instalado (`terraform version` >= 1.0)

## Instrucciones Paso a Paso

### Paso 1: Crear la Estructura del Proyecto

```bash
mkdir -p /root/lab
```

El directorio `/root/lab` será el espacio de trabajo de este lab. Todos los archivos `.tf` y el estado local se almacenarán aquí.

### Paso 2: Crear el archivo main.tf

```bash
touch /root/lab/main.tf
```

Crear el archivo vacío primero permite verificar que el directorio existe y es escribible antes de volcas contenido en él.

```bash
cat > /root/lab/main.tf <<'EOF'
terraform {
  required_version = ">= 1.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# Archivo de configuración del servidor web
resource "local_file" "web_config" {
  filename = "/root/lab/output/web.conf"
  content  = <<-EOT
    [server]
    host     = "0.0.0.0"
    port     = 8080
    env      = "development"
    managed  = "terraform"
  EOT
}

# Archivo de registro del proyecto
resource "local_file" "project_readme" {
  filename = "/root/lab/output/PROJECT.md"
  content  = <<-EOT
    # Proyecto Terraform

    Gestionado con Terraform.
    Archivo: ${local_file.web_config.filename}
  EOT
}

output "web_config_path" {
  description = "Ruta del archivo de configuracion web"
  value       = local_file.web_config.filename
}

output "project_readme_path" {
  description = "Ruta del README del proyecto"
  value       = local_file.project_readme.filename
}
EOF
```

Este archivo declara dos recursos `local_file` con una dependencia implícita: `project_readme` referencia el atributo `filename` de `web_config`, por lo que Terraform creará `web_config` primero. Los `output` exponen rutas útiles tras el apply.

### Paso 3: INIT — Inicializar el Directorio de Trabajo

```bash
terraform -chdir=/root/lab init
```

`terraform init` descarga el provider `hashicorp/local`, crea el directorio `.terraform/` y genera el archivo de bloqueo `.terraform.lock.hcl`. Debe ejecutarse al menos una vez antes de cualquier otra operación.

### Paso 4: VALIDATE — Validar la Sintaxis

```bash
terraform -chdir=/root/lab validate
```

`terraform validate` comprueba que la configuración HCL es sintácticamente correcta y que las referencias entre recursos son coherentes. No hace llamadas a la API del provider ni necesita credenciales.

### Paso 5: FORMAT — Formatear el Código

```bash
terraform -chdir=/root/lab fmt
```

`terraform fmt` reescribe los archivos `.tf` aplicando el estilo canónico de HashiCorp: alineación de `=`, indentación con dos espacios y ordenamiento de bloques. Ejecutarlo antes de cada commit mantiene la coherencia del repositorio.

### Paso 6: PLAN — Previsualizar los Cambios

```bash
terraform -chdir=/root/lab plan
```

`terraform plan` compara la configuración deseada contra el estado actual y muestra exactamente qué recursos se crearán, modificarán o destruirán. La línea `Plan: 2 to add` confirma que se crearán los dos archivos sin afectar nada existente.

### Paso 7: Guardar el Plan en un Archivo

```bash
terraform -chdir=/root/lab plan -out=/root/lab/tfplan
```

Guardar el plan en un archivo binario garantiza que el `apply` subsiguiente ejecute exactamente lo que fue revisado, sin que cambios de última hora en la configuración alteren el resultado.

### Paso 8: APPLY — Aplicar el Plan

```bash
terraform -chdir=/root/lab apply /root/lab/tfplan
```

`terraform apply` ejecuta el plan guardado: crea los dos archivos en disco y actualiza el state file (`terraform.tfstate`) con los atributos reales de cada recurso. No se solicita confirmación porque se aplica un plan previamente aprobado.

### Paso 9: VERIFY — Inspeccionar el Estado y los Outputs

```bash
terraform -chdir=/root/lab output
```

`terraform output` imprime los valores definidos en los bloques `output` del state actual. Usar outputs en lugar de `cat` directo sobre el state es la práctica recomendada para exponer información a otros sistemas o scripts.

```bash
terraform -chdir=/root/lab state list
```

`terraform state list` enumera todos los recursos gestionados. Tras el apply deben aparecer `local_file.project_readme` y `local_file.web_config`.

### Paso 10: MODIFY — Modificar un Recurso y Volver a Planear

```bash
cat > /root/lab/main.tf <<'EOF'
terraform {
  required_version = ">= 1.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# Archivo de configuración del servidor web (actualizado)
resource "local_file" "web_config" {
  filename = "/root/lab/output/web.conf"
  content  = <<-EOT
    [server]
    host     = "0.0.0.0"
    port     = 9090
    env      = "staging"
    managed  = "terraform"
  EOT
}

# Archivo de registro del proyecto
resource "local_file" "project_readme" {
  filename = "/root/lab/output/PROJECT.md"
  content  = <<-EOT
    # Proyecto Terraform

    Gestionado con Terraform.
    Archivo: ${local_file.web_config.filename}
  EOT
}

output "web_config_path" {
  description = "Ruta del archivo de configuracion web"
  value       = local_file.web_config.filename
}

output "project_readme_path" {
  description = "Ruta del README del proyecto"
  value       = local_file.project_readme.filename
}
EOF
```

El puerto cambia de `8080` a `9090` y el entorno de `development` a `staging`. Modificar el contenido de un `local_file` obliga a Terraform a recrear el recurso porque el hash del contenido cambia.

```bash
terraform -chdir=/root/lab plan
```

El plan mostrará `~ local_file.web_config` con el símbolo `-/+` indicando destrucción y recreación. Revisar el plan antes de aplicar es fundamental para evitar sorpresas en entornos reales.

### Paso 11: Aplicar la Modificación

```bash
terraform -chdir=/root/lab apply -auto-approve
```

`-auto-approve` omite la confirmación interactiva. Es aceptable en este lab de aprendizaje; en producción siempre se recomienda revisar y confirmar explícitamente.

### Paso 12: DESTROY — Destruir Todos los Recursos

```bash
terraform -chdir=/root/lab destroy -auto-approve
```

`terraform destroy` elimina todos los recursos gestionados en el state y lo deja vacío. Ejecutar destroy al finalizar un lab evita acumular archivos o costos residuales en entornos cloud reales.

### Paso 13: Ejecutar la Validación del Lab

```bash
cd /root/lab
```

```bash
bash validate-lab.sh
```

El script verifica que Terraform está instalado, que el directorio fue inicializado, que `main.tf` contiene los recursos esperados y que el workflow fue ejecutado correctamente.

## Conceptos Clave

| Concepto | Descripción |
|---|---|
| `terraform init` | Descarga providers y prepara el directorio de trabajo |
| `terraform validate` | Comprueba sintaxis y referencias sin contactar la API |
| `terraform fmt` | Aplica el estilo canónico de HashiCorp al código HCL |
| `terraform plan` | Calcula y muestra la diferencia entre config y state |
| `terraform apply` | Ejecuta los cambios y actualiza el state |
| `terraform output` | Muestra los valores de los bloques `output` del state |
| `terraform state list` | Enumera los recursos registrados en el state |
| `terraform destroy` | Elimina todos los recursos gestionados |
| Plan file (`-out`) | Archivo binario que congela un plan para aplicarlo sin cambios |
| State file | Archivo JSON que registra el estado real de cada recurso gestionado |
| Dependencia implícita | Referencia de un recurso a un atributo de otro; Terraform infiere el orden |
| `-auto-approve` | Omite la confirmación interactiva; solo recomendado en desarrollo |

---

**Anterior:** [Modulo 3 - Core Workflow](../)
**Siguiente:** [Lab 2 - Targets Incremental](../lab2-targets-incremental/)

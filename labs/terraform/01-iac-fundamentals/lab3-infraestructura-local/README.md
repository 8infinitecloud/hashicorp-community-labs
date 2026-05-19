# Lab 3: Infraestructura Local con Terraform

## Objetivo

Crear una infraestructura simulada usando el provider `local` de Terraform, aplicando variables, locals, condicionales y outputs para entender cómo IaC genera configuraciones reales sin necesitar un cloud provider.

## Duración

30 minutos

## Prerrequisitos

- Lab 1 y Lab 2 del Módulo 1 completados
- Terraform instalado (verificar con `terraform version`)

## Escenario

Simularás el despliegue de una aplicación web generando sus archivos de configuración, variables de entorno y script de deployment mediante Terraform. La misma configuración funciona para desarrollo y producción simplemente cambiando una variable.

## Instrucciones

### Paso 1: Crear el directorio del proyecto

```bash
mkdir lab3-iac-demo
```

Crea el directorio de trabajo donde vivirán todos los archivos del lab.

```bash
cd lab3-iac-demo
```

Entra al directorio para que todos los comandos siguientes operen dentro de él.

### Paso 2: Crear el archivo main.tf

```bash
touch main.tf
```

Crea el archivo vacío antes de escribir su contenido.

```bash
cat > main.tf <<'EOF'
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

variable "app_name" {
  description = "Nombre de la aplicacion"
  type        = string
  default     = "MiAppPeruana"
}

variable "environment" {
  description = "Ambiente de deployment"
  type        = string
  default     = "desarrollo"
}

variable "region" {
  description = "Region simulada"
  type        = string
  default     = "sa-east-1"
}

locals {
  app_port = var.environment == "produccion" ? 443 : 8080
  replicas = var.environment == "produccion" ? 3 : 1
}

resource "local_file" "app_config" {
  filename = "config/app.conf"
  content  = <<-EOT
    [application]
    name = "${var.app_name}"
    environment = "${var.environment}"
    port = ${local.app_port}

    [deployment]
    region = "${var.region}"
    replicas = ${local.replicas}
    auto_scaling = ${var.environment == "produccion" ? "enabled" : "disabled"}

    [database]
    host = "db-${var.environment}.${var.region}.rds.amazonaws.com"
    port = 5432
    name = "${lower(var.app_name)}_${var.environment}"
  EOT
}

resource "local_file" "env_file" {
  filename = "config/.env"
  content  = <<-EOT
    APP_NAME=${var.app_name}
    APP_ENV=${var.environment}
    APP_PORT=${local.app_port}
    APP_REGION=${var.region}
    DB_HOST=db-${var.environment}.${var.region}.rds.amazonaws.com
    DB_PORT=5432
    DB_NAME=${lower(var.app_name)}_${var.environment}
  EOT
}

resource "local_file" "deploy_script" {
  filename        = "scripts/deploy.sh"
  file_permission = "0755"
  content         = <<-EOT
    #!/bin/bash
    echo "Deploying ${var.app_name} to ${var.environment}..."
    echo "Region: ${var.region}"
    echo "Replicas: ${local.replicas}"
    echo "Port: ${local.app_port}"
    echo "Configuration loaded from config/app.conf"
    echo "Starting ${local.replicas} instance(s)..."
    echo "Deployment complete!"
    echo "Access your app at: http://localhost:${local.app_port}"
  EOT
}

output "app_info" {
  value = {
    name        = var.app_name
    environment = var.environment
    region      = var.region
    port        = local.app_port
    replicas    = local.replicas
  }
}

output "files_created" {
  value = [
    local_file.app_config.filename,
    local_file.env_file.filename,
    local_file.deploy_script.filename,
  ]
}
EOF
```

Define tres recursos `local_file`: el archivo de configuración de la app, el archivo `.env` con variables de entorno, y el script de deployment. Los locals calculan el puerto y número de réplicas según el ambiente, demostrando que el mismo código sirve para desarrollo y producción.

### Paso 3: Inicializar Terraform

```bash
terraform init
```

Descarga el provider `hashicorp/local` y configura el directorio `.terraform`. Este paso es obligatorio antes de cualquier plan o apply.

### Paso 4: Ver el plan de ejecución

```bash
terraform plan
```

Muestra exactamente qué archivos va a crear Terraform sin aplicar ningún cambio. Revisa los valores calculados para `app_port` y `replicas` en el ambiente `desarrollo`.

### Paso 5: Aplicar la configuración

```bash
terraform apply -auto-approve
```

Crea los tres archivos (`config/app.conf`, `config/.env`, `scripts/deploy.sh`) y registra todos los recursos en el state file. Terraform crea los subdirectorios automáticamente.

### Paso 6: Verificar los archivos generados

```bash
ls -la config/ scripts/
```

Confirma que Terraform creó los subdirectorios y los tres archivos. El script `deploy.sh` debe aparecer con permisos `755`.

```bash
cat config/app.conf
```

Revisa la configuración generada: puerto `8080`, una sola réplica y auto-scaling desactivado, valores propios del ambiente `desarrollo`.

### Paso 7: Cambiar a producción

```bash
terraform apply -auto-approve -var="environment=produccion"
```

Aplica el mismo código con una variable diferente. Terraform detecta el drift entre el state actual y el nuevo plan, y actualiza los archivos. Verifica que ahora el puerto es `443`, las réplicas son `3` y auto-scaling está `enabled`.

```bash
cat config/app.conf
```

Confirma que el archivo refleja los nuevos valores de producción, demostrando idempotencia y reutilización del mismo código base.

### Paso 8: Ejecutar el script de deployment

```bash
bash scripts/deploy.sh
```

Ejecuta el script generado por Terraform para verificar que es ejecutable y muestra los valores correctos del ambiente activo.

### Paso 9: Destruir la infraestructura

```bash
terraform destroy -auto-approve
```

Elimina todos los archivos gestionados por Terraform y limpia el state. Los directorios vacíos quedan en el sistema de archivos, pero los recursos de Terraform desaparecen.

### Paso 10: Volver al directorio del lab y validar

```bash
cd /root/lab
```

Regresa al directorio raíz del lab donde se encuentra el script de validación.

```bash
bash validate-lab.sh
```

Ejecuta todas las verificaciones automáticas para confirmar que el lab fue completado correctamente.

## Conceptos

| Concepto | Descripcion |
|---|---|
| `variable` | Parametro de entrada que personaliza la configuracion sin cambiar el codigo |
| `locals` | Valores calculados a partir de variables, disponibles dentro del modulo |
| Condicional ternario | `condition ? true_val : false_val` — logica dinamica dentro de HCL |
| `local_file` | Recurso del provider `local` que crea un archivo en disco |
| `file_permission` | Permisos Unix del archivo generado, en formato octal como string |
| Interpolacion | `"${var.name}"` inserta el valor de una variable dentro de un string |
| `output` | Expone valores del modulo para inspeccion o consumo por otros modulos |
| Idempotencia | Aplicar el mismo plan multiples veces produce el mismo resultado final |
| `terraform destroy` | Elimina todos los recursos gestionados por el state actual |

---

**Anterior:** [Lab 2 - Primer Archivo](../lab2-primer-archivo/)
**Siguiente:** [Modulo 2 - Terraform Fundamentals](../../02-terraform-fundamentals/)

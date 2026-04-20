# Lab 3: Simular Infraestructura con Terraform Local

![Terraform](https://img.shields.io/badge/Terraform-Local%20Infrastructure-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Crear una "infraestructura" local usando Terraform para entender Infrastructure as Code sin necesidad de cloud providers.

## ⏱️ Duración
30 minutos

## 📋 Prerrequisitos
- ✅ Lab 1 completado (Terraform instalado)
- ✅ Lab 2 completado (Primer archivo Terraform)
- Editor de texto
- Terminal/línea de comandos

## 🎬 Escenario

Vas a simular la creación de una aplicación web con su configuración completa, usando solo archivos locales. Esto te permitirá entender cómo funciona IaC sin necesidad de una cuenta de AWS, Azure o GCP.

**Lo que crearás:**
- Archivo de configuración de la aplicación
- Variables de entorno
- Script de deployment
- Documentación automática

Todo generado automáticamente por Terraform basado en variables.

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear el Directorio del Proyecto

```bash
# Crear directorio
mkdir lab3-iac-demo
cd lab3-iac-demo
```

### Paso 2: Crear el Archivo main.tf

Crea un archivo `main.tf` con el siguiente contenido:

```hcl
# main.tf - Simulación de infraestructura web

# Variables de configuración
variable "app_name" {
  description = "Nombre de la aplicación"
  type        = string
  default     = "MiAppPeruana"
}

variable "environment" {
  description = "Ambiente de deployment"
  type        = string
  default     = "desarrollo"
}

variable "region" {
  description = "Región simulada"
  type        = string
  default     = "sa-east-1"  # São Paulo
}

# Locals para datos calculados
locals {
  timestamp = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  app_port  = var.environment == "produccion" ? 443 : 8080
  replicas  = var.environment == "produccion" ? 3 : 1
}

# Simular archivo de configuración de la app
resource "local_file" "app_config" {
  filename = "config/app.conf"
  content  = <<-EOT
    # Configuración de ${var.app_name}
    # Generado automáticamente por Terraform
    # Fecha: ${local.timestamp}
    
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

# Simular archivo de variables de entorno
resource "local_file" "env_file" {
  filename = "config/.env"
  content  = <<-EOT
    APP_NAME=${var.app_name}
    APP_ENV=${var.environment}
    APP_PORT=${local.app_port}
    APP_REGION=${var.region}
    
    # Database
    DB_HOST=db-${var.environment}.${var.region}.rds.amazonaws.com
    DB_PORT=5432
    DB_NAME=${lower(var.app_name)}_${var.environment}
    
    # Generado: ${local.timestamp}
  EOT
}

# Simular script de deployment
resource "local_file" "deploy_script" {
  filename        = "scripts/deploy.sh"
  content         = <<-EOT
    #!/bin/bash
    # Script de deployment para ${var.app_name}
    # Ambiente: ${var.environment}
    # Generado automáticamente por Terraform
    
    echo "🚀 Deploying ${var.app_name} to ${var.environment}..."
    echo "📍 Region: ${var.region}"
    echo "🔢 Replicas: ${local.replicas}"
    echo "🔌 Port: ${local.app_port}"
    
    # Simular deployment
    echo "✅ Configuration loaded from config/app.conf"
    echo "✅ Environment variables loaded from config/.env"
    echo "✅ Starting ${local.replicas} instance(s)..."
    echo "🎉 Deployment complete!"
    echo ""
    echo "Access your app at: http://localhost:${local.app_port}"
  EOT
  file_permission = "0755"
}

# Simular README de la infraestructura
resource "local_file" "readme" {
  filename = "README.md"
  content  = <<-EOT
    # ${var.app_name} - Infraestructura
    
    ## Información del Deployment
    
    - **Aplicación:** ${var.app_name}
    - **Ambiente:** ${var.environment}
    - **Región:** ${var.region}
    - **Puerto:** ${local.app_port}
    - **Réplicas:** ${local.replicas}
    - **Generado:** ${local.timestamp}
    
    ## Archivos Generados
    
    - \`config/app.conf\` - Configuración de la aplicación
    - \`config/.env\` - Variables de entorno
    - \`scripts/deploy.sh\` - Script de deployment
    
    ## Comandos
    
    \`\`\`bash
    # Ver configuración
    cat config/app.conf
    
    # Ejecutar deployment
    ./scripts/deploy.sh
    
    # Actualizar infraestructura
    terraform apply
    
    # Destruir infraestructura
    terraform destroy
    \`\`\`
    
    ## Cambiar Ambiente
    
    Para cambiar a producción:
    
    \`\`\`bash
    terraform apply -var="environment=produccion"
    \`\`\`
    
    ---
    Infraestructura gestionada con Terraform 💜
  EOT
}

# Outputs para mostrar información
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
    local_file.readme.filename
  ]
}

output "next_steps" {
  value = <<-EOT
    
    ✅ Infraestructura creada exitosamente!
    
    Próximos pasos:
    1. Revisa los archivos: ls -la config/ scripts/
    2. Lee el README: cat README.md
    3. Ejecuta el deploy: ./scripts/deploy.sh
    4. Cambia a producción: terraform apply -var="environment=produccion"
  EOT
}
```

### Paso 3: Inicializar y Aplicar

```bash
# Inicializar Terraform
terraform init

# Ver el plan
terraform plan

# Aplicar la configuración
terraform apply
```

Terraform te mostrará qué archivos va a crear. Escribe `yes` para confirmar.

### Paso 4: Explorar los Archivos Generados

```bash
# Ver estructura creada
tree .
# o
ls -la

# Ver configuración de la app
cat config/app.conf

# Ver variables de entorno
cat config/.env

# Ver el README generado
cat README.md
```

### Paso 5: Ejecutar el Script de Deployment

```bash
# Ejecutar el script generado
./scripts/deploy.sh
```

### Paso 6: Cambiar a Producción

```bash
# Aplicar con ambiente de producción
terraform apply -var="environment=produccion"

# Observa los cambios:
# - Puerto cambia de 8080 a 443
# - Réplicas cambian de 1 a 3
# - Auto-scaling se habilita

# Ver la nueva configuración
cat config/app.conf
```

### Paso 7: Experimentar con Variables

```bash
# Cambiar nombre de la app y región
terraform apply \
  -var="app_name=TiendaOnline" \
  -var="environment=produccion" \
  -var="region=us-east-1"

# Ver cómo cambió todo
cat config/app.conf
cat README.md
```

### Paso 8: Limpiar Todo

```bash
# Destruir la infraestructura (eliminar archivos)
terraform destroy

# Confirma con: yes

# Verificar que se eliminaron
ls -la config/ scripts/
```

### Paso 9: Ejecutar Validación

```bash
# Volver al directorio del lab
cd ..

# Ejecutar validación
./validate-lab.sh
```

## 🧪 Experimentos Adicionales

### Experimento 1: Crear Archivo de Variables

Crea un archivo `terraform.tfvars`:

```hcl
app_name    = "EcommercePeru"
environment = "staging"
region      = "sa-east-1"
```

Aplica sin especificar variables en la línea de comandos:
```bash
terraform apply
```

### Experimento 2: Agregar Más Archivos

Agrega un nuevo recurso al `main.tf`:

```hcl
resource "local_file" "docker_compose" {
  filename = "docker-compose.yml"
  content  = <<-EOT
    version: '3.8'
    services:
      app:
        image: ${lower(var.app_name)}:latest
        ports:
          - "${local.app_port}:${local.app_port}"
        environment:
          - APP_ENV=${var.environment}
        replicas: ${local.replicas}
  EOT
}
```

### Experimento 3: Usar Condicionales

Agrega lógica condicional:

```hcl
resource "local_file" "monitoring" {
  count    = var.environment == "produccion" ? 1 : 0
  filename = "config/monitoring.conf"
  content  = "Monitoring enabled for production"
}
```

Esto solo crea el archivo en producción.

## ✅ Criterios de Validación

Para completar exitosamente este laboratorio:

1. ✅ Proyecto `lab3-iac-demo` creado
2. ✅ Archivo `main.tf` con configuración completa
3. ✅ `terraform apply` ejecutado exitosamente
4. ✅ Archivos generados en `config/` y `scripts/`
5. ✅ Script de deployment ejecutado
6. ✅ Cambio a producción probado
7. ✅ `terraform destroy` ejecutado

## 🎓 Conceptos Aprendidos

- ✅ **Variables de entrada**: Parametrizar configuraciones
- ✅ **Locals**: Calcular valores dinámicamente
- ✅ **Condicionales**: Lógica basada en variables
- ✅ **Recursos**: Crear archivos con `local_file`
- ✅ **Interpolación**: Usar variables en strings
- ✅ **Outputs**: Mostrar información útil
- ✅ **Idempotencia**: Ejecutar múltiples veces sin problemas
- ✅ **Destroy**: Limpiar recursos creados

## 💡 ¿Qué Aprendiste?

Este lab demuestra conceptos clave de IaC:

1. **Declarativo**: Describes QUÉ quieres, no CÓMO hacerlo
2. **Reutilizable**: Mismo código para desarrollo y producción
3. **Versionable**: Todo en archivos que puedes versionar en Git
4. **Consistente**: Siempre genera la misma configuración
5. **Automatizable**: Perfecto para CI/CD

**En el mundo real**, en lugar de archivos locales crearías:
- Instancias EC2 en AWS
- Virtual Machines en Azure
- Compute Instances en GCP
- Redes, bases de datos, balanceadores, etc.

¡Pero el concepto es exactamente el mismo!

## 🔧 Troubleshooting

### Error: "Error creating file"

```bash
# Verificar permisos del directorio
ls -la

# Crear directorios manualmente si es necesario
mkdir -p config scripts
```

### Error: "Invalid template interpolation"

```bash
# Verificar sintaxis de interpolación
terraform validate

# Asegúrate de usar ${} correctamente
```

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform IaC Fundamentals Badge**

---

**Anterior:** [Lab 2 - Primer Archivo](../lab2-primer-archivo/)  
**Siguiente:** [Módulo 2 - Terraform Fundamentals](../../02-terraform-fundamentals/)

# Lab 1: Resources con Dependencias y Lifecycle

![Terraform](https://img.shields.io/badge/Terraform-Lifecycle-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Aprender a gestionar dependencias entre recursos y usar lifecycle rules para controlar el comportamiento de Terraform.

## ⏱️ Duración
35 minutos

## 📋 Prerrequisitos
- ✅ Módulos 1, 2 y 3 completados
- Terraform instalado
- Editor de texto

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear el Directorio del Proyecto

```bash
mkdir lab1-lifecycle
cd lab1-lifecycle
```

### Paso 2: Dependencias Implícitas

Crea `implicit-dependencies.tf`:

```hcl
# implicit-dependencies.tf - Dependencias por referencias

terraform {
  required_version = ">= 1.0"
}

# Archivo base
resource "local_file" "config" {
  filename = "${path.module}/config.txt"
  content  = "Database: ${local_file.database.filename}"
  
  # Dependencia implícita: referencia a local_file.database
}

# Archivo de base de datos
resource "local_file" "database" {
  filename = "${path.module}/database.txt"
  content  = "PostgreSQL Connection String"
}

# Archivo de logs que depende de config
resource "local_file" "logs" {
  filename = "${path.module}/logs.txt"
  content  = "Logging to: ${local_file.config.filename}"
  
  # Dependencia implícita: referencia a local_file.config
}
```

Ejecuta:

```bash
# Inicializar
terraform init

# Ver el grafo de dependencias
terraform graph

# Aplicar y observar el orden
terraform apply -auto-approve

# Terraform crea en orden:
# 1. database.txt (no tiene dependencias)
# 2. config.txt (depende de database)
# 3. logs.txt (depende de config)
```

### Paso 3: Dependencias Explícitas

Crea `explicit-dependencies.tf`:

```hcl
# explicit-dependencies.tf - Dependencias con depends_on

# Archivo principal
resource "local_file" "app" {
  filename = "${path.module}/app.txt"
  content  = "Application Started"
  
  # Dependencia explícita: debe crearse después de setup
  depends_on = [
    local_file.setup,
    local_file.env
  ]
}

# Archivo de setup
resource "local_file" "setup" {
  filename = "${path.module}/setup.txt"
  content  = "Setup Complete"
}

# Archivo de environment
resource "local_file" "env" {
  filename = "${path.module}/env.txt"
  content  = "Environment: production"
}

# Archivo de health check
resource "local_file" "health" {
  filename = "${path.module}/health.txt"
  content  = "Health Check: OK"
  
  # Debe crearse después de app
  depends_on = [local_file.app]
}
```

Ejecuta:

```bash
# Aplicar
terraform apply -auto-approve

# Orden de creación:
# 1. setup.txt y env.txt (paralelo)
# 2. app.txt (después de setup y env)
# 3. health.txt (después de app)

# Ver el estado
terraform state list
```

### Paso 4: Lifecycle - create_before_destroy

Crea `lifecycle-create-before.tf`:

```hcl
# lifecycle-create-before.tf

# Servidor web que no puede tener downtime
resource "local_file" "web_server" {
  filename = "${path.module}/web-server.txt"
  content  = "Web Server v1.0"
  
  lifecycle {
    # Crear nuevo antes de destruir el viejo
    create_before_destroy = true
  }
}

# Load balancer que depende del servidor
resource "local_file" "load_balancer" {
  filename = "${path.module}/load-balancer.txt"
  content  = "LB pointing to: ${local_file.web_server.filename}"
  
  lifecycle {
    create_before_destroy = true
  }
}
```

Ejecuta:

```bash
# Aplicar
terraform apply -auto-approve

# Modificar el contenido
# Edita el archivo y cambia v1.0 a v2.0
```

Modifica `lifecycle-create-before.tf`:

```hcl
resource "local_file" "web_server" {
  filename = "${path.module}/web-server.txt"
  content  = "Web Server v2.0"  # Cambio aquí
  
  lifecycle {
    create_before_destroy = true
  }
}
```

```bash
# Aplicar cambios
terraform apply -auto-approve

# Terraform:
# 1. Crea web-server.txt con v2.0
# 2. Actualiza load-balancer.txt
# 3. Destruye la versión v1.0

# Sin create_before_destroy habría downtime
```

### Paso 5: Lifecycle - prevent_destroy

Crea `lifecycle-prevent.tf`:

```hcl
# lifecycle-prevent.tf

# Base de datos crítica que no debe destruirse
resource "local_file" "database_critical" {
  filename = "${path.module}/database-critical.txt"
  content  = "CRITICAL DATABASE - DO NOT DELETE"
  
  lifecycle {
    # Prevenir destrucción accidental
    prevent_destroy = true
  }
}

# Backup de la base de datos
resource "local_file" "database_backup" {
  filename = "${path.module}/database-backup.txt"
  content  = "Backup of: ${local_file.database_critical.filename}"
  
  lifecycle {
    prevent_destroy = true
  }
}
```

Ejecuta:

```bash
# Aplicar
terraform apply -auto-approve

# Intentar destruir
terraform destroy

# ERROR: Resource has lifecycle.prevent_destroy
# Terraform rechaza la destrucción

# Para destruir, debes:
# 1. Remover prevent_destroy del código
# 2. Aplicar el cambio
# 3. Luego destruir
```

### Paso 6: Lifecycle - ignore_changes

Crea `lifecycle-ignore.tf`:

```hcl
# lifecycle-ignore.tf

# Archivo que puede ser modificado externamente
resource "local_file" "user_config" {
  filename = "${path.module}/user-config.txt"
  content  = "Initial Config"
  
  lifecycle {
    # Ignorar cambios en el contenido
    # Útil cuando usuarios modifican el archivo manualmente
    ignore_changes = [content]
  }
}

# Archivo con timestamp que siempre cambia
resource "local_file" "cache" {
  filename = "${path.module}/cache.txt"
  content  = "Cache created at: ${timestamp()}"
  
  lifecycle {
    # Ignorar cambios en content (timestamp siempre cambia)
    ignore_changes = [content]
  }
}
```

Ejecuta:

```bash
# Aplicar
terraform apply -auto-approve

# Modificar el archivo manualmente
echo "User Modified Content" > user-config.txt

# Planear de nuevo
terraform plan

# Terraform NO detecta cambios porque ignore_changes está activo

# Sin ignore_changes, Terraform revertiría el cambio manual
```

### Paso 7: Lifecycle - replace_triggered_by

Crea `lifecycle-replace.tf`:

```hcl
# lifecycle-replace.tf

# Configuración base
resource "local_file" "base_config" {
  filename = "${path.module}/base-config.txt"
  content  = "Base Config v1"
}

# Aplicación que debe recrearse si cambia la config base
resource "local_file" "application" {
  filename = "${path.module}/application.txt"
  content  = "Application using config"
  
  lifecycle {
    # Reemplazar si cambia base_config
    replace_triggered_by = [
      local_file.base_config
    ]
  }
}

# Servicio que depende de la aplicación
resource "local_file" "service" {
  filename = "${path.module}/service.txt"
  content  = "Service for: ${local_file.application.filename}"
  
  lifecycle {
    replace_triggered_by = [
      local_file.application
    ]
  }
}
```

Ejecuta:

```bash
# Aplicar
terraform apply -auto-approve

# Modificar base_config
```

Edita `lifecycle-replace.tf`:

```hcl
resource "local_file" "base_config" {
  filename = "${path.module}/base-config.txt"
  content  = "Base Config v2"  # Cambio aquí
}
```

```bash
# Aplicar
terraform apply -auto-approve

# Terraform:
# 1. Reemplaza base_config (cambió el content)
# 2. Reemplaza application (triggered by base_config)
# 3. Reemplaza service (triggered by application)
```

### Paso 8: Combinando Lifecycle Rules

Crea `lifecycle-combined.tf`:

```hcl
# lifecycle-combined.tf - Múltiples reglas

# Servidor de producción
resource "local_file" "prod_server" {
  filename = "${path.module}/prod-server.txt"
  content  = "Production Server v1.0"
  
  lifecycle {
    # Crear antes de destruir (sin downtime)
    create_before_destroy = true
    
    # No permitir destrucción accidental
    prevent_destroy = true
    
    # Ignorar cambios en file_permission
    # (pueden ser modificados por el sistema)
    ignore_changes = [file_permission]
  }
}

# Configuración que puede cambiar
resource "local_file" "dynamic_config" {
  filename = "${path.module}/dynamic-config.txt"
  content  = "Config updated at: ${timestamp()}"
  
  lifecycle {
    # Ignorar timestamp que siempre cambia
    ignore_changes = [content]
    
    # Pero prevenir destrucción
    prevent_destroy = true
  }
}
```

Ejecuta:

```bash
# Aplicar
terraform apply -auto-approve

# Intentar destruir
terraform destroy
# ERROR: prevent_destroy activo

# Modificar prod_server
# Terraform creará nuevo antes de destruir viejo
```

### Paso 9: Visualizar el Grafo de Dependencias

```bash
# Ver todas las dependencias
terraform graph

# Si tienes graphviz instalado:
terraform graph | dot -Tpng > dependencies.png
open dependencies.png  # macOS
xdg-open dependencies.png  # Linux

# Ver en formato más legible
terraform graph | grep -E "label|->
```

### Paso 10: Inspeccionar el Estado

```bash
# Listar todos los recursos
terraform state list

# Ver detalles de un recurso
terraform state show local_file.prod_server

# Ver dependencias en el state
terraform show -json | jq '.values.root_module.resources[] | {address, depends_on}'
```

### Paso 11: Limpiar (Comentar prevent_destroy primero)

Edita todos los archivos y comenta o remueve `prevent_destroy`:

```hcl
lifecycle {
  # prevent_destroy = true  # Comentado
}
```

Luego:

```bash
# Aplicar cambios
terraform apply -auto-approve

# Ahora sí destruir
terraform destroy -auto-approve

# Verificar
terraform state list
# (debe estar vacío)
```

### Paso 12: Ejecutar Validación

```bash
cd ..
./validate-lab.sh
```

## 📚 Lifecycle Rules Explicadas

### create_before_destroy

```hcl
lifecycle {
  create_before_destroy = true
}
```

**Cuándo usar:**
- Recursos que no pueden tener downtime
- Servidores web, bases de datos
- Load balancers

**Comportamiento:**
1. Crea el nuevo recurso
2. Actualiza dependencias
3. Destruye el viejo recurso

### prevent_destroy

```hcl
lifecycle {
  prevent_destroy = true
}
```

**Cuándo usar:**
- Recursos críticos
- Bases de datos de producción
- Buckets con datos importantes

**Comportamiento:**
- Terraform rechaza `destroy`
- Debes remover la regla primero

### ignore_changes

```hcl
lifecycle {
  ignore_changes = [
    tags,
    user_data,
    # all  # Ignorar todos los cambios
  ]
}
```

**Cuándo usar:**
- Atributos modificados externamente
- Tags gestionados por otros sistemas
- Configuraciones dinámicas

**Comportamiento:**
- Terraform ignora cambios en esos atributos
- No intenta revertirlos

### replace_triggered_by

```hcl
lifecycle {
  replace_triggered_by = [
    aws_security_group.web
  ]
}
```

**Cuándo usar:**
- Recursos que deben recrearse juntos
- Aplicaciones que dependen de configuración
- Servicios acoplados

**Comportamiento:**
- Si el recurso referenciado cambia
- Este recurso se reemplaza también

## 🔧 Tipos de Dependencias

### Implícitas (Automáticas)

```hcl
resource "local_file" "a" {
  content = "Hello"
}

resource "local_file" "b" {
  # Dependencia implícita por referencia
  content = local_file.a.content
}
```

### Explícitas (Manuales)

```hcl
resource "local_file" "a" {
  content = "Hello"
}

resource "local_file" "b" {
  content = "World"
  
  # Dependencia explícita
  depends_on = [local_file.a]
}
```

## 💡 Mejores Prácticas

1. **Prefiere dependencias implícitas**
   ```hcl
   # ✅ BIEN - Dependencia clara
   ami = data.aws_ami.ubuntu.id
   
   # ❌ MAL - Dependencia oculta
   depends_on = [data.aws_ami.ubuntu]
   ```

2. **Usa prevent_destroy en producción**
   ```hcl
   # Para recursos críticos
   resource "aws_db_instance" "prod" {
     lifecycle {
       prevent_destroy = true
     }
   }
   ```

3. **create_before_destroy para servicios**
   ```hcl
   # Para evitar downtime
   resource "aws_instance" "web" {
     lifecycle {
       create_before_destroy = true
     }
   }
   ```

4. **ignore_changes para atributos externos**
   ```hcl
   # Tags gestionados por otros sistemas
   resource "aws_instance" "web" {
     lifecycle {
       ignore_changes = [tags]
     }
   }
   ```

## 🔧 Troubleshooting

### Error: "cycle in dependency graph"

```bash
# Dependencia circular detectada
# A depende de B, B depende de A

# Solución: Revisar y romper el ciclo
```

### Error: "prevent_destroy set but destroy requested"

```bash
# Solución:
# 1. Remover prevent_destroy del código
# 2. terraform apply
# 3. terraform destroy
```

### Recursos se crean en orden incorrecto

```bash
# Agregar depends_on explícito
resource "..." "..." {
  depends_on = [resource.other]
}
```

## ✅ Criterios de Validación

1. ✅ Proyecto `lab1-lifecycle` creado
2. ✅ Archivos con dependencias implícitas
3. ✅ Archivos con dependencias explícitas
4. ✅ Lifecycle rules implementadas
5. ✅ Grafo de dependencias visualizado
6. ✅ Recursos limpiados

## 🎓 Conceptos Aprendidos

- ✅ Dependencias implícitas vs explícitas
- ✅ Lifecycle rule: create_before_destroy
- ✅ Lifecycle rule: prevent_destroy
- ✅ Lifecycle rule: ignore_changes
- ✅ Lifecycle rule: replace_triggered_by
- ✅ Grafo de dependencias
- ✅ Orden de creación de recursos

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Dependencies Master Badge**

---

**Anterior:** [Módulo 4 - Intro](../)  
**Siguiente:** [Lab 2 - Data Sources](../lab2-data-sources/)

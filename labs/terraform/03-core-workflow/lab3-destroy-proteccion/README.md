# Lab 3: Destroy Selectivo y Protección

![Terraform](https://img.shields.io/badge/Terraform-Protection-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Aprender a destruir recursos selectivamente y proteger recursos críticos contra destrucción accidental.

## ⏱️ Duración
25 minutos

## 📋 Prerrequisitos
- ✅ Lab 2 completado
- Terraform instalado

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear el Proyecto

```bash
mkdir lab3-protection
cd lab3-protection
```

### Paso 2: Crear main.tf

```hcl
# main.tf - Recursos con protección

terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# Recurso temporal (puede destruirse)
resource "local_file" "temp" {
  filename = "temp.txt"
  content  = "Este archivo es temporal"
}

# Recurso de desarrollo (puede destruirse)
resource "local_file" "dev" {
  filename = "dev.txt"
  content  = "Archivo de desarrollo"
}

# Recurso de producción (PROTEGIDO)
resource "local_file" "production" {
  filename = "production.txt"
  content  = "Archivo de producción - NO ELIMINAR"
  
  lifecycle {
    prevent_destroy = true
  }
}

# Recurso crítico (PROTEGIDO)
resource "local_file" "database_backup" {
  filename = "database_backup.txt"
  content  = "Backup crítico de base de datos"
  
  lifecycle {
    prevent_destroy = true
  }
}

output "files_created" {
  value = [
    local_file.temp.filename,
    local_file.dev.filename,
    local_file.production.filename,
    local_file.database_backup.filename
  ]
}
```

### Paso 3: Crear Todos los Recursos

```bash
terraform init
terraform apply -auto-approve

# Ver archivos creados
ls -la *.txt
```

### Paso 4: Experimento 1 - Destroy Selectivo

```bash
# Destruir recurso temporal
terraform destroy -target=local_file.temp

# Confirma con: yes

# Ver qué queda
terraform state list
ls -la *.txt
```

### Paso 5: Experimento 2 - Destroy Múltiple

```bash
# Destruir recurso de desarrollo
terraform destroy -target=local_file.dev

# Ver qué queda
terraform state list
```

### Paso 6: Experimento 3 - Intentar Destroy Protegido

```bash
# Intentar destruir recurso protegido
terraform destroy -target=local_file.production

# Output esperado:
# Error: Instance cannot be destroyed
# 
# Resource local_file.production has lifecycle.prevent_destroy set,
# but the plan calls for this resource to be destroyed.
```

### Paso 7: Experimento 4 - Plan de Destrucción Total

```bash
# Ver plan de destrucción total
terraform plan -destroy

# Observa: Error por recursos protegidos
```

### Paso 8: Experimento 5 - Remover Protección

Edita `main.tf` y comenta los bloques `lifecycle`:

```hcl
resource "local_file" "production" {
  filename = "production.txt"
  content  = "Archivo de producción - NO ELIMINAR"
  
  # lifecycle {
  #   prevent_destroy = true
  # }
}
```

```bash
# Aplicar cambio (actualiza state)
terraform apply -auto-approve

# Ahora sí puedes destruir
terraform destroy -target=local_file.production
```

### Paso 9: Limpiar Todo

```bash
# Asegúrate de que no hay lifecycle blocks
# Luego destruye todo
terraform destroy -auto-approve
```

### Paso 10: Ejecutar Validación

```bash
cd ..
./validate-lab.sh
```

## 📚 Lifecycle: prevent_destroy

### Sintaxis

```hcl
resource "tipo" "nombre" {
  # configuración...
  
  lifecycle {
    prevent_destroy = true
  }
}
```

### Casos de Uso Reales

```hcl
# Proteger base de datos de producción
resource "aws_db_instance" "production" {
  identifier = "prod-db"
  # ...
  
  lifecycle {
    prevent_destroy = true
  }
}

# Proteger bucket S3 con datos críticos
resource "aws_s3_bucket" "backups" {
  bucket = "company-backups"
  
  lifecycle {
    prevent_destroy = true
  }
}

# Proteger VPC de producción
resource "aws_vpc" "production" {
  cidr_block = "10.0.0.0/16"
  
  lifecycle {
    prevent_destroy = true
  }
}

# Proteger tabla DynamoDB
resource "aws_dynamodb_table" "users" {
  name = "users-prod"
  # ...
  
  lifecycle {
    prevent_destroy = true
  }
}
```

## 💡 Mejores Prácticas

### 1. Protege Recursos Críticos

```hcl
# ✅ BIEN - Recursos de producción protegidos
resource "aws_db_instance" "prod" {
  # ...
  lifecycle {
    prevent_destroy = true
  }
}

# ❌ MAL - Sin protección
resource "aws_db_instance" "prod" {
  # ...
}
```

### 2. Usa Tags para Identificar

```hcl
resource "aws_instance" "web" {
  # ...
  
  tags = {
    Environment = "production"
    Critical    = "true"
  }
  
  lifecycle {
    prevent_destroy = true
  }
}
```

### 3. Documenta la Protección

```hcl
# IMPORTANTE: Este recurso está protegido contra destrucción
# Para eliminarlo, primero comenta el lifecycle block
resource "aws_s3_bucket" "backups" {
  bucket = "critical-backups"
  
  lifecycle {
    prevent_destroy = true
  }
}
```

## ⚠️ Advertencias

1. **Solo protege contra `terraform destroy`**
   - No protege contra eliminación manual en la consola
   - No protege contra `terraform state rm`

2. **Para eliminar un recurso protegido:**
   - Comenta o elimina el `lifecycle` block
   - Ejecuta `terraform apply` (actualiza state)
   - Luego ejecuta `terraform destroy`

3. **No es una protección absoluta**
   - Es una capa de seguridad adicional
   - Combina con IAM policies y backups

## 🔧 Otros Lifecycle Rules

```hcl
resource "aws_instance" "web" {
  # ...
  
  lifecycle {
    # Prevenir destrucción
    prevent_destroy = true
    
    # Crear antes de destruir
    create_before_destroy = true
    
    # Ignorar cambios en ciertos atributos
    ignore_changes = [tags, user_data]
    
    # Reemplazar si cambia otro recurso
    replace_triggered_by = [aws_security_group.web]
  }
}
```

## ✅ Criterios de Validación

1. ✅ Recursos con y sin protección creados
2. ✅ Destroy selectivo ejecutado
3. ✅ Intento de destroy protegido (debe fallar)
4. ✅ Protección removida y recurso destruido

## 🎓 Conceptos Aprendidos

- ✅ `lifecycle.prevent_destroy` para protección
- ✅ Destroy selectivo con `-target`
- ✅ Plan de destrucción sin ejecutar
- ✅ Casos de uso reales de protección

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Protection Master Badge**

---

**Anterior:** [Lab 2 - Targets](../lab2-targets-incremental/)  
**Siguiente:** [Lab 4 - Calidad y Debugging](../lab4-calidad-debugging/)

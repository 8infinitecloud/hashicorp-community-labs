# Lab 3: Explorar el Terraform State

![Terraform](https://img.shields.io/badge/Terraform-State%20Management-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Entender cómo Terraform gestiona el estado de la infraestructura y aprender a inspeccionarlo.

## ⏱️ Duración
30 minutos

## 📋 Prerrequisitos
- ✅ Lab 2 completado
- Terraform instalado
- Conocimientos de JSON (básico)

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear el Directorio del Proyecto

```bash
mkdir lab2-state
cd lab2-state
```

### Paso 2: Crear el Archivo main.tf

```hcl
# main.tf - Recursos para explorar el state

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# Generar IDs aleatorios
resource "random_pet" "server_name" {
  length    = 2
  separator = "-"
}

resource "random_integer" "port" {
  min = 8000
  max = 9000
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "random_uuid" "session_id" {
}

# Crear archivos de configuración
resource "local_file" "server_config" {
  filename = "config/server.conf"
  content  = <<-EOT
    [server]
    name = ${random_pet.server_name.id}
    port = ${random_integer.port.result}
    session_id = ${random_uuid.session_id.result}
    
    [database]
    password = ${random_password.db_password.result}
    
    # Este archivo fue generado por Terraform
    # State file: terraform.tfstate
    # Generado: ${timestamp()}
  EOT
}

resource "local_file" "readme" {
  filename = "README.md"
  content  = <<-EOT
    # Servidor ${random_pet.server_name.id}
    
    ## Configuración
    - Puerto: ${random_integer.port.result}
    - Session ID: ${random_uuid.session_id.result}
    - Password DB: (ver server.conf)
    
    ## State Management
    Este proyecto usa Terraform state para rastrear recursos.
    
    ### Comandos útiles:
    
    \`\`\`bash
    # Ver state completo
    terraform show
    
    # Listar recursos
    terraform state list
    
    # Ver recurso específico
    terraform state show random_pet.server_name
    
    # Ver outputs
    terraform output
    
    # Actualizar state
    terraform refresh
    \`\`\`
    
    ## Recursos en el State
    
    1. random_pet.server_name
    2. random_integer.port
    3. random_password.db_password
    4. random_uuid.session_id
    5. local_file.server_config
    6. local_file.readme
    
    Total: 6 recursos gestionados por Terraform
  EOT
}

resource "local_file" "state_guide" {
  filename = "state-guide.md"
  content  = <<-EOT
    # Guía del Terraform State
    
    ## ¿Qué es el State?
    
    El state file (\`terraform.tfstate\`) es un archivo JSON que:
    
    - Mapea recursos reales a tu configuración
    - Almacena metadata de cada recurso
    - Mejora el performance (evita consultar APIs constantemente)
    - Permite detectar drift (cambios manuales)
    - Facilita colaboración en equipo
    
    ## Estructura del State File
    
    \`\`\`json
    {
      "version": 4,
      "terraform_version": "1.6.0",
      "serial": 1,
      "lineage": "unique-id",
      "outputs": {...},
      "resources": [...]
    }
    \`\`\`
    
    ### Campos Importantes
    
    - **version**: Versión del formato del state
    - **terraform_version**: Versión de Terraform que lo creó
    - **serial**: Número incremental de cambios
    - **lineage**: ID único del state (para detectar conflictos)
    - **outputs**: Valores de outputs
    - **resources**: Array de todos los recursos
    
    ## Comandos de State
    
    ### Inspección
    
    \`\`\`bash
    terraform state list              # Listar todos los recursos
    terraform state show RESOURCE     # Ver detalles de un recurso
    terraform show                    # Ver state completo legible
    terraform output                  # Ver outputs
    \`\`\`
    
    ### Modificación (Avanzado)
    
    \`\`\`bash
    terraform state mv SOURCE DEST    # Mover/renombrar recurso
    terraform state rm RESOURCE       # Remover del state (no destruye)
    terraform state pull              # Descargar state remoto
    terraform state push              # Subir state remoto
    \`\`\`
    
    ### Refresh
    
    \`\`\`bash
    terraform refresh                 # Actualizar state con realidad
    terraform plan -refresh-only      # Ver qué cambiaría
    terraform apply -refresh-only     # Aplicar solo refresh
    \`\`\`
    
    ## ⚠️ Advertencias Importantes
    
    1. **Nunca edites el state manualmente**
       - Usa comandos \`terraform state\`
       - El state es JSON pero muy complejo
    
    2. **El state puede contener secretos**
       - Passwords, API keys, etc.
       - No lo subas a Git sin encriptar
       - Usa remote state con encriptación
    
    3. **Backup automático**
       - Terraform crea \`terraform.tfstate.backup\`
       - Se actualiza en cada \`apply\`
    
    4. **Colaboración**
       - Usa remote state (S3, Terraform Cloud)
       - Habilita state locking
       - Evita conflictos de equipo
    
    ## Drift Detection
    
    Terraform detecta cuando alguien modificó recursos manualmente:
    
    \`\`\`bash
    # Alguien borró config/server.conf manualmente
    terraform plan
    # Output: Plan: 1 to add, 0 to change, 0 to destroy
    # Terraform lo recreará
    \`\`\`
    
    ## Remote State (Producción)
    
    \`\`\`hcl
    terraform {
      backend "s3" {
        bucket = "mi-terraform-state"
        key    = "prod/terraform.tfstate"
        region = "us-east-1"
        
        # State locking con DynamoDB
        dynamodb_table = "terraform-locks"
        encrypt        = true
      }
    }
    \`\`\`
    
    Generado: ${timestamp()}
  EOT
}

# Outputs
output "server_info" {
  value = {
    name       = random_pet.server_name.id
    port       = random_integer.port.result
    session_id = random_uuid.session_id.result
  }
}

output "files_created" {
  value = [
    local_file.server_config.filename,
    local_file.readme.filename,
    local_file.state_guide.filename
  ]
}

output "state_commands" {
  value = <<-EOT
    
    📊 Comandos para explorar el state:
    
    1. terraform state list
    2. terraform state show random_pet.server_name
    3. terraform show
    4. terraform output
    5. cat terraform.tfstate | jq .
  EOT
}
```

### Paso 3: Inicializar y Aplicar

```bash
# Inicializar
terraform init

# Aplicar
terraform apply
```

### Paso 4: Explorar el State

#### Comando 1: Listar Recursos

```bash
# Listar todos los recursos en el state
terraform state list

# Output:
# local_file.readme
# local_file.server_config
# local_file.state_guide
# random_integer.port
# random_password.db_password
# random_pet.server_name
# random_uuid.session_id
```

#### Comando 2: Ver Recurso Específico

```bash
# Ver detalles de un recurso
terraform state show random_pet.server_name

# Output:
# resource "random_pet" "server_name" {
#     id        = "brave-lion"
#     length    = 2
#     separator = "-"
# }
```

#### Comando 3: Ver State Completo

```bash
# Ver todo el state en formato legible
terraform show

# Ver state en JSON
cat terraform.tfstate

# Ver state con jq (más legible)
cat terraform.tfstate | jq .
```

#### Comando 4: Ver Outputs

```bash
# Ver todos los outputs
terraform output

# Ver output específico
terraform output server_info

# Ver en JSON
terraform output -json
```

### Paso 5: Explorar el Archivo terraform.tfstate

```bash
# Ver estructura del state
cat terraform.tfstate | jq 'keys'
# ["lineage", "outputs", "resources", "serial", "terraform_version", "version"]

# Ver solo recursos
cat terraform.tfstate | jq '.resources'

# Ver outputs
cat terraform.tfstate | jq '.outputs'

# Ver versión de Terraform
cat terraform.tfstate | jq '.terraform_version'

# Contar recursos
cat terraform.tfstate | jq '.resources | length'
```

### Paso 6: Detectar Drift

#### Experimento 1: Borrar un Archivo Manualmente

```bash
# Borrar el archivo de configuración
rm config/server.conf

# Ver qué detecta Terraform
terraform plan

# Output: Plan: 1 to add, 0 to change, 0 to destroy
# Terraform detectó que falta y lo recreará

# Recrear el archivo
terraform apply
```

#### Experimento 2: Modificar un Recurso

Modifica `main.tf`:

```hcl
resource "random_pet" "server_name" {
  length    = 3  # Cambiar de 2 a 3
  separator = "-"
}
```

```bash
# Ver los cambios
terraform plan

# Aplicar
terraform apply

# Ver cómo cambió el state
terraform state show random_pet.server_name
```

### Paso 7: Comandos Avanzados de State

```bash
# 1. Refresh: Actualizar state sin modificar recursos
terraform refresh

# 2. Ver qué cambiaría un refresh
terraform plan -refresh-only

# 3. Ver backup del state
cat terraform.tfstate.backup

# 4. Comparar state actual vs backup
diff terraform.tfstate terraform.tfstate.backup

# 5. Ver lineage (ID único del state)
cat terraform.tfstate | jq '.lineage'

# 6. Ver serial (número de cambios)
cat terraform.tfstate | jq '.serial'
```

### Paso 8: Ejecutar Validación

```bash
cd ..
./validate-lab.sh
```

## 📚 Conceptos Clave

### Estructura del State

```json
{
  "version": 4,
  "terraform_version": "1.6.0",
  "serial": 3,
  "lineage": "abc-123-def",
  "outputs": {
    "server_info": {
      "value": {...},
      "type": "object"
    }
  },
  "resources": [
    {
      "mode": "managed",
      "type": "random_pet",
      "name": "server_name",
      "provider": "provider[\"registry.terraform.io/hashicorp/random\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "id": "brave-lion",
            "length": 2,
            "separator": "-"
          }
        }
      ]
    }
  ]
}
```

### Campos Importantes

- **serial**: Incrementa con cada cambio
- **lineage**: ID único para detectar conflictos
- **resources**: Array de todos los recursos
- **outputs**: Valores calculados

### Drift Detection

Terraform compara:
1. **Configuración** (main.tf)
2. **State** (terraform.tfstate)
3. **Realidad** (recursos reales)

Si hay diferencias, Terraform las corrige.

## ⚠️ Advertencias Importantes

### 1. No Editar Manualmente

```bash
# ❌ NO HACER
vim terraform.tfstate

# ✅ HACER
terraform state mv ...
terraform state rm ...
```

### 2. El State Contiene Secretos

```hcl
resource "random_password" "db" {
  length = 16
}

# El password está en el state en texto plano!
```

**Solución:** Usa remote state con encriptación.

### 3. Backup Automático

Terraform crea `terraform.tfstate.backup` automáticamente.

### 4. Colaboración

Para equipos, usa remote state:
- AWS S3 + DynamoDB
- Terraform Cloud
- Azure Blob Storage
- Google Cloud Storage

## 🔧 Comandos de State

### Inspección

```bash
terraform state list                    # Listar recursos
terraform state show RESOURCE           # Ver detalles
terraform show                          # Ver todo
terraform output                        # Ver outputs
```

### Modificación

```bash
terraform state mv SOURCE DEST          # Mover/renombrar
terraform state rm RESOURCE             # Remover
terraform state replace-provider OLD NEW # Cambiar provider
```

### Refresh

```bash
terraform refresh                       # Actualizar state
terraform plan -refresh-only            # Ver cambios
terraform apply -refresh-only           # Aplicar refresh
```

## ✅ Criterios de Validación

1. ✅ Proyecto `lab2-state` creado
2. ✅ Múltiples recursos creados
3. ✅ State file generado
4. ✅ Comandos de inspección ejecutados
5. ✅ Drift detection probado
6. ✅ Archivos guía generados

## 🎓 Conceptos Aprendidos

- ✅ Estructura del state file
- ✅ Comandos de inspección
- ✅ Drift detection
- ✅ State refresh
- ✅ Backup automático
- ✅ Mejores prácticas de state
- ✅ Remote state (conceptos)

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform State Manager Badge**

---

**Anterior:** [Lab 2 - Providers](../lab2-providers/)  
**Siguiente:** [Lab 4 - CLI Avanzado](../lab4-cli-avanzado/)

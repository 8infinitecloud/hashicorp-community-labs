# Lab 2: Targets y Apply Incremental

![Terraform](https://img.shields.io/badge/Terraform-Targeting-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Aprender a aplicar cambios incrementales usando targets para recursos específicos.

## ⏱️ Duración
30 minutos

## 📋 Prerrequisitos
- ✅ Lab 1 completado
- Terraform instalado

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear el Proyecto

```bash
mkdir lab3-targets
cd lab3-targets
```

### Paso 2: Crear main.tf

```hcl
# main.tf - Múltiples recursos con dependencias

terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# Recurso 1: ID aleatorio
resource "random_id" "server" {
  byte_length = 4
}

# Recurso 2: Pet name
resource "random_pet" "app_name" {
  length    = 2
  separator = "-"
}

# Recurso 3: Password
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Recurso 4: Archivo de configuración (depende de random_id)
resource "local_file" "config" {
  filename = "config/server-${random_id.server.hex}.conf"
  content  = <<-EOT
    [server]
    id = ${random_id.server.hex}
    name = ${random_pet.app_name.id}
    
    [database]
    password = ${random_password.db_password.result}
  EOT
}

# Recurso 5: Archivo README (depende de todo)
resource "local_file" "readme" {
  filename = "README.md"
  content  = <<-EOT
    # Servidor ${random_pet.app_name.id}
    
    ID: ${random_id.server.hex}
    Config: ${local_file.config.filename}
  EOT
}

output "all_resources" {
  value = {
    server_id   = random_id.server.hex
    app_name    = random_pet.app_name.id
    config_file = local_file.config.filename
    readme_file = local_file.readme.filename
  }
}
```

### Paso 3: Experimento 1 - Aplicar Solo un Recurso

```bash
# Inicializar
terraform init

# Aplicar solo random_pet
terraform plan -target=random_pet.app_name
terraform apply -target=random_pet.app_name

# Ver state (solo debe tener random_pet)
terraform state list
# Output: random_pet.app_name
```

### Paso 4: Experimento 2 - Aplicar con Dependencias

```bash
# Intentar aplicar local_file.config
terraform plan -target=local_file.config

# Observa: Terraform detecta que necesita random_id también
# Plan: 2 to add (random_id + local_file.config)

terraform apply -target=local_file.config

# Ver state
terraform state list
# Output:
# local_file.config
# random_id.server
# random_pet.app_name
```

### Paso 5: Experimento 3 - Aplicar Todo lo Restante

```bash
# Aplicar sin targets (crea lo que falta)
terraform apply

# Ver todos los recursos
terraform state list

# Ver outputs
terraform output
```

### Paso 6: Experimento 4 - Modificar con Target

Edita `main.tf` y cambia:

```hcl
resource "random_pet" "app_name" {
  length    = 3  # Cambiar de 2 a 3
  separator = "-"
}
```

```bash
# Plan solo para random_pet
terraform plan -target=random_pet.app_name

# Observa: También afecta a local_file.readme (dependencia)

# Aplicar
terraform apply -target=random_pet.app_name
```

### Paso 7: Experimento 5 - Destroy Selectivo

```bash
# Destruir solo el README
terraform destroy -target=local_file.readme

# Ver qué queda
terraform state list

# Limpiar todo
terraform destroy
```

### Paso 8: Ejecutar Validación

```bash
cd ..
./validate-lab.sh
```

## 📚 Uso de Targets

### Sintaxis

```bash
# Plan con target
terraform plan -target=RESOURCE_TYPE.RESOURCE_NAME

# Apply con target
terraform apply -target=RESOURCE_TYPE.RESOURCE_NAME

# Destroy con target
terraform destroy -target=RESOURCE_TYPE.RESOURCE_NAME

# Múltiples targets
terraform apply \
  -target=random_pet.app_name \
  -target=random_id.server
```

### Casos de Uso

1. **Debugging**: Crear recursos uno por uno para identificar problemas
2. **Cambios Controlados**: Aplicar cambios incrementales en producción
3. **Recuperación**: Recrear solo recursos específicos
4. **Testing**: Probar recursos individuales

## ⚠️ Advertencias

1. **Terraform respeta dependencias**: Si un recurso depende de otro, ambos se incluyen
2. **No uses targets regularmente**: Solo para casos especiales
3. **El state puede quedar inconsistente**: Usa con cuidado
4. **Mejor práctica**: Aplica todo el plan completo cuando sea posible

## ✅ Criterios de Validación

1. ✅ Proyecto creado con múltiples recursos
2. ✅ Apply con target ejecutado
3. ✅ Dependencias respetadas automáticamente
4. ✅ Destroy selectivo probado

## 🎓 Conceptos Aprendidos

- ✅ Usar `-target` para recursos específicos
- ✅ Terraform respeta dependencias automáticamente
- ✅ Apply y destroy selectivo
- ✅ Casos de uso de targets

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Targeting Expert Badge**

---

**Anterior:** [Lab 1 - Workflow](../lab1-workflow-completo/)  
**Siguiente:** [Lab 3 - Destroy y Protección](../lab3-destroy-proteccion/)

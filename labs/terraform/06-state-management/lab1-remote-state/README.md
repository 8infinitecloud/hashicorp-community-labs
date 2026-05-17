# Lab 1: Remote State

![Terraform](https://img.shields.io/badge/Terraform-Remote_State-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Entender la diferencia entre state local y remoto, y simular la configuración de un backend S3 para trabajo colaborativo.

## ⏱️ Duración
30 minutos

## 📋 Prerrequisitos
- ✅ Módulo 05 completado
- Terraform instalado
- Conocimiento del archivo `terraform.tfstate`

## 🚀 Instrucciones Paso a Paso

### Paso 1: Observar el State Local

```bash
mkdir lab1-remote-state
cd lab1-remote-state
```

Crea `main.tf`:

```hcl
# main.tf — configuración inicial con state LOCAL

terraform {
  required_version = ">= 1.0"
}

resource "local_file" "config" {
  filename = "${path.module}/app.conf"
  content  = "entorno=dev\nversion=1.0\n"
}

resource "local_file" "readme" {
  filename = "${path.module}/DEPLOYED.md"
  content  = "# Desplegado\nFecha: ${timestamp()}\n"
}

output "archivos" {
  value = [local_file.config.filename, local_file.readme.filename]
}
```

```bash
terraform init
terraform apply -auto-approve

# Inspecciona el state local
ls -la                        # verás terraform.tfstate
cat terraform.tfstate          # JSON con el estado actual
terraform state list           # lista recursos gestionados
terraform show                 # descripción legible
```

### Paso 2: Entender la Estructura del tfstate

```bash
# El state contiene:
# - versión del formato
# - terraform_version
# - resources: lista de recursos gestionados
# - cada recurso tiene: type, name, provider, instances
cat terraform.tfstate | python3 -m json.tool | head -50
```

### Paso 3: Problema con State Local en Equipo

Crea `notas-problema.txt`:

```bash
cat > notas-problema.txt << 'EOF'
PROBLEMA DEL STATE LOCAL:
- Solo existe en tu máquina
- Dos personas aplicando al mismo tiempo → conflicto
- Sin locking → corrupción del state
- No hay historial de cambios

SOLUCIÓN: Remote State
- Almacenado en S3, GCS, Azure Blob, etc.
- Locking con DynamoDB (AWS)
- Versionado del state
- Compartido por todo el equipo
EOF
cat notas-problema.txt
```

### Paso 4: Configuración del Backend S3 (referencia)

> **Nota:** En este lab el entorno no tiene AWS. Estudia la configuración y entiende la estructura.

```hcl
# backend.tf — configuración de backend S3

terraform {
  backend "s3" {
    bucket         = "mi-empresa-terraform-state"
    key            = "proyectos/app-web/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true

    # Locking con DynamoDB (ver Lab 2)
    dynamodb_table = "terraform-state-lock"
  }
}
```

Crea el archivo de referencia:

```bash
cat > backend-referencia.tf << 'EOF'
# REFERENCIA: backend S3 real
# No ejecutar en este lab — requiere AWS

terraform {
  backend "s3" {
    bucket         = "mi-empresa-terraform-state"
    key            = "proyectos/app-web/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
EOF
```

### Paso 5: Simular la Migración de State

```bash
# Ver el state actual
terraform state list

# En un escenario real, migrarías con:
# terraform init -migrate-state
# Terraform detecta el nuevo backend y pregunta si migrar

# Para este lab, mueve el state manualmente para simular
cp terraform.tfstate terraform.tfstate.backup
echo "State respaldado en terraform.tfstate.backup"

terraform state list
```

### Paso 6: Comandos Clave de State

```bash
# Listar recursos
terraform state list

# Ver detalle de un recurso
terraform state show local_file.config

# Sacar un recurso del state (sin destruirlo)
# terraform state rm local_file.readme

# Mover un recurso dentro del state
# terraform state mv local_file.config local_file.configuracion

# Importar recurso existente al state
# terraform import local_file.nuevo /ruta/al/archivo
```

### Paso 7: Ejecutar Validación

```bash
./validate-lab.sh
```

## ✅ Criterios de Validación

1. ✅ Proyecto con state local generado correctamente
2. ✅ `terraform.tfstate` inspeccionado
3. ✅ `terraform state list` ejecutado
4. ✅ Backup del state creado
5. ✅ Configuración de backend S3 de referencia creada

## 🔧 Troubleshooting

### Error: "state file is locked"

```bash
# Forzar liberación del lock (solo si estás seguro)
terraform force-unlock LOCK_ID
```

### Error: "no state file found"

```bash
# El state no existe aún — ejecuta apply primero
terraform apply -auto-approve
```

## 📚 Recursos

- [Terraform Backends](https://developer.hashicorp.com/terraform/language/settings/backends/configuration)
- [S3 Backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)

## 🎓 Conceptos Aprendidos

- ✅ Estructura del archivo `terraform.tfstate`
- ✅ Diferencia entre state local y remoto
- ✅ Configuración del backend S3
- ✅ Comandos `state list`, `state show`, `state rm`, `state mv`
- ✅ Por qué el state remoto es necesario en equipos

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Remote State Badge**

---

**Anterior:** [Módulo 05 - Terraform Modules](../../05-terraform-modules/)
**Siguiente:** [Lab 2 - State Locking](../lab2-state-locking/)

# Lab 1: Remote State

![Terraform](https://img.shields.io/badge/Terraform-Remote_State-7B42BC?style=flat&logo=terraform)

## Objetivo

Entender la diferencia entre state local y remoto, inspeccionar la estructura de `terraform.tfstate`, y documentar la configuración de un backend remoto para trabajo colaborativo.

## Duracion

30 minutos

## Prerrequisitos

- Modulo 05 completado
- Terraform instalado (`terraform version` >= 1.0)
- Conocimiento basico del archivo `terraform.tfstate`

## Instrucciones Paso a Paso

### Paso 1: Preparar el directorio de trabajo

```bash
cd /root/lab
```

El lab ya tiene su directorio pre-creado en el contenedor. Siempre trabajaras desde `/root/lab`.

### Paso 2: Crear main.tf con state local

```bash
touch main.tf
```

```bash
cat > main.tf <<'EOF'
terraform {
  required_version = ">= 1.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

resource "local_file" "config" {
  filename = "${path.module}/app.conf"
  content  = "entorno=dev\nversion=1.0\n"
}

resource "local_file" "readme" {
  filename = "${path.module}/DEPLOYED.md"
  content  = "# Desplegado\nFecha: generado por Terraform\n"
}

output "archivos" {
  value = [local_file.config.filename, local_file.readme.filename]
}
EOF
```

`main.tf` define dos recursos `local_file` que generan archivos en disco. El bloque `required_providers` fija el proveedor `hashicorp/local` version 2.x para que Terraform sepa donde descargarlo.

### Paso 3: Inicializar y aplicar

```bash
terraform init
```

```bash
terraform apply -auto-approve
```

`terraform init` descarga el provider y crea el directorio `.terraform/`. `terraform apply` ejecuta la configuracion y escribe el resultado en `terraform.tfstate`.

### Paso 4: Inspeccionar el state local

```bash
ls -la
```

```bash
terraform state list
```

```bash
terraform state show local_file.config
```

`terraform state list` muestra los recursos gestionados por este state. `terraform state show` muestra los atributos completos de un recurso especifico, util para verificar que los valores son correctos.

### Paso 5: Leer la estructura del tfstate

```bash
python3 -m json.tool terraform.tfstate | head -40
```

El tfstate es un JSON con campos clave: `serial` (incrementa en cada apply), `terraform_version`, y `resources` (lista de recursos con sus atributos actuales). Nunca edites este archivo manualmente.

### Paso 6: Crear el archivo de notas sobre el problema del state local

```bash
touch notas-problema.txt
```

```bash
cat > notas-problema.txt <<'EOF'
PROBLEMA DEL STATE LOCAL:
- Solo existe en tu maquina local
- Dos personas aplicando al mismo tiempo generan conflicto
- Sin locking: posible corrupcion del state
- Sin historial de versiones

SOLUCION: Remote State
- Almacenado en S3, GCS, Azure Blob, Terraform Cloud, etc.
- Locking automatico (DynamoDB en AWS)
- State versionado y recuperable
- Compartido por todo el equipo de forma segura
EOF
```

Este archivo documenta el razonamiento detras del remote state. El state local es suficiente para proyectos personales, pero inviable en equipos porque no hay mecanismo de sincronizacion ni locking.

### Paso 7: Crear la referencia de configuracion de backend S3

```bash
touch backend-referencia.tf
```

```bash
cat > backend-referencia.tf <<'EOF'
# REFERENCIA: backend S3 real con locking via DynamoDB
# No ejecutar en este lab — requiere credenciales AWS reales

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

Esta es la configuracion tipica de backend S3 en produccion. `bucket` y `key` identifican donde se almacena el state. `dynamodb_table` habilita el locking automatico: cuando alguien ejecuta `apply`, Terraform escribe un registro en DynamoDB que bloquea a otros usuarios hasta que el apply termine.

### Paso 8: Respaldar el state antes de cualquier migracion

```bash
cp terraform.tfstate terraform.tfstate.backup
```

```bash
echo "State respaldado en terraform.tfstate.backup"
```

Siempre respalda el tfstate antes de operaciones de migracion. Si algo falla durante `terraform init -migrate-state`, puedes restaurar el state manualmente copiando el backup.

### Paso 9: Ver comandos clave de state

```bash
terraform state list
```

```bash
terraform state show local_file.config
```

```bash
terraform show
```

`terraform state list` lista todos los recursos gestionados. `terraform state show <recurso>` muestra sus atributos. `terraform show` muestra el estado completo en formato legible, equivalente a leer el tfstate pero sin JSON.

### Paso 10: Ejecutar validacion

```bash
cd /root/lab && bash validate-lab.sh
```

## Criterios de Validacion

1. Terraform inicializado (`.terraform/` presente)
2. `terraform.tfstate` existe y tiene `serial > 0`
3. El state contiene al menos 2 recursos
4. `notas-problema.txt` creado
5. `backend-referencia.tf` creado con bloque `backend`
6. `main.tf` usa el provider `local`

## Conceptos Aprendidos

- Estructura del archivo `terraform.tfstate`
- Diferencia entre state local y remoto
- Configuracion del backend S3 con locking DynamoDB
- Comandos `state list`, `state show`, `show`
- Por que el state remoto es necesario en equipos

---

**Anterior:** [Modulo 05 - Terraform Modules](../../05-terraform-modules/)
**Siguiente:** [Lab 2 - State Locking](../lab2-state-locking/)

# Lab 1: Remote State

![Terraform](https://img.shields.io/badge/Terraform-Remote_State-7B42BC?style=flat&logo=terraform)

## Objetivo

Configurar un backend S3 remoto usando LocalStack, almacenar el state en S3, e inspeccionar los recursos gestionados con `terraform state list` y `awslocal s3 ls`.

## Duracion

30 minutos

## Prerrequisitos

- Modulo 05 completado
- Terraform instalado (`terraform version` >= 1.0)
- LocalStack corriendo en el contenedor (se verifica en el Paso 1)

## Instrucciones Paso a Paso

### Paso 1: Verificar que LocalStack esta listo

```bash
curl -s http://localhost:4566/_localstack/health | jq .services.s3
```

Debe retornar `"running"` o `"available"`. LocalStack simula los servicios AWS en `http://localhost:4566`. Si el valor no es `"running"`, espera 10 segundos y vuelve a ejecutar el comando.

### Paso 2: Crear el bucket S3 para el remote state

```bash
awslocal s3 mb s3://tf-state-lab1
```

`awslocal` es un wrapper preconfigurado de la AWS CLI que apunta a LocalStack en `localhost:4566`. El bucket `tf-state-lab1` almacenara el archivo `terraform.tfstate` en lugar de guardarlo localmente en disco.

### Paso 3: Crear providers.tf con el backend S3

```bash
touch providers.tf
```

```bash
cat > providers.tf <<'EOF'
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket                      = "tf-state-lab1"
    key                         = "lab1/terraform.tfstate"
    region                      = "us-east-1"
    endpoint                    = "http://localhost:4566"
    access_key                  = "test"
    secret_key                  = "test"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = "http://localhost:4566"
  }
}
EOF
```

El bloque `backend "s3"` indica a Terraform que guarde el state en S3 en lugar del disco local. `force_path_style = true` es necesario para que la URL funcione con LocalStack. `skip_credentials_validation` evita llamadas reales a AWS IAM ya que usamos credenciales de prueba.

### Paso 4: Crear main.tf con un recurso AWS S3

```bash
touch main.tf
```

```bash
cat > main.tf <<'EOF'
resource "aws_s3_bucket" "app" {
  bucket = "mi-app-bucket-lab1"

  tags = {
    Entorno = "dev"
    Lab     = "remote-state"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.app.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.app.arn
}
EOF
```

Este recurso crea un bucket S3 gestionado por Terraform en LocalStack. El state de este recurso — su ARN, ID, region, etc. — se almacenara en el backend S3 configurado en `providers.tf`, no en un archivo local.

### Paso 5: Inicializar Terraform con el backend remoto

```bash
terraform init
```

`terraform init` descarga el provider AWS, detecta el bloque `backend "s3"`, y crea el archivo de state remoto en `s3://tf-state-lab1/lab1/terraform.tfstate`. Si ves el mensaje "Successfully configured the backend", el backend remoto esta activo.

### Paso 6: Aplicar la configuracion

```bash
terraform apply -auto-approve
```

Terraform aplica el plan y crea el bucket `mi-app-bucket-lab1` en LocalStack. Al terminar, el state ya no existe en disco: fue escrito directamente en S3. El output muestra el nombre y ARN del bucket creado.

### Paso 7: Inspeccionar el state remoto en S3

```bash
awslocal s3 ls s3://tf-state-lab1/lab1/
```

```bash
terraform state list
```

`awslocal s3 ls` confirma que el archivo `terraform.tfstate` existe en el bucket S3. `terraform state list` lo recupera remotamente y lista los recursos gestionados, demostrando que Terraform puede trabajar con el state remoto de forma transparente.

### Paso 8: Ver los detalles del recurso en el state remoto

```bash
terraform state show aws_s3_bucket.app
```

`terraform state show` descarga el state desde S3 y muestra todos los atributos del recurso. Esto funciona igual que con el state local, pero el origen es el bucket S3 en LocalStack.

### Paso 9: Ejecutar validacion

```bash
cd /root/lab
```

```bash
bash validate-lab.sh
```

## Criterios de Validacion

1. LocalStack responde en `http://localhost:4566` con S3 en estado `running`
2. Bucket `tf-state-lab1` existe en LocalStack
3. `terraform.tfstate` en S3 en `lab1/terraform.tfstate`
4. `terraform state list` muestra `aws_s3_bucket.app`
5. `providers.tf` contiene bloque `backend "s3"`
6. No existe `terraform.tfstate` local (el state esta en S3)

## Conceptos Aprendidos

| Concepto | Descripcion |
|----------|-------------|
| Remote State | State almacenado en S3 en lugar del disco local |
| `backend "s3"` | Bloque de configuracion del backend en Terraform |
| `force_path_style` | Necesario para URLs de S3 compatibles con LocalStack |
| `awslocal` | Wrapper de AWS CLI preconfigurado para LocalStack |
| `terraform state list` | Lista recursos del state (local o remoto) |
| `terraform state show` | Muestra atributos completos de un recurso en el state |

---

**Anterior:** [Modulo 05 - Terraform Modules](../../05-terraform-modules/)
**Siguiente:** [Lab 2 - State Locking](../lab2-state-locking/)

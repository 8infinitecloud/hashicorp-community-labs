# Lab 3: Drift Detection

![Terraform](https://img.shields.io/badge/Terraform-Drift_Detection-7B42BC?style=flat&logo=terraform)
![LocalStack](https://img.shields.io/badge/LocalStack-AWS_Local-FF9900?style=flat)

## Objetivo

Detectar y reconciliar *configuration drift* real usando buckets S3 en el servidor mock de AWS. El drift ocurre cuando alguien modifica infraestructura directamente en AWS (o en este caso, via el CLI con `--endpoint-url`) sin pasar por Terraform.

## Duracion

25 minutos

## Prerrequisitos

- Labs 1 y 2 del modulo 07 completados
- Terraform instalado
- Mock AWS server corriendo en el contenedor (se verifica en el Paso 1)

## Instrucciones Paso a Paso

### Paso 1: Verificar que el servidor Mock AWS esta listo

```bash
curl -sf http://localhost:4566/ > /dev/null && echo "Mock AWS server OK" || echo "No disponible aun"
```

El servidor mock corre en `http://localhost:4566`. Si muestra "No disponible aun", espera unos segundos y vuelve a intentarlo.

### Paso 2: Preparar el directorio de trabajo

```bash
mkdir -p /root/lab
cd /root/lab
```

Todos los archivos del lab viviran en `/root/lab`. El validate al final esperara encontrarlos en este directorio.

### Paso 3: Crear la configuracion Terraform

```bash
touch main.tf
```

```bash
cat > main.tf <<'EOF'
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
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

resource "aws_s3_bucket" "app" {
  bucket        = "app-bucket-drift-lab"
  force_destroy = true
}

resource "aws_s3_bucket_tagging" "app" {
  bucket = aws_s3_bucket.app.id
  tagging {
    tag_set {
      key   = "Environment"
      value = "dev"
    }
    tag_set {
      key   = "ManagedBy"
      value = "terraform"
    }
  }
}
EOF
```

El provider apunta a LocalStack usando credenciales ficticias y desactivando las validaciones de AWS. El bucket `app-bucket-drift-lab` tiene dos tags que Terraform gestionara: `Environment=dev` y `ManagedBy=terraform`.

### Paso 4: Inicializar Terraform

```bash
terraform init
```

Terraform descarga el provider `hashicorp/aws` y configura el directorio `.terraform`. Esto es necesario antes de cualquier operacion.

### Paso 5: Aplicar la configuracion inicial

```bash
terraform apply -auto-approve
```

Terraform crea el bucket y aplica los tags. El state local (`terraform.tfstate`) queda sincronizado con lo que existe en LocalStack.

### Paso 6: Verificar el estado inicial de los tags

```bash
aws --endpoint-url http://localhost:4566 s3api get-bucket-tagging --bucket app-bucket-drift-lab
```

Debes ver `Environment=dev` y `ManagedBy=terraform`. Este es el estado "correcto" definido por el codigo Terraform.

### Paso 7: Simular drift — cambio manual fuera de Terraform

```bash
aws --endpoint-url http://localhost:4566 s3api put-bucket-tagging --bucket app-bucket-drift-lab --tagging 'TagSet=[{Key=Environment,Value=produccion},{Key=ManagedBy,Value=manual}]'
```

Esto simula lo que ocurre cuando alguien entra directamente a la consola de AWS y cambia los tags de emergencia, o cuando un script externo sobreescribe la configuracion. El state de Terraform todavia dice `Environment=dev`, pero la realidad en AWS ahora dice `Environment=produccion`.

### Paso 8: Verificar el drift introducido

```bash
aws --endpoint-url http://localhost:4566 s3api get-bucket-tagging --bucket app-bucket-drift-lab
```

Confirmas que los tags en el recurso real son diferentes a los que Terraform espera. Esto es el drift: brecha entre el estado deseado (codigo) y el estado real (infraestructura).

### Paso 9: Detectar el drift con terraform plan

```bash
terraform plan
```

Terraform compara su state contra la realidad actual en LocalStack. El plan muestra que quiere revertir los tags a `Environment=dev` y `ManagedBy=terraform`. En un pipeline de CI, un exit code 2 aqui dispara una alerta de drift.

### Paso 10: Reconciliar — aplicar el estado deseado

```bash
terraform apply -auto-approve
```

Terraform sobreescribe los cambios manuales con los valores del codigo. La fuente de verdad es siempre el codigo HCL, no la consola de AWS.

### Paso 11: Agregar ignore_changes para campos gestionados externamente

```bash
cat > main.tf <<'EOF'
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
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

resource "aws_s3_bucket" "app" {
  bucket        = "app-bucket-drift-lab"
  force_destroy = true

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_s3_bucket_tagging" "app" {
  bucket = aws_s3_bucket.app.id
  tagging {
    tag_set {
      key   = "Environment"
      value = "dev"
    }
    tag_set {
      key   = "ManagedBy"
      value = "terraform"
    }
  }
}
EOF
```

`lifecycle { ignore_changes = [tags] }` le dice a Terraform que ignore diferencias en el campo `tags` del bucket. Usar esto cuando otra herramienta (por ejemplo, un sistema de CMDB o AWS Config) necesita agregar sus propios tags sin que Terraform los revierta.

### Paso 12: Verificar que el plan no muestra cambios

```bash
terraform plan
```

Despues de reconciliar, el plan debe mostrar `No changes. Your infrastructure matches the configuration.` Con `ignore_changes` activo, futuras modificaciones manuales a los tags del bucket no apareceran en el plan.

### Paso 13: Ejecutar validacion

```bash
cd /root/lab
```

```bash
bash validate-lab.sh
```

## Conceptos Aprendidos

| Concepto | Descripcion |
|---|---|
| Configuration drift | Brecha entre el estado deseado (codigo) y el estado real (infraestructura) |
| `terraform plan` | Detecta drift comparando el state contra la realidad en el proveedor |
| Reconciliacion | `terraform apply` revierte los cambios manuales al estado definido en el codigo |
| `ignore_changes` | Indica a Terraform que ignore diferencias en campos especificos del recurso |
| `--endpoint-url` | Flag de AWS CLI para apuntar al servidor mock en lugar de AWS real |

---

**Anterior:** [Lab 2 - Upgrades](../lab2-upgrades/)
**Siguiente:** [Lab 4 - Troubleshooting](../lab4-troubleshooting/)

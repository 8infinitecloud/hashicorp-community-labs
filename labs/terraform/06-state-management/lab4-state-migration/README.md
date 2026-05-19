# Lab 4: State Migration

![Terraform](https://img.shields.io/badge/Terraform-State_Migration-7B42BC?style=flat&logo=terraform)

## Objetivo

Migrar el state de un backend local a un backend S3 remoto usando `terraform init -migrate-state`, verificar que el state remoto es identico al local, y confirmar que la infraestructura no cambia despues de la migracion.

## Duracion

30 minutos

## Prerrequisitos

- Labs 1, 2 y 3 del modulo 06 completados
- Terraform instalado (`terraform version` >= 1.0)
- LocalStack corriendo en el contenedor

## Instrucciones Paso a Paso

### Paso 1: Verificar que LocalStack esta listo

```bash
curl -s http://localhost:4566/_localstack/health | jq .services.s3
```

Debe retornar `"running"` o `"available"`. Este lab usa S3 como destino de la migracion del state, asi que necesitas que el servicio este disponible antes de continuar.

### Paso 2: Crear main.tf con backend local (sin bloque backend)

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
  bucket = "mi-app-bucket-lab4"

  tags = {
    Entorno = "dev"
    Lab     = "state-migration"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.app.bucket
}
EOF
```

Cuando no hay bloque `backend` en la configuracion, Terraform usa el backend local por defecto y guarda el state en `terraform.tfstate` en el directorio de trabajo. Este es el punto de partida: una configuracion existente con state local que necesita migrarse a un backend remoto.

### Paso 3: Inicializar y aplicar con backend local

```bash
terraform init
```

```bash
terraform apply -auto-approve
```

Terraform aplica la configuracion y crea el bucket `mi-app-bucket-lab4` en LocalStack. El state se guarda localmente en `terraform.tfstate`. Este es el escenario tipico de un proyecto que comenzo sin un backend remoto y ahora necesita ser compartido con el equipo.

### Paso 4: Verificar que el state local existe

```bash
ls -la terraform.tfstate
```

```bash
terraform state list
```

`terraform.tfstate` debe existir en el directorio actual con el recurso `aws_s3_bucket.app`. Esta es la evidencia del estado antes de la migracion. Es el archivo que se copiara al backend S3.

### Paso 5: Crear el bucket S3 de destino para el backend remoto

```bash
awslocal s3 mb s3://tf-state-lab4
```

El bucket de destino debe existir antes de ejecutar la migracion. Si Terraform no puede conectarse al bucket durante `init -migrate-state`, el proceso fallara y el state local permanecera intacto.

### Paso 6: Crear backend.tf con el bloque de backend S3

```bash
touch backend.tf
```

```bash
cat > backend.tf <<'EOF'
terraform {
  backend "s3" {
    bucket                      = "tf-state-lab4"
    key                         = "lab4/terraform.tfstate"
    region                      = "us-east-1"
    endpoint                    = "http://localhost:4566"
    access_key                  = "test"
    secret_key                  = "test"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
EOF
```

La migracion de backend se realiza en un archivo separado `backend.tf` para mantener limpio `main.tf`. Terraform permite dividir la configuracion en multiples archivos `.tf`. Al agregar este archivo, la proxima ejecucion de `terraform init` detectara el cambio de backend y ofrecera la migracion.

### Paso 7: Migrar el state al backend S3

```bash
terraform init -migrate-state -force-copy
```

`terraform init -migrate-state` detecta que hay un state local y que el backend cambio a S3. El flag `-force-copy` acepta automaticamente la pregunta de confirmacion. Terraform copia el contenido de `terraform.tfstate` al bucket S3 en `lab4/terraform.tfstate` y luego elimina el archivo local.

### Paso 8: Verificar que el state local ya no existe

```bash
ls terraform.tfstate 2>/dev/null && echo "AUN EXISTE - migracion no completa" || echo "OK - state local eliminado"
```

Tras una migracion exitosa, `terraform.tfstate` desaparece del directorio local porque el state ahora vive en S3. Si el archivo aun existe, la migracion no se completo correctamente.

### Paso 9: Verificar que el state existe en S3

```bash
awslocal s3 ls s3://tf-state-lab4/lab4/
```

```bash
terraform state list
```

`awslocal s3 ls` confirma que el archivo `terraform.tfstate` llego al bucket de destino. `terraform state list` lo recupera desde S3 y debe mostrar exactamente los mismos recursos que existian antes de la migracion.

### Paso 10: Confirmar que no hay cambios de infraestructura

```bash
terraform plan
```

`terraform plan` debe mostrar "No changes. Your infrastructure matches the configuration." Esto es la prueba definitiva de que la migracion fue exitosa: el state remoto es identico al local y la infraestructura real en LocalStack coincide con lo que describe el state.

### Paso 11: Ejecutar validacion

```bash
cd /root/lab
```

```bash
bash validate-lab.sh
```

## Criterios de Validacion

1. LocalStack S3 en estado `running`
2. Bucket `tf-state-lab4` existe
3. `terraform.tfstate` local no existe (migrado a S3)
4. State file en S3 en `lab4/terraform.tfstate`
5. `terraform state list` muestra `aws_s3_bucket.app`
6. `terraform plan` muestra sin cambios (exit code 0)
7. `backend.tf` contiene bloque `backend "s3"`

## Proceso de Migracion de Backend

| Paso | Comando | Descripcion |
|------|---------|-------------|
| 1 | `awslocal s3 mb s3://bucket` | Crear el bucket de destino |
| 2 | Crear `backend.tf` | Agregar bloque `backend "s3"` |
| 3 | `terraform init -migrate-state` | Copiar state local a S3 |
| 4 | `terraform state list` | Verificar recursos en state remoto |
| 5 | `terraform plan` | Confirmar sin cambios de infraestructura |

## Conceptos Aprendidos

| Concepto | Descripcion |
|----------|-------------|
| Backend local | State guardado en `terraform.tfstate` en disco local |
| `terraform init -migrate-state` | Comando que copia el state al nuevo backend |
| `-force-copy` | Acepta automaticamente la confirmacion de migracion |
| Validacion post-migracion | `terraform plan` sin cambios confirma integridad del state |
| `backend.tf` separado | Convencion para separar la config del backend del codigo |
| State eliminado localmente | Tras migracion exitosa, el archivo local desaparece |

---

**Anterior:** [Lab 3 - Workspaces](../lab3-workspaces/)
**Siguiente:** [Modulo 07 - Maintain Infrastructure](../../07-maintain-infrastructure/)

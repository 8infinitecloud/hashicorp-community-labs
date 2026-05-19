# Lab 2: State Locking

![Terraform](https://img.shields.io/badge/Terraform-State_Locking-7B42BC?style=flat&logo=terraform)

## Objetivo

Configurar DynamoDB como mecanismo de locking del state en un backend S3 con LocalStack, verificar que la tabla de locks existe, y confirmar que no queda ningun lock activo despues de un apply exitoso.

## Duracion

30 minutos

## Prerrequisitos

- Lab 1 del modulo 06 completado
- Terraform instalado (`terraform version` >= 1.0)
- LocalStack corriendo en el contenedor

## Instrucciones Paso a Paso

### Paso 1: Verificar que LocalStack esta listo

```bash
curl -s http://localhost:4566/_localstack/health | jq '{s3: .services.s3, dynamodb: .services.dynamodb}'
```

Ambos servicios deben mostrar `"running"` o `"available"`. DynamoDB es el servicio que almacena los locks de Terraform cuando se usa un backend S3. Si algun servicio no esta listo, espera unos segundos y reintenta.

### Paso 2: Crear el bucket S3 para el state

```bash
awslocal s3 mb s3://tf-state-lab2
```

Este bucket almacenara el `terraform.tfstate`. Se usa un bucket diferente al lab anterior (`tf-state-lab2`) para mantener cada lab aislado y evitar conflictos de state.

### Paso 3: Crear la tabla DynamoDB para el locking

```bash
awslocal dynamodb create-table \
  --table-name tf-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

La tabla DynamoDB debe crearse antes de ejecutar `terraform init`. El atributo `LockID` de tipo `String` es la clave de particion requerida por Terraform. Cuando Terraform inicia un `apply` o `plan`, escribe un item con la clave `LockID` en esta tabla; si el item ya existe, el comando falla con "Error acquiring the state lock".

### Paso 4: Crear providers.tf con backend S3 y locking DynamoDB

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
    bucket                      = "tf-state-lab2"
    key                         = "lab2/terraform.tfstate"
    region                      = "us-east-1"
    endpoint                    = "http://localhost:4566"
    access_key                  = "test"
    secret_key                  = "test"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
    dynamodb_table              = "tf-lock"
    dynamodb_endpoint           = "http://localhost:4566"
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
    s3       = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
  }
}
EOF
```

El campo `dynamodb_table = "tf-lock"` habilita el locking automatico. `dynamodb_endpoint` apunta a LocalStack en lugar del endpoint real de AWS DynamoDB. Cada vez que Terraform necesite escribir el state, primero intentara adquirir el lock en DynamoDB.

### Paso 5: Crear main.tf con recursos AWS

```bash
touch main.tf
```

```bash
cat > main.tf <<'EOF'
resource "aws_s3_bucket" "app" {
  bucket = "mi-app-bucket-lab2"

  tags = {
    Entorno = "dev"
    Lab     = "state-locking"
  }
}

resource "aws_dynamodb_table" "datos" {
  name         = "mi-tabla-datos"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Lab = "state-locking"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.app.bucket
}

output "tabla_name" {
  value = aws_dynamodb_table.datos.name
}
EOF
```

`main.tf` define dos recursos: un bucket S3 y una tabla DynamoDB. Tener dos recursos hace mas interesante observar el state y confirmar que el locking protege la escritura de ambos durante el apply.

### Paso 6: Inicializar y aplicar

```bash
terraform init
```

```bash
terraform apply -auto-approve
```

`terraform init` configura el backend S3 con locking. Durante el `apply`, Terraform escribe un item en `tf-lock` con `LockID = "tf-state-lab2/lab2/terraform.tfstate"`, aplica los cambios, y luego borra el item al terminar. El lock se libera automaticamente al finalizar con exito.

### Paso 7: Confirmar que la tabla de locks existe y no tiene locks activos

```bash
awslocal dynamodb scan --table-name tf-lock
```

La respuesta debe mostrar `"Count": 0` porque el apply ya termino y libero el lock. Si ves un item con `LockID`, significa que hay un apply en curso o que un proceso anterior termino de forma anormal (lock huerfano).

### Paso 8: Ver los recursos en el state

```bash
terraform state list
```

```bash
terraform state show aws_s3_bucket.app
```

`terraform state list` recupera el state desde S3 y lista los recursos. `terraform state show` muestra los atributos del bucket, incluyendo el ARN, region, y tags, todos almacenados en el state remoto.

### Paso 9: Inspeccionar el state file en S3

```bash
awslocal s3 ls s3://tf-state-lab2/lab2/
```

```bash
awslocal s3 cp s3://tf-state-lab2/lab2/terraform.tfstate - | python3 -m json.tool | head -20
```

El primer comando confirma que el archivo existe en S3. El segundo lo descarga y formatea el JSON para mostrar los primeros 20 campos: `version`, `terraform_version`, `serial`, y la lista de `resources`. El campo `serial` incrementa en cada apply exitoso.

### Paso 10: Ejecutar validacion

```bash
cd /root/lab
```

```bash
bash validate-lab.sh
```

## Criterios de Validacion

1. LocalStack con S3 y DynamoDB en estado `running`
2. Bucket `tf-state-lab2` existe
3. Tabla DynamoDB `tf-lock` existe
4. `terraform.tfstate` en S3 en `lab2/terraform.tfstate`
5. `terraform state list` muestra ambos recursos
6. No hay locks activos en `tf-lock` (Count = 0)
7. `providers.tf` contiene `dynamodb_table`

## Conceptos Aprendidos

| Concepto | Descripcion |
|----------|-------------|
| State Locking | Mecanismo que evita escrituras concurrentes al state |
| `dynamodb_table` | Tabla DynamoDB usada por Terraform para adquirir locks |
| `LockID` | Clave primaria del item de lock (ruta del state en S3) |
| Lock huerfano | Lock que quedo activo porque el proceso termino de forma anormal |
| `force-unlock` | Comando para liberar un lock huerfano manualmente |
| Lock liberado automaticamente | Al terminar apply/plan, Terraform borra el item de DynamoDB |

---

**Anterior:** [Lab 1 - Remote State](../lab1-remote-state/)
**Siguiente:** [Lab 3 - Workspaces](../lab3-workspaces/)

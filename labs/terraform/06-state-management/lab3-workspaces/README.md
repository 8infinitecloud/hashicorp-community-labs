# Lab 3: Workspaces

![Terraform](https://img.shields.io/badge/Terraform-Workspaces-7B42BC?style=flat&logo=terraform)

## Objetivo

Gestionar multiples entornos (dev y prod) usando Terraform workspaces con un backend S3 en LocalStack, donde cada workspace almacena su state en una ruta separada dentro del mismo bucket S3.

## Duracion

30 minutos

## Prerrequisitos

- Labs 1 y 2 del modulo 06 completados
- Terraform instalado (`terraform version` >= 1.0)
- Mock AWS server corriendo en el contenedor (se verifica en el Paso 1)

## Instrucciones Paso a Paso

### Paso 1: Verificar que el servidor Mock AWS esta listo

```bash
curl -sf http://localhost:4566/ > /dev/null && echo "Mock AWS server OK" || echo "No disponible aun"
```

Este lab usa unicamente S3 para el backend de los workspaces. El servidor mock lo expone en `localhost:4566` sin necesidad de credenciales reales.

### Paso 2: Crear el bucket S3 para los workspaces

```bash
aws --endpoint-url http://localhost:4566 s3 mb s3://tf-state-lab3
```

Un solo bucket alojara los states de todos los workspaces. Terraform separa automaticamente los states usando el prefijo `env:/<workspace>/` dentro del bucket, por lo que no necesitas crear buckets separados por entorno.

### Paso 3: Crear providers.tf con backend S3

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
    bucket                      = "tf-state-lab3"
    key                         = "workspaces/terraform.tfstate"
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

Con un backend S3, los workspaces no usan el directorio `terraform.tfstate.d/` en disco. En cambio, Terraform almacena el state de cada workspace en `env:/<nombre>/workspaces/terraform.tfstate` dentro del bucket. El workspace `default` sigue usando la ruta `key` sin prefijo.

### Paso 4: Crear main.tf con recursos diferenciados por workspace

```bash
touch main.tf
```

```bash
cat > main.tf <<'EOF'
resource "aws_s3_bucket" "entorno" {
  bucket = "mi-bucket-${terraform.workspace}-lab3"

  tags = {
    Entorno   = terraform.workspace
    Workspace = terraform.workspace
    Lab       = "workspaces"
  }
}

output "workspace_actual" {
  value = terraform.workspace
}

output "bucket_name" {
  value = aws_s3_bucket.entorno.bucket
}
EOF
```

`terraform.workspace` devuelve el nombre del workspace activo como cadena de texto. Usarlo en el nombre del bucket garantiza que cada workspace crea un recurso distinto en LocalStack, haciendo visible la separacion entre entornos con la misma configuracion de codigo.

### Paso 5: Inicializar Terraform

```bash
terraform init
```

`terraform init` descarga el provider AWS y configura el backend S3. En este punto estas en el workspace `default`. El estado inicial del workspace se crea cuando ejecutas el primer apply.

### Paso 6: Crear el workspace dev y aplicar

```bash
terraform workspace new dev
```

```bash
terraform workspace show
```

```bash
terraform apply -auto-approve
```

`terraform workspace new dev` crea el workspace y lo selecciona automaticamente. `terraform workspace show` confirma que estas en `dev`. El apply crea el bucket `mi-bucket-dev-lab3` en LocalStack y guarda el state en `s3://tf-state-lab3/env:/dev/workspaces/terraform.tfstate`.

### Paso 7: Crear el workspace prod y aplicar

```bash
terraform workspace new prod
```

```bash
terraform apply -auto-approve
```

Al crear el workspace `prod`, Terraform cambia automaticamente a el. El apply crea el bucket `mi-bucket-prod-lab3` en LocalStack con su propio state aislado. Los dos workspaces comparten el mismo codigo de `main.tf` pero cada uno gestiona recursos distintos.

### Paso 8: Listar los workspaces

```bash
terraform workspace list
```

El workspace activo aparece marcado con `*`. Deben verse al menos `default`, `dev`, y `prod`. Cada workspace tiene su propio ciclo de vida: puedes destruir o modificar `dev` sin afectar a `prod`.

### Paso 9: Inspeccionar las rutas de state en S3

```bash
aws --endpoint-url http://localhost:4566 s3 ls s3://tf-state-lab3/ --recursive
```

Terraform crea el state del workspace `dev` en `env:/dev/workspaces/terraform.tfstate` y el de `prod` en `env:/prod/workspaces/terraform.tfstate`. Esta estructura de rutas es la forma en que S3 backend implementa el aislamiento de workspaces sin necesitar buckets separados.

### Paso 10: Cambiar entre workspaces y verificar aislamiento

```bash
terraform workspace select dev
```

```bash
terraform state list
```

```bash
terraform workspace select prod
```

```bash
terraform state list
```

Al cambiar con `terraform workspace select`, Terraform apunta automaticamente al state correspondiente en S3. El `state list` en `dev` muestra `aws_s3_bucket.entorno` gestionando `mi-bucket-dev-lab3`, y en `prod` muestra el bucket `mi-bucket-prod-lab3`. Los estados son completamente independientes.

### Paso 11: Confirmar los buckets creados en LocalStack

```bash
aws --endpoint-url http://localhost:4566 s3 ls
```

Deben aparecer `mi-bucket-dev-lab3` y `mi-bucket-prod-lab3` en la lista. Cada workspace creo su propio bucket en LocalStack, demostrando que `terraform.workspace` diferencia los recursos gestionados aunque el codigo fuente sea identico.

### Paso 12: Ejecutar validacion

```bash
cd /root/lab
```

```bash
bash validate-lab.sh
```

## Criterios de Validacion

1. LocalStack S3 en estado `running`
2. Bucket `tf-state-lab3` existe (bucket de backend)
3. State del workspace `dev` existe en S3 en `env:/dev/`
4. State del workspace `prod` existe en S3 en `env:/prod/`
5. Bucket `mi-bucket-dev-lab3` creado en LocalStack
6. Bucket `mi-bucket-prod-lab3` creado en LocalStack
7. `main.tf` usa `terraform.workspace`

## Cuando usar Workspaces vs Directorios Separados

| Workspaces con S3 backend | Directorios separados |
|--------------------------|----------------------|
| Un solo bucket, rutas separadas por workspace | Buckets distintos por entorno |
| Misma config de codigo para todos los entornos | Config diferenciada por entorno |
| Cambio rapido entre entornos | Mas aislamiento y control |
| Riesgo de aplicar en el entorno equivocado | Menos riesgo de error de entorno |
| Recomendado para entornos similares | Recomendado para produccion critica |

## Conceptos Aprendidos

| Concepto | Descripcion |
|----------|-------------|
| `terraform workspace new` | Crea y selecciona un nuevo workspace |
| `terraform workspace select` | Cambia al workspace indicado |
| `terraform workspace list` | Lista todos los workspaces disponibles |
| `terraform.workspace` | Variable que devuelve el nombre del workspace activo |
| Rutas S3 por workspace | `env:/<nombre>/<key>` es la convencion del backend S3 |
| Aislamiento de state | Cada workspace tiene su propio state sin interferencias |

---

**Anterior:** [Lab 2 - State Locking](../lab2-state-locking/)
**Siguiente:** [Lab 4 - State Migration](../lab4-state-migration/)

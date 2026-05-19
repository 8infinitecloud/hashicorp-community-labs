# Lab 4: Troubleshooting

![Terraform](https://img.shields.io/badge/Terraform-Troubleshooting-7B42BC?style=flat&logo=terraform)
![LocalStack](https://img.shields.io/badge/LocalStack-AWS_Local-FF9900?style=flat)

## Objetivo

Importar infraestructura AWS pre-existente al state de Terraform usando `terraform import`, y diagnosticar ejecuciones con el sistema de logging `TF_LOG`. Estos son dos de los flujos de troubleshooting mas frecuentes en equipos reales.

## Duracion

30 minutos

## Prerrequisitos

- Labs 1, 2 y 3 del modulo 07 completados
- Terraform instalado
- Mock AWS server corriendo en el contenedor (se verifica en el Paso 1)

## Instrucciones Paso a Paso

### Paso 1: Verificar que el servidor Mock AWS esta listo

```bash
curl -sf http://localhost:4566/ > /dev/null && echo "Mock AWS server OK" || echo "No disponible aun"
```

El servidor mock debe estar activo antes de continuar. Si muestra "No disponible aun", espera unos segundos y vuelve a intentarlo.

### Paso 2: Preparar el directorio de trabajo

```bash
mkdir -p /root/lab
cd /root/lab
```

### Paso 3: Crear infraestructura FUERA de Terraform (simula infra legada)

```bash
aws --endpoint-url http://localhost:4566 s3 mb s3://bucket-legado --region us-east-1
```

```bash
aws --endpoint-url http://localhost:4566 s3api put-bucket-tagging --bucket bucket-legado --tagging 'TagSet=[{Key=Origen,Value=manual}]'
```

Esto simula un bucket que alguien creo manualmente en la consola de AWS hace meses, sin ningun codigo Terraform. Es el escenario clasico cuando una empresa decide adoptar IaC: ya tiene recursos en produccion y necesita incorporarlos a Terraform sin destruirlos ni recrearlos.

### Paso 4: Verificar que el bucket existe

```bash
aws --endpoint-url http://localhost:4566 s3 ls
```

El bucket `bucket-legado` debe aparecer en la lista. Terraform todavia no sabe nada de el.

### Paso 5: Escribir el codigo Terraform que describe el recurso existente

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

resource "aws_s3_bucket" "legado" {
  bucket        = "bucket-legado"
  force_destroy = true
}
EOF
```

El bloque `resource "aws_s3_bucket" "legado"` describe el bucket que ya existe. El nombre logico `legado` en Terraform no tiene que coincidir con el nombre fisico del bucket — el vinculo se establece durante el `import`.

### Paso 6: Inicializar Terraform

```bash
terraform init
```

### Paso 7: Ejecutar plan (muestra que quiere CREAR — todavia no importamos)

```bash
terraform plan
```

Terraform ve el bloque `aws_s3_bucket.legado` en el codigo pero no encuentra ningun registro en el state. Por eso el plan indica que quiere crear el bucket. Si ejecutaras `apply` aqui fallaria porque el bucket ya existe en LocalStack.

### Paso 8: Importar el recurso existente al state

```bash
terraform import aws_s3_bucket.legado bucket-legado
```

`terraform import` asocia el recurso real (`bucket-legado` en LocalStack) con el bloque de configuracion (`aws_s3_bucket.legado`) en el state. No modifica ni recrea el recurso — solo actualiza el archivo `terraform.tfstate`.

### Paso 9: Inspeccionar lo que se importo

```bash
terraform state show aws_s3_bucket.legado
```

El comando muestra todos los atributos del recurso tal como estan en LocalStack, ahora registrados en el state de Terraform. Esto te ayuda a verificar que el import fue exitoso y a identificar si el codigo necesita ajustes.

### Paso 10: Plan despues del import (debe mostrar cambios minimos o ninguno)

```bash
terraform plan
```

Ahora Terraform conoce el recurso. El plan puede mostrar diferencias menores entre los atributos del recurso real y los del bloque de configuracion. Revisa los cambios — si son aceptables, continua.

### Paso 11: Aplicar para reconciliar diferencias

```bash
terraform apply -auto-approve
```

`apply` alinea el estado real con el codigo. El bucket no se destruye ni se recrea — Terraform solo aplica las diferencias menores detectadas en el plan.

### Paso 12: Habilitar logging de debug

```bash
export TF_LOG=DEBUG
```

```bash
export TF_LOG_PATH=/root/lab/terraform-debug.log
```

`TF_LOG=DEBUG` activa el modo verbose de Terraform. `TF_LOG_PATH` redirige los logs a un archivo en lugar de stderr, lo cual es esencial en CI/CD para guardar evidencia de ejecuciones y diagnosticar fallos.

### Paso 13: Ejecutar plan para generar el log de debug

```bash
terraform plan
```

Terraform escribe los logs en `/root/lab/terraform-debug.log` mientras ejecuta el plan. El log incluye informacion sobre la inicializacion del provider, llamadas HTTP a LocalStack, y la resolucion de dependencias.

### Paso 14: Inspeccionar el log generado

```bash
head -50 /root/lab/terraform-debug.log
```

Las primeras lineas del log muestran la version de Terraform, el sistema operativo y el inicio del provider de AWS. Mas adelante encontraras las llamadas API con sus request y response completos — informacion invaluable para diagnosticar errores de autenticacion o permisos.

### Paso 15: Desactivar el logging

```bash
unset TF_LOG TF_LOG_PATH
```

Desactiva las variables de entorno para que ejecuciones futuras no generen logs de debug. En produccion, mantener `TF_LOG=DEBUG` activo de forma permanente genera archivos muy grandes.

### Paso 16: Ejecutar validacion

```bash
cd /root/lab
```

```bash
bash validate-lab.sh
```

## Conceptos Aprendidos

| Concepto | Descripcion |
|---|---|
| `terraform import` | Incorpora un recurso existente al state sin destruirlo ni recrearlo |
| Infra legada | Recursos creados antes de adoptar IaC que deben incorporarse gradualmente |
| `terraform state show` | Muestra los atributos de un recurso tal como estan registrados en el state |
| `TF_LOG` | Variable de entorno para activar logging verbose (TRACE/DEBUG/INFO/WARN/ERROR) |
| `TF_LOG_PATH` | Redirige los logs de Terraform a un archivo en lugar de stderr |

---

**Anterior:** [Lab 3 - Drift Detection](../lab3-drift-detection/)
**Siguiente:** [Modulo 08 - HCP Terraform](../../08-hcp-terraform/)

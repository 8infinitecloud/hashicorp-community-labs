# Lab 2: State Locking

![Terraform](https://img.shields.io/badge/Terraform-State_Locking-7B42BC?style=flat&logo=terraform)

## Objetivo

Entender el mecanismo de locking del state de Terraform: como se adquiere, que estructura tiene, como se libera forzosamente, y como se configura con DynamoDB en un backend S3 real.

## Duracion

25 minutos

## Prerrequisitos

- Lab 1 del modulo 06 completado
- Terraform instalado (`terraform version` >= 1.0)

## Instrucciones Paso a Paso

### Paso 1: Preparar el directorio de trabajo

```bash
cd /root/lab
```

### Paso 2: Crear main.tf

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

variable "entorno" {
  type    = string
  default = "dev"
}

resource "local_file" "config" {
  filename = "${path.module}/config-${var.entorno}.txt"
  content  = "entorno=${var.entorno}\n"
}

output "archivo" {
  value = local_file.config.filename
}
EOF
```

`main.tf` crea un archivo cuyo nombre incluye la variable `entorno`. Al aplicar con distintos valores de `entorno` se generan archivos distintos, lo que permite ver como el state se actualiza sin recrear recursos innecesariamente.

### Paso 3: Inicializar y aplicar

```bash
terraform init
```

```bash
terraform apply -auto-approve
```

Terraform inicializa el provider local y aplica la configuracion. El state resultante `terraform.tfstate` refleja el recurso creado.

### Paso 4: Inspeccionar el lock file de providers

```bash
cat .terraform.lock.hcl
```

`.terraform.lock.hcl` es el lock file de versiones de providers, diferente al lock de operaciones. Fija los hashes exactos del provider descargado para garantizar reproducibilidad entre equipos.

### Paso 5: Simular un lock activo de operacion

```bash
touch .terraform.tfstate.lock.info
```

```bash
cat > .terraform.tfstate.lock.info <<'EOF'
{
  "ID": "abc123-def456-ghi789",
  "Operation": "OperationTypeApply",
  "Info": "",
  "Who": "usuario@maquina",
  "Version": "1.7.0",
  "Created": "2026-05-17T10:00:00Z",
  "Path": "terraform.tfstate"
}
EOF
```

Durante un `terraform apply` real con backend local, Terraform crea este archivo JSON. Mientras existe, cualquier otro comando que necesite escribir el state fallara con "Error acquiring the state lock". El campo `ID` es el identificador unico del lock.

### Paso 6: Leer el lock info

```bash
cat .terraform.tfstate.lock.info
```

El campo `Who` identifica que usuario y maquina tomaron el lock. `Operation` indica que tipo de operacion lo adquirio. `Created` permite saber si el lock es reciente o es un lock huerfano de un proceso que ya termino.

### Paso 7: Crear la referencia de backend con locking DynamoDB

```bash
touch backend-con-locking.tf.referencia
```

```bash
cat > backend-con-locking.tf.referencia <<'EOF'
# REFERENCIA: backend S3 + DynamoDB locking
# No ejecutar en este lab — requiere credenciales AWS reales

terraform {
  backend "s3" {
    bucket         = "mi-empresa-state"
    key            = "app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# La tabla DynamoDB debe tener:
# - Partition key: LockID (tipo String)
# - Billing mode: PAY_PER_REQUEST
EOF
```

En un backend S3 real, `dynamodb_table` reemplaza al archivo `.terraform.tfstate.lock.info`. Terraform escribe un item en DynamoDB al iniciar cualquier operacion de escritura. Si el item ya existe, la operacion falla con un error de lock, protegiendo el state de escrituras concurrentes.

### Paso 8: Documentar el flujo de locking

```bash
touch flujo-locking.md
```

```bash
cat > flujo-locking.md <<'EOF'
# Flujo de Locking en Terraform

## Secuencia normal de apply
1. `terraform apply` inicia
2. Terraform adquiere el lock (escribe en DynamoDB o crea .lock.info)
3. Ejecuta el plan y aplica los cambios
4. Libera el lock al terminar (borra el registro)

## Cuando otro usuario intenta apply simultaneo
1. Usuario B ejecuta `terraform apply`
2. Terraform detecta el lock activo
3. Error: "Error acquiring the state lock"
4. Usuario B debe esperar o contactar a Usuario A

## Cuando usar force-unlock
- Solo cuando el proceso que creo el lock ya NO existe
- El proceso crasheo o la terminal se cerro accidentalmente
- NUNCA forzar unlock mientras otro apply este corriendo

## Comando para liberar un lock huerfano
terraform force-unlock <LOCK_ID>

## Backend local vs S3
- Local: archivo .terraform.tfstate.lock.info en disco
- S3:    item en tabla DynamoDB con clave LockID
EOF
```

`flujo-locking.md` sirve como referencia para el equipo. Documentar cuando es seguro usar `force-unlock` es critico porque ejecutarlo mientras hay un apply activo puede corromper el state.

### Paso 9: Liberar el lock simulado

```bash
rm .terraform.tfstate.lock.info
```

```bash
echo "Lock liberado correctamente"
```

Eliminar el archivo `.terraform.tfstate.lock.info` es el equivalente local de lo que hace `terraform force-unlock`. En un backend S3 real, `force-unlock` borra el item de DynamoDB usando el ID del lock.

### Paso 10: Aplicar con variable diferente para confirmar que el lock no interfiere

```bash
terraform apply -var="entorno=staging" -auto-approve
```

```bash
terraform state list
```

Con el lock liberado, el apply funciona normalmente. El state ahora refleja el archivo `config-staging.txt`. `terraform state list` confirma que el recurso esta gestionado correctamente.

### Paso 11: Ejecutar validacion

```bash
cd /root/lab && bash validate-lab.sh
```

## Criterios de Validacion

1. Terraform inicializado (`.terraform/` presente)
2. `terraform.tfstate` existe con recursos
3. `flujo-locking.md` creado y contiene la palabra "lock"
4. Referencia de backend con DynamoDB creada
5. `main.tf` usa `local_file`
6. No queda un lock activo (`.terraform.tfstate.lock.info` no existe)

## Conceptos Aprendidos

- Que es y para que sirve el state locking
- Como Terraform implementa locking con DynamoDB en S3
- Estructura del lock info (ID, Operation, Who, Created)
- Cuando y como usar `force-unlock` de forma segura
- Diferencia entre lock de providers (`.terraform.lock.hcl`) y lock de operaciones

---

**Anterior:** [Lab 1 - Remote State](../lab1-remote-state/)
**Siguiente:** [Lab 3 - Workspaces](../lab3-workspaces/)

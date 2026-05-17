# Lab 2: State Locking

![Terraform](https://img.shields.io/badge/Terraform-State_Locking-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Entender el mecanismo de locking del state para evitar conflictos cuando múltiples personas trabajan con la misma infraestructura.

## ⏱️ Duración
25 minutos

## 📋 Prerrequisitos
- ✅ Lab 1 del módulo 06 completado
- Terraform instalado

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear el Proyecto Base

```bash
mkdir lab2-state-locking
cd lab2-state-locking
```

Crea `main.tf`:

```hcl
terraform {
  required_version = ">= 1.0"
}

variable "entorno" {
  type    = string
  default = "dev"
}

resource "local_file" "config" {
  filename = "${path.module}/config-${var.entorno}.txt"
  content  = "entorno=${var.entorno}\ntimestamp=${timestamp()}\n"
}

output "archivo" { value = local_file.config.filename }
```

```bash
terraform init
terraform apply -auto-approve
```

### Paso 2: Observar el Lock File Local

```bash
# Terraform crea un .terraform.lock.hcl para versiones de providers
cat .terraform.lock.hcl

# Durante un apply, Terraform crea un lock en el backend
# Con backend local: archivo .terraform.tfstate.lock.info
# Con backend S3: registro en DynamoDB
```

### Paso 3: Simular un Lock Activo

```bash
# Simula el archivo de lock que crea Terraform durante apply
cat > .terraform.tfstate.lock.info << 'EOF'
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

echo "Lock simulado creado."
cat .terraform.tfstate.lock.info
```

### Paso 4: Entender el Backend S3 con DynamoDB Locking

Crea `backend-con-locking.tf.referencia`:

```hcl
# REFERENCIA: S3 + DynamoDB locking
# Requiere AWS — estudia la estructura

terraform {
  backend "s3" {
    bucket         = "mi-empresa-state"
    key            = "app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"   # ← tabla de locking
  }
}

# La tabla DynamoDB debe existir con:
# - Partition key: LockID (String)
# - Billing: PAY_PER_REQUEST
```

```bash
cat > backend-con-locking.tf.referencia << 'EOF'
terraform {
  backend "s3" {
    bucket         = "mi-empresa-state"
    key            = "app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
EOF
cat backend-con-locking.tf.referencia
```

### Paso 5: Forzar Liberación de un Lock

```bash
# Ver el ID del lock actual
cat .terraform.tfstate.lock.info

# En caso real donde el lock quedó huérfano:
# terraform force-unlock <LOCK_ID>
# Ejemplo:
# terraform force-unlock abc123-def456-ghi789

# Para este lab, simula el comando
echo "Comando: terraform force-unlock abc123-def456-ghi789"
echo "Este comando solo debe usarse cuando el proceso que creó el lock ya no existe"

# Limpiar el lock simulado
rm .terraform.tfstate.lock.info
echo "Lock liberado"
```

### Paso 6: Aplicar Normalmente (sin lock)

```bash
# Ahora apply funciona sin conflicto
terraform apply -var="entorno=staging" -auto-approve
terraform state list
```

### Paso 7: Documentar el Flujo de Locking

```bash
cat > flujo-locking.md << 'EOF'
# Flujo de Locking en Terraform

## Secuencia Normal
1. `terraform apply` inicia
2. Terraform adquiere el lock (escribe en DynamoDB)
3. Ejecuta los cambios
4. Libera el lock al terminar

## Cuando Otro Usuario Intenta Apply Simultáneo
1. Usuario B ejecuta `terraform apply`
2. Terraform detecta el lock activo
3. Error: "Error acquiring the state lock"
4. Usuario B debe esperar o contactar a Usuario A

## Cuándo Usar force-unlock
- Solo cuando el proceso que creó el lock ya NO existe
- Proceso crasheó / terminal cerrada accidentalmente
- Nunca forzar unlock mientras otro apply esté corriendo

## Verificar Lock Activo
- Backend S3: consultar tabla DynamoDB
- Backend local: buscar archivo .terraform.tfstate.lock.info
EOF

cat flujo-locking.md
```

### Paso 8: Ejecutar Validación

```bash
./validate-lab.sh
```

## ✅ Criterios de Validación

1. ✅ Proyecto aplicado con state local
2. ✅ Lock simulado creado e inspeccionado
3. ✅ Configuración de DynamoDB locking documentada
4. ✅ Flujo de locking comprendido
5. ✅ Lock liberado correctamente

## 🔧 Troubleshooting

### Error: "Error acquiring the state lock"

```
Significa que otro proceso tiene el lock activo.
Opciones:
1. Esperar a que termine
2. Si el proceso no existe: terraform force-unlock <ID>
```

### Lock huérfano en DynamoDB

```bash
# Listar locks activos (requiere AWS CLI)
# aws dynamodb scan --table-name terraform-locks

# Forzar unlock
# terraform force-unlock <LOCK_ID>
```

## 🎓 Conceptos Aprendidos

- ✅ Qué es y para qué sirve el state locking
- ✅ Cómo Terraform implementa locking con DynamoDB
- ✅ Estructura del lock info
- ✅ Cuándo y cómo usar `force-unlock`
- ✅ Buenas prácticas para evitar conflictos de state

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform State Locking Badge**

---

**Anterior:** [Lab 1 - Remote State](../lab1-remote-state/)
**Siguiente:** [Lab 3 - Workspaces](../lab3-workspaces/)

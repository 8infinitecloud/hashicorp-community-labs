# Lab Terraform: Deploy Básico en AWS

![Terraform](https://img.shields.io/badge/Terraform-Practitioner-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Crear un bucket S3 y una instancia EC2 básica usando Terraform, aprendiendo los fundamentos de Infrastructure as Code.

## ⏱️ Duración
10-15 minutos

## 📋 Prerrequisitos
- AWS CLI configurado con credenciales válidas
- Terraform instalado (versión 1.0+)
- Permisos AWS para crear S3 buckets y EC2 instances

## 🚀 Instrucciones Paso a Paso

### Paso 1: Configurar el entorno
```bash
# Configurar región AWS
export AWS_REGION=us-east-1

# Generar nombre único para el bucket
export TF_VAR_bucket_name="hashicorp-lab-$(whoami)-$(date +%s)"

# Verificar credenciales AWS
aws sts get-caller-identity
```

### Paso 2: Inicializar Terraform
```bash
# Inicializar el directorio de trabajo
terraform init

# Verificar la configuración
terraform fmt
terraform validate
```

### Paso 3: Planificar el deployment
```bash
# Ver qué recursos se van a crear
terraform plan

# Guardar el plan (opcional)
terraform plan -out=tfplan
```

### Paso 4: Aplicar la configuración
```bash
# Crear los recursos
terraform apply -auto-approve

# O usar el plan guardado
# terraform apply tfplan
```

### Paso 5: Verificar los recursos creados
```bash
# Ver los outputs
terraform output

# Verificar en AWS CLI
aws s3 ls | grep $(terraform output -raw bucket_name)
aws ec2 describe-instances --instance-ids $(terraform output -raw instance_id)
```

### Paso 6: Ejecutar validación del laboratorio
```bash
# Ejecutar script de validación
./validate-lab.sh
```

### Paso 7: Limpiar recursos
```bash
# Destruir todos los recursos
terraform destroy -auto-approve

# Verificar que se eliminaron
aws s3 ls | grep $(terraform output -raw bucket_name) || echo "Bucket eliminado"
```

## ✅ Criterios de Validación
Para obtener el badge, el laboratorio debe cumplir:

1. **Terraform funcional**: `terraform validate` pasa sin errores
2. **Recursos creados**: Bucket S3 y EC2 instance existen en AWS
3. **Outputs correctos**: Los outputs muestran ARN del bucket e ID de instancia
4. **Estado consistente**: `terraform plan` no muestra cambios después del apply
5. **Limpieza exitosa**: Los recursos se destruyen correctamente

## 🏆 Badge: Terraform Practitioner
Al completar exitosamente este laboratorio, obtienes el badge **Terraform Practitioner** que certifica que puedes:
- Escribir configuraciones básicas de Terraform
- Gestionar el ciclo de vida de recursos en AWS
- Usar variables y outputs
- Aplicar buenas prácticas de IaC

## 🔧 Troubleshooting
- **Error de credenciales**: Verificar `aws configure list`
- **Bucket ya existe**: Cambiar el nombre del bucket
- **Permisos insuficientes**: Verificar políticas IAM
- **Región incorrecta**: Verificar variable AWS_REGION

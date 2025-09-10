# Lab Terraform: Deploy Básico en AWS

![Terraform](https://img.shields.io/badge/Terraform-Practitioner-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Crear un bucket S3 y una instancia EC2 básica usando Terraform.

## ⏱️ Duración
10-15 minutos

## 📋 Prerrequisitos
- AWS CLI configurado
- Terraform instalado
- Credenciales AWS válidas

## 🚀 Instrucciones

1. **Configurar variables**:
   ```bash
   export AWS_REGION=us-east-1
   export TF_VAR_bucket_name="mi-bucket-$(date +%s)"
   ```

2. **Inicializar Terraform**:
   ```bash
   terraform init
   ```

3. **Planificar el deploy**:
   ```bash
   terraform plan
   ```

4. **Aplicar la configuración**:
   ```bash
   terraform apply -auto-approve
   ```

5. **Verificar recursos**:
   ```bash
   terraform output
   ```

6. **Limpiar recursos**:
   ```bash
   terraform destroy -auto-approve
   ```

## ✅ Validación
El laboratorio se considera completado cuando:
- El bucket S3 se crea exitosamente
- La instancia EC2 está en estado "running"
- Los outputs muestran los recursos creados

## 🏆 Badge
Al completar este lab, obtienes el badge **Terraform Practitioner**.

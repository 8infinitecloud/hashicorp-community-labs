# Módulo 6: State Management

![Terraform](https://img.shields.io/badge/Terraform-State-7B42BC?style=for-the-badge&logo=terraform)

## 📚 Descripción del Módulo

Gestión avanzada del state de Terraform: backends remotos, locking, workspaces y colaboración en equipo.

## ⏱️ Duración Total
Aproximadamente 2 horas (4 labs)

## 🎯 Objetivos de Aprendizaje

- ✅ Configurar backends remotos (S3, Terraform Cloud)
- ✅ Implementar state locking
- ✅ Usar workspaces para múltiples entornos
- ✅ Migrar state entre backends
- ✅ Importar recursos existentes
- ✅ Colaborar en equipo con state compartido

## 🧪 Laboratorios

### [Lab 1: Remote State con S3](./lab1-remote-state/)
**Duración:** 30 minutos  
**Badge:** 🏆 Terraform Remote State Expert

### [Lab 2: State Locking y Colaboración](./lab2-state-locking/)
**Duración:** 30 minutos  
**Badge:** 🏆 Terraform State Locking Master

### [Lab 3: Workspaces](./lab3-workspaces/)
**Duración:** 30 minutos  
**Badge:** 🏆 Terraform Workspaces Expert

### [Lab 4: State Migration e Import](./lab4-state-migration/)
**Duración:** 30 minutos  
**Badge:** 🏆 Terraform State Migration Pro

## 🎓 Conceptos Clave

### Backend Remoto S3

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### Workspaces

```bash
# Crear workspace
terraform workspace new dev

# Listar workspaces
terraform workspace list

# Cambiar workspace
terraform workspace select prod

# Usar en código
resource "aws_instance" "web" {
  tags = {
    Environment = terraform.workspace
  }
}
```

### Importar Recursos

```bash
# Importar recurso existente
terraform import aws_instance.web i-1234567890abcdef0

# Ver state
terraform state list
terraform state show aws_instance.web
```

## 🏆 Badge del Módulo
🎖️ **Terraform State Management Complete**

---

**Siguiente:** [Módulo 7 - Maintain Infrastructure](../07-maintain-infrastructure/)

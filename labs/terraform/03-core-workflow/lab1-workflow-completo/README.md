# Lab 1: Workflow Completo con AWS

![Terraform](https://img.shields.io/badge/Terraform-Workflow-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Ejecutar el workflow completo de Terraform creando infraestructura real en AWS.

## ⏱️ Duración
45 minutos

## 📋 Prerrequisitos
- ✅ Módulos 1 y 2 completados
- Cuenta de AWS (Free Tier)
- AWS CLI configurado con credenciales
- Terraform instalado

## ⚠️ Advertencia Importante

Este lab crea recursos reales en AWS. Aunque usa Free Tier:
- Puede generar costos mínimos si se deja corriendo
- **IMPORTANTE:** Ejecuta `terraform destroy` al finalizar
- Verifica en AWS Console que los recursos se eliminaron

## 🚀 Instrucciones Paso a Paso

### Paso 1: Verificar Credenciales AWS

```bash
# Verificar que AWS CLI está configurado
aws sts get-caller-identity

# Debe mostrar tu Account ID, User ID y ARN
# Si falla, configura con: aws configure
```

### Paso 2: Crear el Directorio del Proyecto

```bash
mkdir lab3-workflow
cd lab3-workflow
```

### Paso 3: Crear el Archivo main.tf

```hcl
# main.tf - Infraestructura web simple en AWS

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
  region = "us-east-1"
  
  default_tags {
    tags = {
      Project     = "TerraformBootcamp"
      Environment = "lab"
      ManagedBy   = "Terraform"
      Country     = "Peru"
    }
  }
}

# Security Group para permitir HTTP
resource "aws_security_group" "web" {
  name        = "lab3-web-sg"
  description = "Security group para servidor web"
  
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "lab3-web-sg"
  }
}

# Instancia EC2 con servidor web
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
  instance_type = "t2.micro"  # Free tier eligible
  
  vpc_security_group_ids = [aws_security_group.web.id]
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              
              cat > /var/www/html/index.html << 'HTML'
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Peru HUG - Terraform Lab</title>
                  <style>
                      body {
                          font-family: Arial, sans-serif;
                          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                          color: white;
                          display: flex;
                          justify-content: center;
                          align-items: center;
                          height: 100vh;
                          margin: 0;
                      }
                      .container {
                          text-align: center;
                          background: rgba(0,0,0,0.3);
                          padding: 3rem;
                          border-radius: 10px;
                      }
                      h1 { font-size: 3rem; margin: 0; }
                      p { font-size: 1.5rem; }
                  </style>
              </head>
              <body>
                  <div class="container">
                      <h1>🚀 Terraform Lab 3</h1>
                      <p>Servidor desplegado con Terraform</p>
                      <p>Peru HUG Bootcamp</p>
                  </div>
              </body>
              </html>
              HTML
              EOF
  
  tags = {
    Name = "lab3-web-server"
  }
}

# Outputs
output "instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "IP pública de la instancia"
  value       = aws_instance.web.public_ip
}

output "security_group_id" {
  description = "ID del security group"
  value       = aws_security_group.web.id
}

output "web_url" {
  description = "URL del servidor web"
  value       = "http://${aws_instance.web.public_ip}"
}
```

### Paso 4: WRITE - Revisar la Configuración

```bash
# Ver el contenido del archivo
cat main.tf

# Verificar sintaxis básica
terraform fmt -check
```

### Paso 5: INIT - Inicializar

```bash
# Inicializar el directorio de trabajo
terraform init

# Observa:
# - Descarga del provider AWS
# - Creación de .terraform/
# - Creación de .terraform.lock.hcl

# Ver providers instalados
terraform providers
```

### Paso 6: VALIDATE - Validar

```bash
# Validar la configuración
terraform validate

# Output esperado:
# Success! The configuration is valid.
```

### Paso 7: FORMAT - Formatear

```bash
# Formatear el código
terraform fmt

# Verificar formato
terraform fmt -check
```

### Paso 8: PLAN - Planear

```bash
# Ver qué se va a crear
terraform plan

# Observa la salida:
# Plan: 2 to add, 0 to change, 0 to destroy.
# 
# + aws_security_group.web
# + aws_instance.web

# Guardar el plan
terraform plan -out=tfplan

# Revisar plan guardado
terraform show tfplan
```

### Paso 9: APPLY - Aplicar

```bash
# Aplicar el plan guardado
terraform apply tfplan

# O aplicar directamente (con confirmación)
# terraform apply

# Espera ~1-2 minutos mientras se crea la infraestructura

# Output esperado:
# Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
# 
# Outputs:
# instance_id = "i-abc123..."
# public_ip = "54.123.45.67"
# security_group_id = "sg-xyz789..."
# web_url = "http://54.123.45.67"
```

### Paso 10: VERIFY - Verificar

```bash
# Ver el estado
terraform show

# Ver outputs
terraform output

# Ver URL del servidor
terraform output web_url

# Probar el servidor web (espera 1-2 minutos para que inicie)
curl $(terraform output -raw web_url)

# O abre en el navegador
open $(terraform output -raw web_url)  # macOS
xdg-open $(terraform output -raw web_url)  # Linux
```

### Paso 11: MODIFY - Modificar

Edita `main.tf` y cambia el `instance_type`:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.small"  # Cambiar de t2.micro a t2.small
  # ...
}
```

Luego:

```bash
# Ver las diferencias
terraform plan

# Output:
# ~ aws_instance.web will be updated in-place
#   ~ instance_type = "t2.micro" -> "t2.small"

# Aplicar el cambio
terraform apply -auto-approve

# Verificar el cambio
terraform state show aws_instance.web | grep instance_type
```

### Paso 12: INSPECT - Inspeccionar

```bash
# Listar recursos
terraform state list

# Output:
# aws_instance.web
# aws_security_group.web

# Ver detalles de un recurso
terraform state show aws_instance.web

# Ver el grafo de dependencias
terraform graph

# Generar imagen del grafo (requiere graphviz)
terraform graph | dot -Tpng > graph.png
```

### Paso 13: DESTROY - Destruir (IMPORTANTE)

```bash
# Ver qué se va a destruir
terraform plan -destroy

# Destruir todos los recursos
terraform destroy

# Confirma con: yes

# Output:
# Destroy complete! Resources: 2 destroyed.

# Verificar que se eliminaron
terraform state list
# (debe estar vacío)
```

### Paso 14: Verificar en AWS Console

```bash
# Abrir AWS Console y verificar:
# 1. EC2 > Instances (no debe haber instancias lab3-web-server)
# 2. EC2 > Security Groups (no debe haber lab3-web-sg)

# O verificar con AWS CLI
aws ec2 describe-instances --filters "Name=tag:Name,Values=lab3-web-server"
aws ec2 describe-security-groups --filters "Name=group-name,Values=lab3-web-sg"
```

### Paso 15: Ejecutar Validación

```bash
cd ..
./validate-lab.sh
```

## 📚 El Workflow Completo

```
1. WRITE     → Escribir configuración (.tf)
2. INIT      → Inicializar providers
3. VALIDATE  → Validar sintaxis
4. FORMAT    → Formatear código
5. PLAN      → Ver cambios
6. APPLY     → Crear infraestructura
7. VERIFY    → Verificar recursos
8. MODIFY    → Hacer cambios
9. PLAN      → Ver diferencias
10. APPLY    → Aplicar cambios
11. INSPECT  → Inspeccionar state
12. DESTROY  → Limpiar recursos
```

## 🔧 Comandos del Workflow

| Fase | Comando | Descripción |
|------|---------|-------------|
| Write | - | Editar archivos `.tf` |
| Init | `terraform init` | Inicializar |
| Validate | `terraform validate` | Validar sintaxis |
| Format | `terraform fmt` | Formatear código |
| Plan | `terraform plan` | Ver cambios |
| Apply | `terraform apply` | Aplicar cambios |
| Show | `terraform show` | Ver state |
| Output | `terraform output` | Ver outputs |
| Destroy | `terraform destroy` | Destruir todo |

## 💡 Mejores Prácticas

1. **Siempre planea antes de aplicar**
   ```bash
   terraform plan
   terraform apply
   ```

2. **Guarda planes para revisión**
   ```bash
   terraform plan -out=tfplan
   terraform show tfplan
   terraform apply tfplan
   ```

3. **Usa auto-approve solo en desarrollo**
   ```bash
   # Desarrollo
   terraform apply -auto-approve
   
   # Producción
   terraform apply  # Requiere confirmación
   ```

4. **Destruye recursos de lab**
   ```bash
   # Siempre al terminar
   terraform destroy
   ```

## 🔧 Troubleshooting

### Error: "No valid credential sources found"

```bash
# Configurar AWS CLI
aws configure

# O usar variables de entorno
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
```

### Error: "AMI not found"

```bash
# La AMI puede variar por región
# Buscar AMI de Amazon Linux 2 en tu región:
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'Images[0].ImageId' \
  --output text
```

### El servidor web no responde

```bash
# Espera 2-3 minutos para que el user_data se ejecute
# Verifica el security group permite puerto 80
# Verifica la IP pública: terraform output public_ip
```

### Recursos no se destruyen

```bash
# Forzar destrucción
terraform destroy -auto-approve

# Verificar en AWS Console manualmente
```

## ✅ Criterios de Validación

1. ✅ Proyecto `lab3-workflow` creado
2. ✅ Archivo `main.tf` con configuración completa
3. ✅ `terraform init` ejecutado exitosamente
4. ✅ `terraform plan` muestra 2 recursos a crear
5. ✅ `terraform apply` crea infraestructura
6. ✅ Servidor web accesible en navegador
7. ✅ `terraform destroy` limpia recursos

## 🎓 Conceptos Aprendidos

- ✅ Workflow completo de Terraform
- ✅ Crear infraestructura real en AWS
- ✅ Security Groups y EC2 instances
- ✅ User data para configuración inicial
- ✅ Outputs para información útil
- ✅ Modificar recursos existentes
- ✅ Destruir infraestructura

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Workflow Master Badge**

---

**Anterior:** [Módulo 3 - Intro](../)  
**Siguiente:** [Lab 2 - Targets Incremental](../lab2-targets-incremental/)

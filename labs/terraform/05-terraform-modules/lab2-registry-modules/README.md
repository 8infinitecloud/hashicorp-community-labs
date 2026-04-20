# Lab 2: Módulos del Registry

## 🎯 Objetivo
Usar módulos públicos del Terraform Registry.

## ⏱️ Duración: 30 minutos

## 📚 Contenido

### Usar Módulo del Registry

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  
  name = "my-vpc"
  cidr = "10.0.0.0/16"
}
```

### Buscar Módulos
- [Terraform Registry](https://registry.terraform.io/)
- Filtrar por provider (AWS, Azure, GCP)
- Ver documentación y ejemplos

## 🏆 Badge
Terraform Registry Expert

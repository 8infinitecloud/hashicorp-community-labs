# Módulo 8: HCP Terraform (Terraform Cloud)

![Terraform](https://img.shields.io/badge/Terraform-Cloud-7B42BC?style=for-the-badge&logo=terraform)

## 📚 Descripción del Módulo

Uso de HCP Terraform (Terraform Cloud) para colaboración en equipo, CI/CD y gestión empresarial de infraestructura.

## ⏱️ Duración Total
Aproximadamente 2 horas (4 labs)

## 🎯 Objetivos de Aprendizaje

- ✅ Configurar HCP Terraform
- ✅ Crear workspaces en la nube
- ✅ Implementar VCS workflows
- ✅ Usar Sentinel policies
- ✅ Configurar remote operations
- ✅ Gestionar equipos y permisos

## 🧪 Laboratorios

### [Lab 1: Setup HCP Terraform](./lab1-hcp-setup/)
**Duración:** 30 minutos  
**Badge:** 🏆 HCP Terraform Setup Expert

### [Lab 2: VCS Workflows](./lab2-vcs-workflows/)
**Duración:** 30 minutos  
**Badge:** 🏆 Terraform VCS Integration Master

### [Lab 3: Sentinel Policies](./lab3-sentinel-policies/)
**Duración:** 30 minutos  
**Badge:** 🏆 Terraform Sentinel Expert

### [Lab 4: Team Collaboration](./lab4-team-collaboration/)
**Duración:** 30 minutos  
**Badge:** 🏆 Terraform Team Collaboration Pro

## 🎓 Conceptos Clave

### Configurar HCP Terraform

```hcl
terraform {
  cloud {
    organization = "my-org"
    
    workspaces {
      name = "my-workspace"
    }
  }
}
```

### VCS Integration

```hcl
# Conectar con GitHub
# 1. Settings > Version Control > Add VCS Provider
# 2. Authorize GitHub
# 3. Select repository
# 4. Auto-trigger on commits
```

### Sentinel Policy

```hcl
# policy.sentinel
import "tfplan/v2" as tfplan

main = rule {
  all tfplan.resource_changes as _, rc {
    rc.type is "aws_instance" implies
      rc.change.after.instance_type in ["t2.micro", "t2.small"]
  }
}
```

### Remote Operations

```bash
# Login to HCP Terraform
terraform login

# Initialize with cloud backend
terraform init

# Plan runs remotely
terraform plan

# Apply runs remotely
terraform apply
```

### Variables en HCP

```hcl
# Terraform Variables
variable "instance_type" {
  type = string
}

# Environment Variables
# AWS_ACCESS_KEY_ID (sensitive)
# AWS_SECRET_ACCESS_KEY (sensitive)
```

## 🎓 Características de HCP Terraform

### Free Tier
- ✅ Hasta 5 usuarios
- ✅ State management
- ✅ Remote operations
- ✅ VCS integration
- ✅ Private module registry

### Team & Governance (Paid)
- ✅ Sentinel policies
- ✅ Team management
- ✅ SSO/SAML
- ✅ Audit logs
- ✅ Cost estimation

### Business (Paid)
- ✅ Self-hosted agents
- ✅ Concurrency
- ✅ Advanced security
- ✅ Priority support

## 💡 Mejores Prácticas

### 1. Usar Workspaces por Entorno

```
Organization: my-company
├── Workspace: app-dev
├── Workspace: app-staging
└── Workspace: app-prod
```

### 2. Variables Sensibles

```hcl
# Marcar como sensitive en HCP UI
# No commitear en código
variable "db_password" {
  type      = string
  sensitive = true
}
```

### 3. Sentinel para Compliance

```hcl
# Forzar tags obligatorios
# Limitar tipos de instancia
# Validar regiones permitidas
# Prevenir recursos costosos
```

### 4. VCS Workflow

```
1. Developer: Push to feature branch
2. HCP: Speculative plan (preview)
3. Developer: Create PR
4. HCP: Plan on PR
5. Team: Review plan
6. Merge: Auto-apply (optional)
```

## 🔧 Comandos Útiles

```bash
# Login
terraform login

# Logout
terraform logout

# Ver workspaces
terraform workspace list

# Forzar unlock (emergencia)
terraform force-unlock <lock-id>

# Ver runs
# (desde HCP UI)
```

## 📚 Recursos Adicionales

### Documentación
- [HCP Terraform Docs](https://developer.hashicorp.com/terraform/cloud-docs)
- [Sentinel Language](https://docs.hashicorp.com/sentinel)
- [VCS Integration](https://developer.hashicorp.com/terraform/cloud-docs/vcs)

### Tutoriales
- [Get Started with HCP Terraform](https://learn.hashicorp.com/collections/terraform/cloud-get-started)
- [Enforce Policy with Sentinel](https://learn.hashicorp.com/tutorials/terraform/sentinel-install)

## 🏆 Badge del Módulo
🎖️ **HCP Terraform Complete**

---

## 🎉 ¡Felicitaciones!

Al completar este módulo has terminado el **HashiCorp Terraform Bootcamp**.

### 🏆 Badges Obtenidos

- 🎖️ IaC Fundamentals Complete
- 🎖️ Terraform Fundamentals Complete
- 🎖️ Core Workflow Complete
- 🎖️ Terraform Configuration Complete
- 🎖️ Terraform Modules Complete
- 🎖️ State Management Complete
- 🎖️ Maintenance Complete
- 🎖️ HCP Terraform Complete

### 🌟 Badge Final
**🏅 TERRAFORM CERTIFIED PRACTITIONER READY**

Estás listo para el examen de certificación:
- [Terraform Associate Certification](https://www.hashicorp.com/certification/terraform-associate)

---

**¡Éxito en tu carrera con Terraform!** 🚀

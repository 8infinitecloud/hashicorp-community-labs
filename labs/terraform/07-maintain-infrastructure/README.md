# Módulo 7: Maintain Infrastructure

![Terraform](https://img.shields.io/badge/Terraform-Maintain-7B42BC?style=for-the-badge&logo=terraform)

## 📚 Descripción del Módulo

Mantenimiento y actualización de infraestructura: refactoring, upgrades, drift detection y troubleshooting avanzado.

## ⏱️ Duración Total
Aproximadamente 2 horas (4 labs)

## 🎯 Objetivos de Aprendizaje

- ✅ Refactorizar código Terraform
- ✅ Actualizar providers y módulos
- ✅ Detectar y corregir drift
- ✅ Manejar cambios destructivos
- ✅ Troubleshooting avanzado
- ✅ Estrategias de rollback

## 🧪 Laboratorios

### [Lab 1: Refactoring de Código](./lab1-refactoring/)
**Duración:** 30 minutos  
**Badge:** 🏆 Terraform Refactoring Expert

### [Lab 2: Upgrades y Migraciones](./lab2-upgrades/)
**Duración:** 30 minutos  
**Badge:** 🏆 Terraform Upgrade Master

### [Lab 3: Drift Detection](./lab3-drift-detection/)
**Duración:** 30 minutos  
**Badge:** 🏆 Terraform Drift Detective

### [Lab 4: Troubleshooting Avanzado](./lab4-troubleshooting/)
**Duración:** 30 minutos  
**Badge:** 🏆 Terraform Troubleshooting Pro

## 🎓 Conceptos Clave

### Detectar Drift

```bash
# Refresh state
terraform refresh

# Ver diferencias
terraform plan -refresh-only

# Aplicar cambios detectados
terraform apply -refresh-only
```

### Moved Blocks (Refactoring)

```hcl
# Renombrar recurso sin recrear
moved {
  from = aws_instance.web
  to   = aws_instance.web_server
}
```

### Upgrade Providers

```bash
# Ver versiones actuales
terraform version
terraform providers

# Actualizar providers
terraform init -upgrade

# Lock file
terraform providers lock
```

### Troubleshooting

```bash
# Logs detallados
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Validar configuración
terraform validate

# Ver grafo
terraform graph | dot -Tpng > graph.png
```

## 🏆 Badge del Módulo
🎖️ **Terraform Maintenance Complete**

---

**Siguiente:** [Módulo 8 - HCP Terraform](../08-hcp-terraform/)

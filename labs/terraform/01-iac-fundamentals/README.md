# Módulo 1: Infrastructure as Code Fundamentals

![Terraform](https://img.shields.io/badge/Terraform-IaC%20Fundamentals-7B42BC?style=for-the-badge&logo=terraform)

## 📚 Descripción del Módulo

Este módulo te introduce a los conceptos fundamentales de Infrastructure as Code (IaC) y Terraform. Aprenderás qué es IaC, por qué es importante, y cómo usar Terraform para gestionar infraestructura de manera declarativa.

## ⏱️ Duración Total
Aproximadamente 1 hora (3 labs de 15-30 minutos cada uno)

## 🎯 Objetivos de Aprendizaje

Al completar este módulo serás capaz de:

- ✅ Entender qué es Infrastructure as Code y sus beneficios
- ✅ Instalar y configurar Terraform en tu sistema
- ✅ Crear archivos de configuración básicos de Terraform
- ✅ Usar variables, locals y outputs
- ✅ Ejecutar el workflow básico de Terraform (init, plan, apply, destroy)
- ✅ Entender el concepto de estado en Terraform
- ✅ Aplicar principios de IaC en proyectos reales

## 📋 Prerrequisitos

- Conocimientos básicos de línea de comandos
- Editor de texto (VS Code recomendado)
- Acceso a terminal (bash, zsh, PowerShell)
- No se requiere cuenta de cloud provider

## 🧪 Laboratorios

### [Lab 1: Instalación de Terraform](./lab1-instalacion/)
**Duración:** 15 minutos  
**Objetivo:** Instalar Terraform y verificar la instalación

**Aprenderás:**
- Instalar Terraform en macOS, Linux o Windows
- Verificar la instalación
- Configurar el entorno de desarrollo
- Comandos básicos de Terraform CLI

**Badge:** 🏆 Terraform Installation

---

### [Lab 2: Tu Primer Archivo Terraform](./lab2-primer-archivo/)
**Duración:** 20 minutos  
**Objetivo:** Crear tu primera configuración de Terraform

**Aprenderás:**
- Estructura de archivos Terraform
- Bloque `terraform` y configuración
- Variables locales (`locals`)
- Outputs para mostrar información
- Comandos: `init`, `validate`, `fmt`, `plan`, `apply`
- Archivo de estado `terraform.tfstate`

**Badge:** 🏆 Terraform First Configuration

---

### [Lab 3: Simular Infraestructura Local](./lab3-infraestructura-local/)
**Duración:** 30 minutos  
**Objetivo:** Crear una infraestructura simulada usando archivos locales

**Aprenderás:**
- Variables de entrada (`variable`)
- Cálculos dinámicos con `locals`
- Recursos con `local_file`
- Interpolación de strings
- Condicionales en Terraform
- Cambiar entre ambientes (desarrollo/producción)
- Ciclo completo: init → plan → apply → destroy

**Badge:** 🏆 Terraform IaC Fundamentals

---

## 🎓 Conceptos Clave

### ¿Qué es Infrastructure as Code?

Infrastructure as Code (IaC) es la práctica de gestionar y aprovisionar infraestructura mediante código en lugar de procesos manuales.

**Beneficios:**
- 🚀 Automatización y velocidad
- 🔄 Consistencia y reproducibilidad
- 📝 Documentación como código
- 🔍 Control de versiones
- 👥 Colaboración en equipo
- 🛡️ Reducción de errores humanos

### Declarativo vs Imperativo

**Imperativo (cómo hacerlo):**
```bash
# Paso 1: Crear VPC
# Paso 2: Crear subnet
# Paso 3: Crear instancia
```

**Declarativo (qué quieres):**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345"
  instance_type = "t2.micro"
}
# Terraform se encarga de los pasos
```

### Idempotencia

Ejecutar el mismo código múltiples veces produce el mismo resultado:

```bash
terraform apply  # Crea recursos
terraform apply  # No hace nada (ya existen)
terraform apply  # Sigue sin hacer nada
```

### Estado de Terraform

Terraform mantiene un archivo de estado (`terraform.tfstate`) que:
- Mapea recursos reales a tu configuración
- Almacena metadata de recursos
- Mejora performance
- Permite trabajo en equipo

## 📊 Progreso del Módulo

Completa los 3 labs en orden:

1. ⬜ Lab 1: Instalación de Terraform
2. ⬜ Lab 2: Tu Primer Archivo Terraform
3. ⬜ Lab 3: Simular Infraestructura Local

Al completar los 3 labs obtienes: **🎖️ IaC Fundamentals Complete**

## 🔧 Comandos Terraform Esenciales

| Comando | Descripción |
|---------|-------------|
| `terraform init` | Inicializa el directorio de trabajo |
| `terraform validate` | Valida la sintaxis |
| `terraform fmt` | Formatea el código |
| `terraform plan` | Muestra cambios a aplicar |
| `terraform apply` | Aplica los cambios |
| `terraform destroy` | Destruye recursos |
| `terraform output` | Muestra outputs |
| `terraform state list` | Lista recursos en el estado |

## 📚 Recursos Adicionales

### Documentación Oficial
- [Terraform Introduction](https://www.terraform.io/intro)
- [Terraform CLI Documentation](https://www.terraform.io/cli)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)

### Comunidad
- [Terraform GitHub](https://github.com/hashicorp/terraform)
- [Terraform Discuss](https://discuss.hashicorp.com/c/terraform-core)
- [Peru HUG Community](https://www.meetup.com/peru-hug)

### Videos Recomendados
- [What is Infrastructure as Code?](https://www.youtube.com/watch?v=zWw2wuiKd5o)
- [Terraform in 100 Seconds](https://www.youtube.com/watch?v=tomUWcQ0P3k)

## 🎯 Casos de Uso Reales

### Startup Escalando
Una startup de delivery necesita:
- Ambientes idénticos (dev, staging, prod)
- Escalar de 2 a 20 servidores rápidamente
- Replicar infraestructura en múltiples regiones

**Solución:** IaC con Terraform reduce setup de 2 días a 10 minutos

### Empresa Migrando a Cloud
Banco migrando de on-premise a AWS:
- Documentar infraestructura como código
- Migración gradual y controlada
- Compliance y auditoría con Git history

**Solución:** Terraform permite migración segura con rollback capability

### Multi-Región
E-commerce con clientes en Perú, Chile y Colombia:
- Infraestructura en múltiples regiones
- Mismo código, diferentes regiones
- Reducir latencia para usuarios

**Solución:** Terraform modules para replicar infraestructura

## 🚀 Próximos Pasos

Después de completar este módulo:

1. **Módulo 2:** Terraform Fundamentals
   - Providers y recursos
   - Data sources
   - Dependencias entre recursos

2. **Módulo 3:** Core Workflow
   - Workflow completo de Terraform
   - Mejores prácticas
   - Trabajo en equipo

3. **Módulo 4:** Terraform Configuration
   - Variables avanzadas
   - Outputs complejos
   - Funciones de Terraform

## 💡 Tips para el Éxito

1. **Practica cada lab:** No solo leas, ejecuta los comandos
2. **Experimenta:** Modifica el código y ve qué pasa
3. **Lee los errores:** Los mensajes de error de Terraform son muy descriptivos
4. **Usa `terraform plan`:** Siempre revisa antes de aplicar
5. **Versiona tu código:** Usa Git desde el principio

## 🏆 Badges del Módulo

Al completar cada lab obtienes un badge:

- 🏆 **Terraform Installation** (Lab 1)
- 🏆 **Terraform First Configuration** (Lab 2)
- 🏆 **Terraform IaC Fundamentals** (Lab 3)

Al completar los 3 labs:
- 🎖️ **IaC Fundamentals Complete**

---

**¡Comienza con el Lab 1!** → [Instalación de Terraform](./lab1-instalacion/)

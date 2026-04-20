# HashiCorp Terraform Labs

![HashiCorp Terraform](https://img.shields.io/badge/HashiCorp-Terraform-7B42BC?style=for-the-badge&logo=terraform)

Laboratorios prácticos de 10-15 minutos para aprender Terraform con validación automática y sistema de badges.

## 🎯 Objetivo

Obtener experiencia práctica con Terraform a través de laboratorios validados automáticamente que otorgan badges de competencia.

## 🏆 Sistema de Badges

### Badges por Tecnología
Los badges aparecen aquí automáticamente al completar cada laboratorio:

<!-- BADGES_START -->
*Completa los laboratorios para ver tus badges aquí*
<!-- BADGES_END -->

### Badge Fundacional
<!-- FOUNDATIONAL_BADGE_START -->
*Completa todos los laboratorios para desbloquear el badge fundacional*
<!-- FOUNDATIONAL_BADGE_END -->

## 📚 Módulos y Laboratorios

### Módulo 1: IaC Fundamentals
**Duración:** 1 hora | **Labs:** 3

- **[Lab 1: Instalación de Terraform](./labs/terraform/01-iac-fundamentals/lab1-instalacion/)**
  - Instalar Terraform y verificar instalación
  - Duración: 15 minutos
  
- **[Lab 2: Tu Primer Archivo Terraform](./labs/terraform/01-iac-fundamentals/lab2-primer-archivo/)**
  - Crear primera configuración, usar outputs y locals
  - Duración: 20 minutos
  
- **[Lab 3: Infraestructura Local](./labs/terraform/01-iac-fundamentals/lab3-infraestructura-local/)**
  - Simular infraestructura con archivos locales
  - Duración: 30 minutos

### Módulo 2: Terraform Fundamentals
**Duración:** 2 horas | **Labs:** 4

- **[Lab 1: HCL y Tipos de Datos](./labs/terraform/02-terraform-fundamentals/lab1-hcl-tipos-datos/)**
  - Sintaxis HCL, variables, locals, funciones
  - Duración: 30 minutos
  
- **[Lab 2: Configurar Providers](./labs/terraform/02-terraform-fundamentals/lab2-providers/)**
  - Versionado de providers, alias, lock file
  - Duración: 25 minutos
  
- **[Lab 3: Terraform State](./labs/terraform/02-terraform-fundamentals/lab3-terraform-state/)**
  - Gestión de estado, inspección, drift detection
  - Duración: 30 minutos
  
- **[Lab 4: CLI Avanzado](./labs/terraform/02-terraform-fundamentals/lab4-cli-avanzado/)**
  - Comandos avanzados, workspaces, debugging
  - Duración: 25 minutos

### Próximos Módulos (En Desarrollo)
- 🔄 Módulo 3: Core Workflow
- ⚙️ Módulo 4: Terraform Configuration
- 📚 Módulo 5: Terraform Modules
- 💾 Módulo 6: State Management
- 🔧 Módulo 7: Maintain Infrastructure
- ☁️ Módulo 8: HCP Terraform

<!-- 
### 2. Vault - Manejo de Secretos
- **Lab**: [Secretos dinámicos](./labs/2.%20vault/dynamic-secrets/)
- **Duración**: 10-15 minutos
- **Aprenderás**: Generar credenciales dinámicas de PostgreSQL, configurar motores de DB
- **Validación**: ✅ Script automático incluido
- **Archivos**: Scripts para iniciar Vault, configurar DB engine, generar y verificar credenciales

### 3. Vault Radar - Escaneo de Secretos
- **Lab**: [Escaneo de repositorios](./labs/3.%20vault-radar/repo-scanning/)
- **Duración**: 10-15 minutos
- **Aprenderás**: Detectar secretos expuestos en código, usar Vault Radar CLI
- **Validación**: ✅ Script automático incluido
- **Archivos**: Scripts para crear repo de prueba, escanear, revisar y limpiar secretos

### 4. Nomad - Orquestación de Workloads
- **Lab**: [Deploy de contenedor](./labs/4.%20nomad/container-deploy/)
- **Duración**: 10-15 minutos
- **Aprenderás**: Desplegar aplicación web, job definitions, escalado automático
- **Validación**: ✅ Script automático incluido
- **Archivos**: `webapp.nomad`, scripts para deploy, verificación y escalado

### 5. Consul - Service Discovery
- **Lab**: [KV Store básico](./labs/5.%20consul/kv-store/)
- **Duración**: 10-15 minutos
- **Aprenderás**: Almacenar configuración distribuida, usar templates, KV operations
- **Validación**: ✅ Script automático incluido
- **Archivos**: `app-config.tpl`, scripts para setup, lectura y generación de config
-->

## 📁 Estructura del Repositorio

```
hashicorp-terraform-labs/
├── README.md                    # Documentación principal
├── .gitignore                   # Archivos ignorados por Git
├── LICENSE                      # Licencia MIT
├── CONTRIBUTING.md              # Guía de contribución
├── playbook.md                  # Playbook del proyecto
├── PROGRESS.md                  # Avances del proyecto
├── CAMBIOS.md                   # Registro de cambios
│
├── .devcontainer/               # Configuración para GitHub Codespaces
│   ├── devcontainer.json        # Configuración del contenedor
│   └── setup.sh                 # Script de configuración automática
│
├── .github/workflows/           # GitHub Actions para CI/CD
│   └── validate-labs.yml        # Validación automática de labs
│
├── scripts/                     # Scripts de utilidad
│   ├── validate-all-labs.sh     # Validación completa
│   ├── show-badges.sh           # Mostrar estado de badges
│   ├── update-github-badges.sh  # Sincronización con GitHub
│   └── update-readme-badges.sh  # Actualizar README
│
└── labs/terraform/              # Laboratorios organizados por módulo
    ├── 01-iac-fundamentals/     # Módulo 1: IaC Fundamentals
    │   ├── README.md
    │   ├── lab1-instalacion/
    │   ├── lab2-primer-archivo/
    │   └── lab3-infraestructura-local/
    ├── 02-terraform-fundamentals/
    ├── 03-core-workflow/
    ├── 04-terraform-configuration/
    ├── 05-terraform-modules/
    ├── 06-state-management/
    ├── 07-maintain-infrastructure/
    └── 08-hcp-terraform/
```

## 📊 Estado Actual del Repositorio

✅ **Estructura validada**: Laboratorios de Terraform organizados correctamente  
✅ **Scripts funcionales**: Cada lab incluye scripts de validación automática  
✅ **Documentación completa**: READMEs detallados para cada laboratorio  
✅ **CI/CD configurado**: GitHub Actions valida automáticamente los labs  
✅ **Devcontainer listo**: Entorno de desarrollo preconfigurado  

### Laboratorios Implementados
- ✅ **Terraform**: Deploy básico en AWS con S3 y EC2
<!-- 
- ✅ **Vault**: Secretos dinámicos con PostgreSQL
- ✅ **Vault Radar**: Escaneo de repositorios para detectar secretos
- ✅ **Nomad**: Deploy de aplicación web en contenedor
- ✅ **Consul**: KV Store para configuración distribuida
-->

### Próximos Pasos
- 🔄 Más laboratorios de Terraform (módulos, workspaces, remote state)
- 📚 Integración con curso de Udemy
- 🏆 Sistema de badges mejorado
- 🌐 Soporte para múltiples proveedores cloud

---

## 🚀 Inicio Rápido

### Opción 1: GitHub Codespaces (Recomendado)
1. Haz clic en "Code" → "Codespaces" → "Create codespace"
2. El entorno se configura automáticamente con todas las herramientas
3. Ejecuta `lab-help` para ver comandos disponibles
4. Navega a cualquier lab con `lab-<tecnologia>`
5. **Los badges se sincronizan automáticamente con GitHub** al completar labs

### Opción 2: Entorno Local
```bash
git clone https://github.com/tu-usuario/hashicorp-foundational-labs.git
cd hashicorp-foundational-labs

# Instalar herramientas HashiCorp según tu OS
# Ver documentación de instalación en cada lab
```

## 🎮 Cómo Completar los Labs

### Método Individual
```bash
# Navegar al laboratorio
cd "labs/1. terraform/basic-aws-deploy"

# Seguir las instrucciones del README
cat README.md

# Ejecutar los pasos del laboratorio
# ... (seguir instrucciones específicas)

# Validar y obtener badge
./validate-lab.sh
```

### Método Completo
```bash
# Validar todos los laboratorios de una vez
./scripts/validate-all-labs.sh
```

## ✅ Sistema de Validación

Cada laboratorio incluye:

1. **README detallado** con instrucciones paso a paso
2. **Scripts funcionales** para ejecutar el laboratorio
3. **Script de validación** (`validate-lab.sh`) que:
   - Verifica que completaste todos los pasos
   - Valida que los recursos funcionan correctamente
   - Otorga el badge correspondiente
   - Proporciona feedback específico

### Criterios de Validación
- ✅ Configuración correcta de herramientas
- ✅ Recursos creados y funcionando
- ✅ Outputs/resultados esperados
- ✅ Buenas prácticas implementadas
- ✅ Limpieza exitosa de recursos

## 🔧 Prerrequisitos

### Herramientas Base
- Git
- AWS CLI configurado con credenciales válidas
- Terraform instalado (versión 1.0+)

### Para GitHub Codespaces
- Todo preconfigurado automáticamente
- Solo necesitas una cuenta de AWS con credenciales

## 📖 Curso Complementario

Curso gratuito de 1 hora en Udemy: [HashiCorp Terraform Foundational](link-pendiente)

El curso incluye:
- Introducción a Terraform
- Demos de cada laboratorio
- Explicación de conceptos clave de IaC
- Guía para obtener badges

## 🏅 Obtener tus Badges

### Sistema de Badges Automático
Cada laboratorio genera automáticamente un badge al completarse exitosamente:

1. **Completa cada laboratorio** siguiendo las instrucciones
2. **Ejecuta el script de validación** en cada lab (`./validate-lab.sh`)
3. **Badge generado automáticamente** con timestamp de completación
4. **Sincronización con GitHub**: En Codespaces, los badges se commitean automáticamente
5. **Verifica tu progreso** con `./show-badges.sh`
6. **Obtén el badge fundacional** al completar todos los labs

### 🔄 Integración con GitHub Codespaces
- **Detección automática**: El sistema detecta si estás en un Codespace
- **Commit automático**: Los badges se commitean automáticamente al repositorio
- **Estado persistente**: Tus badges se mantienen entre sesiones
- **Archivo de estado**: `badge-status.json` rastrea todos los badges obtenidos

### Badges Disponibles
- 🏆 **Terraform Practitioner** - Deploy básico en AWS
<!-- 
- 🏆 **Vault Practitioner** - Secretos dinámicos
- 🏆 **Vault Radar Practitioner** - Escaneo de secretos
- 🏆 **Nomad Practitioner** - Orquestación de contenedores
- 🏆 **Consul Practitioner** - Service discovery y KV store
-->
- 🎖️ **HashiCorp Foundational Complete** - Badge fundacional (todos los labs de Terraform)

### Comandos Útiles
```bash
# Ver estado de badges
./scripts/show-badges.sh

# Validar todos los labs y generar badges
./scripts/validate-all-labs.sh

# Validar lab individual
cd "labs/1. terraform/basic-aws-deploy" && ./validate-lab.sh
```

## 🤝 Contribuir

¿Quieres mejorar los laboratorios o agregar nuevos?

1. Lee nuestra [Guía de Contribución](CONTRIBUTING.md)
2. Fork el repositorio
3. Crea tu feature branch
4. Envía un Pull Request

## 🔍 Troubleshooting

### Problemas Comunes
- **Scripts no ejecutables**: `chmod +x *.sh`
- **Puertos ocupados**: Cambiar puertos en configuración
- **Docker no responde**: `docker ps` y reiniciar si es necesario
- **Credenciales AWS**: `aws configure list`

### Obtener Ayuda
- Revisa el README específico de cada lab
- Consulta la sección de troubleshooting en cada lab
- Abre un issue en GitHub con detalles del problema

## 📊 Progreso y Estadísticas

```bash
# Ver tu progreso actual
./scripts/show-badges.sh

# Validar todos los labs y generar badges
./scripts/validate-all-labs.sh

# Ver badges obtenidos
find . -name ".badge-*-earned" -exec basename {} \; | sort

# Verificar badge fundacional
ls -la .foundational-badge-earned 2>/dev/null && echo "🏆 Badge Fundacional Obtenido!"
```

## 📄 Licencia

MIT License - ver [LICENSE](LICENSE) para detalles.

---

**¡Comienza tu journey con Terraform hoy mismo!** 🚀

Cada laboratorio te llevará solo 10-15 minutos y al final tendrás competencias validadas en Terraform, la herramienta líder de Infrastructure as Code.

---

*Última actualización: Abril 2026*

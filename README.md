# HashiCorp Foundational Labs

![HashiCorp Foundational](https://img.shields.io/badge/HashiCorp-Foundational-623CE4?style=for-the-badge&logo=hashicorp)

Laboratorios prácticos de 10-15 minutos para aprender los fundamentos del ecosistema HashiCorp con validación automática y sistema de badges.

## 🎯 Objetivo

Obtener experiencia práctica con las herramientas principales de HashiCorp a través de laboratorios validados automáticamente que otorgan badges de competencia.

## 🏆 Sistema de Badges

### Badges por Tecnología
- ![Terraform Practitioner](https://img.shields.io/badge/Terraform-Practitioner-7B42BC?style=flat&logo=terraform)
- ![Vault Practitioner](https://img.shields.io/badge/Vault-Practitioner-FFD814?style=flat&logo=vault)
- ![Nomad Practitioner](https://img.shields.io/badge/Nomad-Practitioner-00CA8E?style=flat&logo=nomad)
- ![Consul Practitioner](https://img.shields.io/badge/Consul-Practitioner-F24C53?style=flat&logo=consul)
- ![Vault Radar Practitioner](https://img.shields.io/badge/Vault%20Radar-Practitioner-FFD814?style=flat&logo=vault)

### Badge Fundacional
![HashiCorp Foundational](https://img.shields.io/badge/HashiCorp-Foundational%20Complete-623CE4?style=for-the-badge&logo=hashicorp)

*Se otorga al completar exitosamente todos los laboratorios*

## 📚 Laboratorios Disponibles

### 1. Terraform - Infraestructura como Código
- **Lab**: [Deploy básico en AWS](./labs/1.%20terraform/basic-aws-deploy/)
- **Duración**: 10-15 minutos
- **Aprenderás**: Crear bucket S3 e instancia EC2, gestionar estado, usar variables y outputs
- **Validación**: ✅ Script automático incluido
- **Archivos**: `main.tf`, `variables.tf`, `outputs.tf`, `validate-lab.sh`

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

## 📁 Estructura del Repositorio

```
hashicorp-foundational-labs/
├── README.md                    # Este archivo
├── LICENSE                      # Licencia MIT
├── CONTRIBUTING.md              # Guía de contribución
├── playbook.md                  # Playbook del proyecto
├── validate-all-labs.sh         # Script de validación completa
├── .devcontainer/               # Configuración para GitHub Codespaces
│   ├── devcontainer.json        # Configuración del contenedor
│   └── setup.sh                 # Script de configuración automática
├── .github/workflows/           # GitHub Actions para CI/CD
│   └── validate-labs.yml        # Validación automática de labs
├── .vscode/                     # Configuración de VS Code
│   └── settings.json            # Configuraciones del editor
└── labs/                        # Laboratorios organizados por tecnología
    ├── 1. terraform/
    │   └── basic-aws-deploy/    # Lab de Terraform
    ├── 2. vault/
    │   └── dynamic-secrets/     # Lab de Vault
    ├── 3. vault-radar/
    │   └── repo-scanning/       # Lab de Vault Radar
    ├── 4. nomad/
    │   └── container-deploy/    # Lab de Nomad
    └── 5. consul/
        └── kv-store/            # Lab de Consul
```

## 📊 Estado Actual del Repositorio

✅ **Estructura validada**: Todos los laboratorios están organizados correctamente  
✅ **Scripts funcionales**: Cada lab incluye scripts de validación automática  
✅ **Documentación completa**: READMEs detallados para cada laboratorio  
✅ **CI/CD configurado**: GitHub Actions valida automáticamente los labs  
✅ **Devcontainer listo**: Entorno de desarrollo preconfigurado  

### Laboratorios Implementados
- ✅ **Terraform**: Deploy básico en AWS con S3 y EC2
- ✅ **Vault**: Secretos dinámicos con PostgreSQL
- ✅ **Vault Radar**: Escaneo de repositorios para detectar secretos
- ✅ **Nomad**: Deploy de aplicación web en contenedor
- ✅ **Consul**: KV Store para configuración distribuida

### Próximos Pasos
- 🔄 Actualización continua de contenido
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
./validate-all-labs.sh
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
- Docker
- Curl/wget

### Por Laboratorio
- **Terraform**: AWS CLI configurado, credenciales válidas
- **Vault**: Docker ejecutándose
- **Nomad**: Docker ejecutándose
- **Consul**: Ninguno adicional
- **Vault Radar**: Git configurado

## 📖 Curso Complementario

Curso gratuito de 1 hora en Udemy: [HashiCorp Foundational](link-pendiente)

El curso incluye:
- Introducción al ecosistema HashiCorp
- Demos de cada laboratorio
- Explicación de conceptos clave
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
- 🏆 **Vault Practitioner** - Secretos dinámicos
- 🏆 **Vault Radar Practitioner** - Escaneo de secretos
- 🏆 **Nomad Practitioner** - Orquestación de contenedores
- 🏆 **Consul Practitioner** - Service discovery y KV store
- 🎖️ **HashiCorp Foundational Complete** - Badge fundacional (todos los labs)

### Comandos Útiles
```bash
# Ver estado de badges
./show-badges.sh

# Validar todos los labs y generar badges
./validate-all-labs.sh

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
./show-badges.sh

# Validar todos los labs y generar badges
./validate-all-labs.sh

# Ver badges obtenidos
find . -name ".badge-*-earned" -exec basename {} \; | sort

# Verificar badge fundacional
ls -la .foundational-badge-earned 2>/dev/null && echo "🏆 Badge Fundacional Obtenido!"
```

## 📄 Licencia

MIT License - ver [LICENSE](LICENSE) para detalles.

---

**¡Comienza tu journey HashiCorp hoy mismo!** 🚀

Cada laboratorio te llevará solo 10-15 minutos y al final tendrás competencias validadas en las herramientas más importantes de la infraestructura moderna.

---

*Última actualización: Noviembre 2024*

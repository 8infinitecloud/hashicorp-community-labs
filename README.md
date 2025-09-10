# HashiCorp Foundational Labs

![HashiCorp Foundational](https://img.shields.io/badge/HashiCorp-Foundational-623CE4?style=for-the-badge&logo=hashicorp)

Laboratorios prácticos de 10-15 minutos para aprender los fundamentos del ecosistema HashiCorp con validación automática.

## 🎯 Objetivo

Obtener experiencia práctica con las herramientas principales de HashiCorp a través de laboratorios validados automáticamente.

## 🏆 Sistema de Badges

### Badges por Tecnología
- ![Terraform Practitioner](https://img.shields.io/badge/Terraform-Practitioner-7B42BC?style=flat&logo=terraform)
- ![Vault Practitioner](https://img.shields.io/badge/Vault-Practitioner-FFD814?style=flat&logo=vault)
- ![Nomad Practitioner](https://img.shields.io/badge/Nomad-Practitioner-00CA8E?style=flat&logo=nomad)
- ![Consul Practitioner](https://img.shields.io/badge/Consul-Practitioner-F24C53?style=flat&logo=consul)

### Badge Fundacional
![HashiCorp Foundational](https://img.shields.io/badge/HashiCorp-Foundational%20Complete-623CE4?style=for-the-badge&logo=hashicorp)

## 📚 Laboratorios Disponibles

### 1. Terraform - Infraestructura como Código
- **Lab 1**: [Deploy básico en AWS](./labs/terraform/basic-aws-deploy/)
- **Duración**: 10-15 minutos
- **Validación**: ✅ Automática con GitHub Actions

### 2. Vault - Manejo de Secretos
- **Lab 1**: [Secretos dinámicos](./labs/vault/dynamic-secrets/)
- **Duración**: 10-15 minutos
- **Validación**: ✅ Automática con GitHub Actions

### 3. Vault Radar - Escaneo de Secretos
- **Lab 1**: [Escaneo de repositorios](./labs/vault-radar/repo-scanning/)
- **Duración**: 10-15 minutos
- **Validación**: ✅ Automática con GitHub Actions

### 4. Nomad - Orquestación de Workloads
- **Lab 1**: [Deploy de contenedor](./labs/nomad/container-deploy/)
- **Duración**: 10-15 minutos
- **Validación**: ✅ Automática con GitHub Actions

### 5. Consul - Service Discovery
- **Lab 1**: [KV Store básico](./labs/consul/kv-store/)
- **Duración**: 10-15 minutos
- **Validación**: ✅ Automática con GitHub Actions

## 🚀 Inicio Rápido

### Opción 1: GitHub Codespaces
1. Haz clic en "Code" → "Codespaces" → "Create codespace"
2. Navega al laboratorio deseado
3. Sigue las instrucciones del README

### Opción 2: Entorno Local
```bash
git clone https://github.com/tu-usuario/hashicorp-foundational-labs.git
cd hashicorp-foundational-labs
cd labs/<tecnologia>/<lab>
```

## 🔧 Requisitos

- Docker (para algunos labs)
- AWS CLI configurado (para labs de Terraform)
- Git

## 📖 Curso Complementario

Curso gratuito de 1 hora en Udemy: [HashiCorp Foundational](link-pendiente)

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

## 📄 Licencia

MIT License - ver [LICENSE](LICENSE) para detalles.

# Lab 1: Instalación de Terraform

![Terraform](https://img.shields.io/badge/Terraform-Installation-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Instalar Terraform en tu sistema operativo y verificar que la instalación sea correcta.

## ⏱️ Duración
15 minutos

## 📋 Prerrequisitos
- Acceso a terminal/línea de comandos
- Permisos de administrador (para instalación)
- Conexión a internet

## 🚀 Instrucciones Paso a Paso

### Opción 1: Instalación con Homebrew (macOS - Recomendado)

```bash
# Instalar Terraform con Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verificar instalación
terraform version
```

### Opción 2: Instalación Manual (macOS/Linux/Windows)

#### macOS

```bash
# Descargar Terraform
cd ~/Downloads
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_darwin_amd64.zip

# Para Mac con chip M1/M2/M3 (ARM)
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_darwin_arm64.zip

# Descomprimir
unzip terraform_1.7.0_darwin_*.zip

# Mover a PATH
sudo mv terraform /usr/local/bin/

# Verificar permisos
sudo chmod +x /usr/local/bin/terraform

# Verificar instalación
terraform version
```

#### Linux (Ubuntu/Debian)

```bash
# Agregar repositorio de HashiCorp
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Actualizar e instalar
sudo apt update
sudo apt install terraform

# Verificar instalación
terraform version
```

#### Windows

```powershell
# Opción 1: Con Chocolatey
choco install terraform

# Opción 2: Manual
# 1. Descargar desde https://www.terraform.io/downloads
# 2. Descomprimir el archivo ZIP
# 3. Mover terraform.exe a C:\Windows\System32\
# 4. O agregar la carpeta al PATH en Variables de Entorno

# Verificar instalación
terraform version
```

### Paso 2: Verificar la Instalación

```bash
# Ver versión instalada
terraform version

# Salida esperada:
# Terraform v1.7.0
# on darwin_arm64 (o tu plataforma)
```

### Paso 3: Ver Comandos Disponibles

```bash
# Ver todos los comandos de Terraform
terraform -help

# Ver ayuda de un comando específico
terraform init -help
terraform plan -help
terraform apply -help
```

### Paso 4: Habilitar Autocompletado (Opcional)

```bash
# Bash
terraform -install-autocomplete
source ~/.bashrc

# Zsh
terraform -install-autocomplete
source ~/.zshrc

# Fish
terraform -install-autocomplete
source ~/.config/fish/config.fish
```

### Paso 5: Ejecutar el Script de Validación

```bash
# Ejecutar script de validación
./validate-lab.sh
```

## ✅ Criterios de Validación

Para completar exitosamente este laboratorio:

1. ✅ Terraform instalado correctamente
2. ✅ Comando `terraform version` funciona
3. ✅ Versión 1.0 o superior
4. ✅ Terraform está en el PATH del sistema

## 🔧 Troubleshooting

### Error: "command not found: terraform"

**Causa:** Terraform no está en el PATH del sistema

**Solución:**
```bash
# Verificar ubicación de terraform
which terraform

# Si no está en PATH, agregarlo
# macOS/Linux
export PATH=$PATH:/usr/local/bin

# Agregar permanentemente a ~/.bashrc o ~/.zshrc
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc
```

### Error: "permission denied"

**Causa:** El binario no tiene permisos de ejecución

**Solución:**
```bash
# Dar permisos de ejecución
sudo chmod +x /usr/local/bin/terraform

# O si está en otra ubicación
chmod +x /ruta/a/terraform
```

### Error: "terraform: cannot execute binary file"

**Causa:** Descargaste la versión incorrecta para tu arquitectura

**Solución:**
```bash
# Verificar tu arquitectura
uname -m
# x86_64 = AMD64
# arm64 = ARM64 (M1/M2/M3)

# Descargar la versión correcta
# Para Intel: terraform_*_darwin_amd64.zip
# Para M1/M2/M3: terraform_*_darwin_arm64.zip
```

### Windows: "terraform no se reconoce como comando"

**Causa:** Terraform no está en el PATH de Windows

**Solución:**
1. Buscar "Variables de entorno" en el menú inicio
2. Editar "Path" en Variables del sistema
3. Agregar la ruta donde está terraform.exe
4. Reiniciar la terminal

## 📚 Recursos Adicionales

- [Documentación oficial de instalación](https://developer.hashicorp.com/terraform/downloads)
- [Terraform CLI Documentation](https://developer.hashicorp.com/terraform/cli)
- [Terraform Tutorials](https://developer.hashicorp.com/terraform/tutorials)

## 🎓 Conceptos Aprendidos

- ✅ Instalación de Terraform en diferentes sistemas operativos
- ✅ Verificación de instalación
- ✅ Comandos básicos de Terraform CLI
- ✅ Configuración del entorno de desarrollo

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Installation Badge**

---

**Siguiente:** [Lab 2 - Tu Primer Archivo Terraform](../02-primer-archivo/)

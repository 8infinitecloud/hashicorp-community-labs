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

### Paso 1: Instalar Terraform

Elige el método según tu sistema operativo:

**macOS — Homebrew (recomendado):**

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**macOS — Manual (Intel o Apple Silicon):**

```bash
cd ~/Downloads

# Intel (x86_64)
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_darwin_amd64.zip

# Apple Silicon (M1/M2/M3)
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_darwin_arm64.zip

unzip terraform_1.7.0_darwin_*.zip
sudo mv terraform /usr/local/bin/
sudo chmod +x /usr/local/bin/terraform
```

**Linux (Ubuntu/Debian):**

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform
```

**Windows — Chocolatey:**

```powershell
choco install terraform
```

**Windows — Manual:**
1. Descargar desde https://www.terraform.io/downloads
2. Descomprimir el archivo ZIP
3. Mover `terraform.exe` a `C:\Windows\System32\`
4. O agregar la carpeta al PATH en Variables de Entorno

### Paso 2: Verificar la Instalación

```bash
terraform version
# Salida esperada:
# Terraform v1.7.0
# on darwin_arm64  (o tu plataforma)
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
terraform -install-autocomplete

# Recargar shell según el que uses
source ~/.bashrc   # Bash
source ~/.zshrc    # Zsh
```

### Paso 5: Ejecutar el Script de Validación

```bash
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
which terraform
export PATH=$PATH:/usr/local/bin
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc
```

### Error: "permission denied"

**Causa:** El binario no tiene permisos de ejecución

**Solución:**
```bash
sudo chmod +x /usr/local/bin/terraform
```

### Error: "terraform: cannot execute binary file"

**Causa:** Descargaste la versión incorrecta para tu arquitectura

**Solución:**
```bash
uname -m
# x86_64 → descargar darwin_amd64.zip  (Intel)
# arm64  → descargar darwin_arm64.zip  (Apple Silicon)
```

### Windows: "terraform no se reconoce como comando"

**Causa:** Terraform no está en el PATH de Windows

**Solución:**
1. Buscar "Variables de entorno" en el menú inicio
2. Editar "Path" en Variables del sistema
3. Agregar la ruta donde está `terraform.exe`
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

**Siguiente:** [Lab 2 - Tu Primer Archivo Terraform](../lab2-primer-archivo/)

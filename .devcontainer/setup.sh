#!/bin/bash

echo "🚀 Configurando entorno HashiCorp Foundational Labs..."

# Actualizar sistema
sudo apt-get update

# Instalar dependencias
sudo apt-get install -y \
    curl \
    wget \
    unzip \
    jq \
    postgresql-client

# Instalar HashiCorp tools
echo "📦 Instalando herramientas HashiCorp..."

# Agregar repositorio HashiCorp
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Actualizar e instalar
sudo apt-get update
sudo apt-get install -y \
    terraform \
    vault \
    nomad \
    consul

# Verificar instalaciones
echo "✅ Verificando instalaciones..."
terraform version
vault version
nomad version
consul version

# Configurar aliases útiles
echo "🔧 Configurando aliases..."
cat >> ~/.bashrc << 'EOF'

# HashiCorp Labs aliases
alias tf='terraform'
alias v='vault'
alias n='nomad'
alias c='consul'

# Navegación rápida a labs
alias lab-tf='cd /workspaces/hashicorp-foundational-labs/labs/terraform/basic-aws-deploy'
alias lab-vault='cd /workspaces/hashicorp-foundational-labs/labs/vault/dynamic-secrets'
alias lab-nomad='cd /workspaces/hashicorp-foundational-labs/labs/nomad/container-deploy'
alias lab-consul='cd /workspaces/hashicorp-foundational-labs/labs/consul/kv-store'
alias lab-radar='cd /workspaces/hashicorp-foundational-labs/labs/vault-radar/repo-scanning'

# Funciones útiles
lab-status() {
    echo "🏆 HashiCorp Labs Status"
    echo "======================="
    echo "📁 Directorio actual: $(pwd)"
    echo "🐳 Docker: $(docker --version 2>/dev/null || echo 'No disponible')"
    echo "🏗️  Terraform: $(terraform version -json 2>/dev/null | jq -r '.terraform_version' || echo 'No disponible')"
    echo "🔐 Vault: $(vault version 2>/dev/null | head -1 || echo 'No disponible')"
    echo "🚀 Nomad: $(nomad version 2>/dev/null | head -1 || echo 'No disponible')"
    echo "🔗 Consul: $(consul version 2>/dev/null | head -1 || echo 'No disponible')"
}

lab-help() {
    echo "🎯 HashiCorp Labs - Comandos Disponibles"
    echo "========================================"
    echo "lab-tf      - Ir al lab de Terraform"
    echo "lab-vault   - Ir al lab de Vault"
    echo "lab-nomad   - Ir al lab de Nomad"
    echo "lab-consul  - Ir al lab de Consul"
    echo "lab-radar   - Ir al lab de Vault Radar"
    echo "lab-status  - Ver estado del entorno"
    echo "lab-help    - Mostrar esta ayuda"
}
EOF

# Hacer scripts ejecutables
find /workspaces/hashicorp-foundational-labs/labs -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

echo "🎉 Configuración completada!"
echo "💡 Ejecuta 'lab-help' para ver comandos disponibles"
echo "📚 Navega a los labs con 'lab-<tecnologia>'"

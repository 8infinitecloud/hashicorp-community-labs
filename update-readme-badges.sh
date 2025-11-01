#!/bin/bash

echo "🔄 Actualizando badges en README..."

# Crear contenido de badges basado en archivos existentes
BADGES_CONTENT=""
FOUNDATIONAL_CONTENT=""

# Verificar badges individuales
if [ -f ".badge-terraform-earned" ]; then
    BADGES_CONTENT+="- ![Terraform Practitioner](https://img.shields.io/badge/Terraform-Practitioner-7B42BC?style=flat&logo=terraform) **Obtenido:** $(cat .badge-terraform-earned)\n"
fi

if [ -f ".badge-vault-earned" ]; then
    BADGES_CONTENT+="- ![Vault Practitioner](https://img.shields.io/badge/Vault-Practitioner-FFD814?style=flat&logo=vault) **Obtenido:** $(cat .badge-vault-earned)\n"
fi

if [ -f ".badge-nomad-earned" ]; then
    BADGES_CONTENT+="- ![Nomad Practitioner](https://img.shields.io/badge/Nomad-Practitioner-00CA8E?style=flat&logo=nomad) **Obtenido:** $(cat .badge-nomad-earned)\n"
fi

if [ -f ".badge-consul-earned" ]; then
    BADGES_CONTENT+="- ![Consul Practitioner](https://img.shields.io/badge/Consul-Practitioner-F24C53?style=flat&logo=consul) **Obtenido:** $(cat .badge-consul-earned)\n"
fi

if [ -f ".badge-vault-radar-earned" ]; then
    BADGES_CONTENT+="- ![Vault Radar Practitioner](https://img.shields.io/badge/Vault%20Radar-Practitioner-FFD814?style=flat&logo=vault) **Obtenido:** $(cat .badge-vault-radar-earned)\n"
fi

# Verificar badge fundacional
if [ -f ".foundational-badge-earned" ]; then
    FOUNDATIONAL_CONTENT="![HashiCorp Foundational](https://img.shields.io/badge/HashiCorp-Foundational%20Complete-623CE4?style=for-the-badge&logo=hashicorp)\n\n**🎉 ¡FELICITACIONES!** Badge Fundacional obtenido: $(cat .foundational-badge-earned)"
fi

# Si no hay badges, mostrar mensaje por defecto
if [ -z "$BADGES_CONTENT" ]; then
    BADGES_CONTENT="*Completa los laboratorios para ver tus badges aquí*"
fi

if [ -z "$FOUNDATIONAL_CONTENT" ]; then
    FOUNDATIONAL_CONTENT="*Completa todos los laboratorios para desbloquear el badge fundacional*"
fi

# Actualizar README usando sed
sed -i.bak "/<!-- BADGES_START -->/,/<!-- BADGES_END -->/{
    /<!-- BADGES_START -->/!{
        /<!-- BADGES_END -->/!d
    }
}" README.md

sed -i.bak "/<!-- BADGES_START -->/a\\
$BADGES_CONTENT
" README.md

sed -i.bak "/<!-- FOUNDATIONAL_BADGE_START -->/,/<!-- FOUNDATIONAL_BADGE_END -->/{
    /<!-- FOUNDATIONAL_BADGE_START -->/!{
        /<!-- FOUNDATIONAL_BADGE_END -->/!d
    }
}" README.md

sed -i.bak "/<!-- FOUNDATIONAL_BADGE_START -->/a\\
$FOUNDATIONAL_CONTENT
" README.md

# Limpiar archivos de respaldo
rm -f README.md.bak

echo "✅ README actualizado con badges obtenidos"

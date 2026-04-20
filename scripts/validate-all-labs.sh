#!/bin/bash

echo "🏆 HashiCorp Terraform Labs - Validación Completa"
echo "=================================================="

TOTAL_LABS=1
COMPLETED_LABS=0
FAILED_LABS=()

# Función para validar un laboratorio
validate_lab() {
    local lab_name=$1
    local lab_path=$2
    
    echo ""
    echo "🔍 Validando $lab_name..."
    echo "$(printf '=%.0s' {1..50})"
    
    cd "$lab_path"
    
    if [ -f "validate-lab.sh" ]; then
        if ./validate-lab.sh; then
            echo "✅ $lab_name - COMPLETADO"
            # Generar badge automáticamente
            echo "$(date +%Y%m%d-%H%M%S)" > ".badge-${lab_name,,}-earned"
            echo "🏆 Badge ${lab_name} Practitioner obtenido!"
            ((COMPLETED_LABS++))
        else
            echo "❌ $lab_name - FALLIDO"
            FAILED_LABS+=("$lab_name")
        fi
    else
        echo "⚠️  $lab_name - Script de validación no encontrado"
        FAILED_LABS+=("$lab_name")
    fi
    
    cd - > /dev/null
}

# Validar laboratorios de Terraform
validate_lab "Terraform" "labs/1. terraform/basic-aws-deploy"

# Labs comentados - descomentar cuando estén listos
# validate_lab "Vault" "labs/2. vault/dynamic-secrets"
# validate_lab "Nomad" "labs/4. nomad/container-deploy"
# validate_lab "Consul" "labs/5. consul/kv-store"
# validate_lab "Vault Radar" "labs/3. vault-radar/repo-scanning"

# Mostrar resultado final
echo ""
echo "📊 RESULTADO FINAL"
echo "=================="
echo "Laboratorios completados: $COMPLETED_LABS/$TOTAL_LABS"

if [ $COMPLETED_LABS -eq $TOTAL_LABS ]; then
    echo ""
    echo "🎉 ¡FELICITACIONES!"
    echo "🏆 Has completado todos los HashiCorp Foundational Labs"
    echo ""
    echo "Badges obtenidos:"
    
    # Verificar y mostrar badges reales
    for badge_file in $(find . -name ".badge-*-earned" 2>/dev/null | sort); do
        badge_name=$(basename "$badge_file" | sed 's/.badge-\(.*\)-earned/\1/' | tr '[:lower:]' '[:upper:]')
        badge_date=$(cat "$badge_file")
        echo "✅ $badge_name Practitioner (obtenido: $badge_date)"
    done
    
    echo ""
    echo "🎖️  BADGE FUNDACIONAL DESBLOQUEADO:"
    echo "🏆 HashiCorp Foundational Complete"
    echo ""
    echo "Ahora puedes:"
    echo "📚 Tomar el curso complementario en Udemy"
    echo "🔗 Compartir tus badges en LinkedIn"
    echo "🚀 Continuar con laboratorios avanzados"
    
    # Crear badge fundacional
    echo "hashicorp-foundational-complete-$(date +%Y%m%d-%H%M%S)" > .foundational-badge-earned
    
    # Actualizar badges en GitHub si estamos en Codespace
    if [ -n "$CODESPACE_NAME" ]; then
        echo ""
        echo "🔄 Sincronizando badges con GitHub..."
        ./scripts/update-github-badges.sh
    fi
    
elif [ $COMPLETED_LABS -gt 0 ]; then
    echo ""
    echo "🎯 Progreso: $COMPLETED_LABS/$TOTAL_LABS laboratorios completados"
    echo ""
    
    # Mostrar badges obtenidos
    earned_badges=$(find . -name ".badge-*-earned" 2>/dev/null | wc -l)
    if [ $earned_badges -gt 0 ]; then
        echo "🏆 Badges obtenidos:"
        for badge_file in $(find . -name ".badge-*-earned" 2>/dev/null | sort); do
            badge_name=$(basename "$badge_file" | sed 's/.badge-\(.*\)-earned/\1/' | tr '[:lower:]' '[:upper:]')
            echo "✅ $badge_name Practitioner"
        done
        echo ""
    fi
    
    echo "Laboratorios pendientes:"
    for lab in "${FAILED_LABS[@]}"; do
        echo "⏳ $lab"
    done
    echo ""
    echo "💡 Completa todos los laboratorios para obtener el badge fundacional"
    
else
    echo ""
    echo "🚀 ¡Comienza tu journey HashiCorp!"
    echo "Ejecuta los laboratorios en orden:"
    echo "1. cd \"labs/1. terraform/basic-aws-deploy\" && ./validate-lab.sh"
    echo "2. cd \"labs/2. vault/dynamic-secrets\" && ./validate-lab.sh"
    echo "3. cd \"labs/3. vault-radar/repo-scanning\" && ./validate-lab.sh"
    echo "4. cd \"labs/4. nomad/container-deploy\" && ./validate-lab.sh"
    echo "5. cd \"labs/5. consul/kv-store\" && ./validate-lab.sh"
fi

echo ""
echo "📖 Para más información, visita: https://github.com/tu-usuario/hashicorp-foundational-labs"
